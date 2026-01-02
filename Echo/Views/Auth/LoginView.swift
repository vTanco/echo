import SwiftUI

/// Login and registration view
struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            AnimatedGradient()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)
                    
                    // Logo
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.accentCyan.opacity(0.3), Color.clear],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.accentCyan, .accentMagenta],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: .accentCyan.opacity(0.5), radius: 20)
                            
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 30, height: 30)
                        }
                        
                        Text("Echo")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accentCyan, .accentMagenta],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("El Mercado de Cómputo Inactivo")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Form
                    VStack(spacing: 16) {
                        if isRegistering {
                            CustomTextField(
                                icon: "person",
                                placeholder: "Nombre",
                                text: $displayName
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        CustomTextField(
                            icon: "envelope",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            icon: "lock",
                            placeholder: "Contraseña",
                            text: $password,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.3), value: isRegistering)
                    
                    // Submit button
                    Button(action: submit) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isRegistering ? "Crear cuenta" : "Iniciar sesión")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.accentCyan, .accentMagenta],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(authManager.isLoading || !isFormValid)
                    .opacity(isFormValid ? 1 : 0.6)
                    .padding(.horizontal)
                    
                    // Toggle mode
                    Button(action: {
                        HapticManager.shared.selection()
                        withAnimation(.spring()) {
                            isRegistering.toggle()
                        }
                    }) {
                        Text(isRegistering ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate")
                            .font(.subheadline)
                            .foregroundColor(.accentCyan)
                    }
                    
                    Spacer()
                }
            }
            
            // Loading overlay
            if authManager.isLoading {
                LoadingOverlay(message: isRegistering ? "Creando cuenta..." : "Iniciando sesión...")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6 &&
        (!isRegistering || !displayName.isEmpty)
    }
    
    private func submit() {
        HapticManager.shared.buttonTap()
        
        Task {
            do {
                if isRegistering {
                    try await authManager.register(email: email, password: password, displayName: displayName)
                } else {
                    try await authManager.login(email: email, password: password)
                }
                ToastManager.shared.success("¡Bienvenido a Echo!")
            } catch {
                HapticManager.shared.error()
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

/// Custom text field with icon
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    LoginView()
}
