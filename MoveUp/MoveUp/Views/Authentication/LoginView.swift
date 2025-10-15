//
//  LoginView.swift
//  MoveUp
//
//  Created by MoveUp on 14/10/2025.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.moveUpPrimary.opacity(0.1),
                        Color.moveUpBackground
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.moveUpPrimary)
                            
                            Text("Bentornato!")
                                .font(MoveUpFont.title(32))
                                .fontWeight(.bold)
                                .foregroundColor(.moveUpTextPrimary)
                            
                            Text("Accedi al tuo account MoveUp")
                                .font(MoveUpFont.body())
                                .foregroundColor(.moveUpTextSecondary)
                        }
                        .padding(.top, 60)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Email", systemImage: "envelope.fill")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(.moveUpTextSecondary)
                                
                                TextField("mario.rossi@email.com", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Password", systemImage: "lock.fill")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(.moveUpTextSecondary)
                                
                                SecureField("La tua password", text: $password)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button("Password dimenticata?") {
                                    // TODO: Password reset
                                }
                                .font(MoveUpFont.caption())
                                .foregroundColor(.moveUpPrimary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Error Message
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(MoveUpFont.caption())
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        
                        // Login Button
                        Button(action: handleLogin) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text("Accedi")
                            }
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.moveUpPrimary : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || authViewModel.isLoading)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Indietro")
                        }
                        .foregroundColor(.moveUpPrimary)
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func handleLogin() {
        authViewModel.signIn(email: email, password: password)
    }
}
