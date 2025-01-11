//
//  LoginScreen.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 1/10/25.
//

import SwiftUI

struct LoginScreen: View {
    
    @EnvironmentObject private var model: BruinEatsModel
    @EnvironmentObject private var appState: AppState
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty && (password.count >= 6 && password.count <= 10)
    }
    
    private func login() async {
        do {
            let loginResponseDTO = try await model.login(username: username, password: password)
            if loginResponseDTO.error {
                errorMessage = loginResponseDTO.reason ?? ""
            } else {
                appState.routes.append(.bruineatsList)
            }
        } catch {
            errorMessage = "error.localizedDescription"
        }
    }
    
    var body: some View {
        Form {
            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            
            HStack {
                Button("Login") {
                    Task {
                        await login()
                    }
                }.buttonStyle(.borderless)
                    .disabled(!isFormValid)
            }
            Text(errorMessage)
        }.navigationTitle("Login")
    }
}

#Preview {
    NavigationStack {
        LoginScreen()
            .environmentObject(BruinEatsModel())
            .environmentObject(AppState())
    }
}
