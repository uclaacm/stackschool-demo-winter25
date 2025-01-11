import SwiftUI

struct RegistrationScreen: View {
    
    @EnvironmentObject private var model: BruinEatsModel
    @EnvironmentObject private var appState: AppState
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty && (password.count >= 6 && password.count <= 10)
    }
    private func register() async {
        
        do {
            let registerResponseDTO = try await model.register(username: username, password: password)
            
            if !registerResponseDTO.error {
                // take the user to the login screen
                appState.routes.append(.login)
            } else {
                errorMessage = registerResponseDTO.reason ?? ""
            }
           
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var body: some View {
        Form {
            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            
            HStack {
                Button("Register") {
                    Task {
                        await register()
                    }
                }.buttonStyle(.borderless)
                    .disabled(!isFormValid)
                
                Spacer()
                
                Button("Login") {
                    appState.routes.append(.login)
                }.buttonStyle(.borderless)
            }
            
            Text(errorMessage)
            
        }
        .navigationTitle("Registration")
    }
}
struct RegistrationScreenContainer: View {
    
    @StateObject private var model = BruinEatsModel()
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationStack(path: $appState.routes) {
            RegistrationScreen()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                        case .register:
                            RegistrationScreen()
                        case .login:
                            LoginScreen()
                        case .bruineatsList:
                            Text("bruin eats list")
                    }
                }
        }
        .environmentObject(model)
        .environmentObject(appState)
    }
    
}

#Preview {
    RegistrationScreenContainer()
}
