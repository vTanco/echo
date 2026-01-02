import SwiftUI

/// Empty state view with icon and message
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.accentCyan.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentCyan, .accentMagenta],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
            }
            .animation(
                Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            // Text
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Optional action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    HapticManager.shared.buttonTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.accentCyan, .accentMagenta],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .padding(32)
        .onAppear {
            isAnimating = true
        }
    }
}

/// Predefined empty states
extension EmptyStateView {
    static var noSessions: EmptyStateView {
        EmptyStateView(
            icon: "cpu",
            title: "Sin sesiones",
            message: "Aún no has iniciado ninguna sesión de cómputo. ¡Empieza a generar ganancias!",
            actionTitle: "Iniciar sesión",
            action: nil
        )
    }
    
    static var noEarnings: EmptyStateView {
        EmptyStateView(
            icon: "eurosign.circle",
            title: "Sin ganancias",
            message: "Completa tareas de cómputo para empezar a generar ingresos pasivos."
        )
    }
    
    static var noDevices: EmptyStateView {
        EmptyStateView(
            icon: "iphone.gen3",
            title: "Sin dispositivos",
            message: "Registra este dispositivo para empezar a contribuir a la red Echo."
        )
    }
    
    static var noTasks: EmptyStateView {
        EmptyStateView(
            icon: "tray",
            title: "Sin tareas",
            message: "No hay tareas pendientes en este momento. Las nuevas tareas aparecerán automáticamente."
        )
    }
    
    static var offline: EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "Sin conexión",
            message: "Comprueba tu conexión a Internet e inténtalo de nuevo.",
            actionTitle: "Reintentar",
            action: nil
        )
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        EmptyStateView.noSessions
    }
}
