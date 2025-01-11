//
//  BruinEatsAppApp.swift
//  BruinEatsApp
//
//  Created by Sneha Agarwal on 1/10/25.
//

import SwiftUI

@main
struct BruinEatsAppApp: App {
    
    @StateObject private var model = BruinEatsModel()
    @StateObject private var appState = AppState()
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appState.routes) {
                RegistrationScreen()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .register:
                            RegistrationScreen()
                        case .login:
                            LoginScreen()
                        case .bruineatsList:
                            BruinEatsList()
                        }
                    }
            }
            .environmentObject(model)
            .environmentObject(appState)
        }
    }
}
