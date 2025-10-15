//
//  APIService.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//  Service per chiamate API al backend
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8080/api"
    
    private init() {}
    
    // MARK: - Wallet Endpoints
    
    func setupBankAccount(
        userId: String,
        iban: String,
        accountHolderName: String,
        country: String,
        completion: @escaping (Result<Wallet, Error>) -> Void
    ) {
        let endpoint = "\(baseURL)/wallet/setup"
        
        let request = [
            "userId": userId,
            "iban": iban,
            "accountHolderName": accountHolderName,
            "country": country
        ]
        
        performRequest(endpoint: endpoint, method: "POST", body: request, completion: completion)
    }
    
    func getWallet(userId: String, completion: @escaping (Result<Wallet, Error>) -> Void) {
        let endpoint = "\(baseURL)/wallet?userId=\(userId)"
        performRequest(endpoint: endpoint, method: "GET", completion: completion)
    }
    
    func getTransactions(
        userId: String,
        page: Int = 0,
        size: Int = 20,
        completion: @escaping (Result<TransactionPage, Error>) -> Void
    ) {
        let endpoint = "\(baseURL)/wallet/transactions?userId=\(userId)&page=\(page)&size=\(size)"
        performRequest(endpoint: endpoint, method: "GET", completion: completion)
    }
    
    func calculateFee(grossAmount: Double, completion: @escaping (Result<FeeBreakdown, Error>) -> Void) {
        let endpoint = "\(baseURL)/wallet/calculate-fee"
        let request = ["grossAmount": grossAmount]
        performRequest(endpoint: endpoint, method: "POST", body: request, completion: completion)
    }
    
    // MARK: - Booking/Payment Endpoints
    
    func validateLesson(
        _ request: ValidationRequest,
        completion: @escaping (Result<ValidationResponse, Error>) -> Void
    ) {
        let endpoint = "\(baseURL)/bookings/\(request.bookingId)/validate"
        
        let body: [String: Any] = [
            "qrCodeData": request.qrCodeData,
            "scannedBy": request.scannedBy
        ]
        
        performRequest(endpoint: endpoint, method: "POST", body: body, completion: completion)
    }
    
    // MARK: - Generic Request Method
    
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            // Handle error responses
            if httpResponse.statusCode >= 400 {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(.failure(APIError.serverError(errorResponse.error)))
                } else {
                    completion(.failure(APIError.httpError(httpResponse.statusCode)))
                }
                return
            }
            
            // Decode success response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                print("Decode error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response JSON: \(jsonString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Supporting Types

struct TransactionPage: Codable {
    let content: [Transaction]
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let number: Int
}

struct ErrorResponse: Codable {
    let error: String
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case httpError(Int)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL non valido"
        case .invalidResponse:
            return "Risposta non valida dal server"
        case .noData:
            return "Nessun dato ricevuto"
        case .httpError(let code):
            return "Errore HTTP \(code)"
        case .serverError(let message):
            return message
        }
    }
}
