//
//  InstantBookingMapView.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//  Mappa live con trainer disponibili ORA - stile Uber
//

import SwiftUI
import MapKit
import Combine
import CoreLocation

struct InstantBookingMapView: View {
    @StateObject private var viewModel = InstantBookingViewModel()
    @State private var selectedTrainer: InstantTrainer?
    @State private var showFilters = false
    
    var body: some View {
        ZStack {
            // Mappa con trainer pins
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.availableTrainers) { trainer in
                MapAnnotation(coordinate: trainer.coordinate) {
                    TrainerMapPin(
                        trainer: trainer,
                        isSelected: selectedTrainer?.id == trainer.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTrainer = trainer
                            }
                        }
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Top bar con filtri
            VStack {
                HStack(spacing: 12) {
                    // Sport filter
                    Menu {
                        Button("Tutti gli sport") {
                            viewModel.selectedSport = nil
                            viewModel.searchAvailableNow()
                        }
                        ForEach(viewModel.availableSports, id: \.self) { sport in
                            Button(sport) {
                                viewModel.selectedSport = sport
                                viewModel.searchAvailableNow()
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "sportscourt")
                            Text(viewModel.selectedSport ?? "Sport")
                                .fontWeight(.medium)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    
                    // Radius slider
                    Menu {
                        ForEach([2, 5, 10, 20], id: \.self) { radius in
                            Button("\(radius) km") {
                                viewModel.radius = Double(radius)
                                viewModel.searchAvailableNow()
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "location.circle")
                            Text("\(Int(viewModel.radius)) km")
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    // Refresh button
                    Button(action: { viewModel.searchAvailableNow() }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 60)
                
                // Stats banner
                if !viewModel.isLoading {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(viewModel.availableNowCount) trainer disponibili ora")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 3)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            
            // Bottom sheet con trainer selezionato
            if let trainer = selectedTrainer {
                VStack {
                    Spacer()
                    
                    TrainerQuickBookCard(
                        trainer: trainer,
                        onBook: {
                            viewModel.bookInstantLesson(trainer: trainer)
                        },
                        onClose: {
                            withAnimation {
                                selectedTrainer = nil
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Cercando trainer disponibili...")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                .padding(24)
                .background(Color.black.opacity(0.7))
                .cornerRadius(16)
            }
        }
        .onAppear {
            viewModel.requestLocationPermission()
            viewModel.searchAvailableNow()
        }
        .alert("Errore", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Errore sconosciuto")
        }
    }
}

// MARK: - Trainer Map Pin
struct TrainerMapPin: View {
    let trainer: InstantTrainer
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Pin body
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.green)
                    .frame(width: isSelected ? 56 : 44, height: isSelected ? 56 : 44)
                    .shadow(radius: isSelected ? 8 : 4)
                
                VStack(spacing: 2) {
                    if trainer.isAvailableNow {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    
                    Text("€\(Int(trainer.price))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Pin pointer
            Triangle()
                .fill(isSelected ? Color.blue : Color.green)
                .frame(width: 12, height: 8)
                .offset(y: -1)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Quick Book Card
struct TrainerQuickBookCard: View {
    let trainer: InstantTrainer
    let onBook: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header con close
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trainer.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", trainer.rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text("\(trainer.reviewCount) recensioni")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            // Info rapide
            VStack(spacing: 12) {
                MapInfoRow(icon: "location.fill", text: trainer.formattedDistance, color: .blue)
                MapInfoRow(icon: "clock.fill", text: "Disponibile tra \(trainer.formattedEta)", color: .green)
                MapInfoRow(icon: "mappin.circle.fill", text: trainer.location, color: .purple)
                
                if trainer.isAvailableNow {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                        Text("DISPONIBILE ORA!")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Divider()
            
            // Price + CTA
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prossima slot")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(trainer.nextSlot)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("€\(String(format: "%.2f", trainer.price))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("/ora")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Book button
            Button(action: onBook) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Prenota Ora")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

struct MapInfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

// MARK: - View Model
class InstantBookingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.4642, longitude: 9.1900), // Milano default
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var availableTrainers: [InstantTrainer] = []
    @Published var availableNowCount = 0
    @Published var selectedSport: String?
    @Published var radius: Double = 5.0
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    var availableSports = ["Tennis", "Padel", "Golf", "Fitness", "Yoga", "Pilates"]
    
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        region.center = location.coordinate
        locationManager.stopUpdatingLocation()
        
        // Auto-search dopo aver ottenuto la posizione
        searchAvailableNow()
    }
    
    func searchAvailableNow() {
        guard let location = userLocation else { return }
        
        isLoading = true
        
        // Chiamata API
        let urlString = "http://localhost:8080/api/instant-booking/now?lat=\(location.latitude)&lng=\(location.longitude)&radius=\(radius)"
        let finalURL = selectedSport != nil ? urlString + "&sport=\(selectedSport!)" : urlString
        
        guard let url = URL(string: finalURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let result = try JSONDecoder().decode(InstantBookingResponse.self, from: data)
                    self?.availableTrainers = result.availableNow + result.availableSoon
                    self?.availableNowCount = result.availableNow.count
                } catch {
                    print("Decode error: \(error)")
                }
            }
        }.resume()
    }
    
    func bookInstantLesson(trainer: InstantTrainer) {
        // TODO: Navigate to booking confirmation
        print("Booking lesson with \(trainer.name)")
    }
}

// MARK: - Data Models
struct InstantTrainer: Identifiable, Codable {
    let id: String
    let name: String
    let rating: Double
    let reviewCount: Int
    let latitude: Double
    let longitude: Double
    let distance: Double
    let etaMinutes: Int
    let nextSlot: String
    let location: String
    let price: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var formattedDistance: String {
        if distance < 1.0 {
            return "\(Int(distance * 1000)) m"
        }
        return String(format: "%.1f km", distance)
    }
    
    var formattedEta: String {
        if etaMinutes < 60 {
            return "\(etaMinutes) min"
        }
        let hours = etaMinutes / 60
        let mins = etaMinutes % 60
        return "\(hours)h \(mins)m"
    }
    
    var isAvailableNow: Bool {
        etaMinutes <= 30
    }
}

struct InstantBookingResponse: Codable {
    let success: Bool
    let availableNow: [InstantTrainer]
    let availableSoon: [InstantTrainer]
    let totalFound: Int
}

// MARK: - Preview
struct InstantBookingMapView_Previews: PreviewProvider {
    static var previews: some View {
        InstantBookingMapView()
    }
}
