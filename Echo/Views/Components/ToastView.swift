import SwiftUI

/// Toast notification types
enum ToastType {
    case success
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .accentGreen
        case .error: return .red
        case .warning: return .accentOrange
        case .info: return .accentCyan
        }
    }
}

/// Toast notification view
struct ToastView: View {
    let type: ToastType
    let message: String
    var subtitle: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundColor(type.color)
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(type.color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: type.color.opacity(0.2), radius: 10, y: 5)
    }
}

/// Toast manager for showing notifications
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var isShowing = false
    @Published var currentToast: (type: ToastType, message: String, subtitle: String?)? = nil
    
    private init() {}
    
    func show(_ type: ToastType, message: String, subtitle: String? = nil, duration: TimeInterval = 3.0) {
        HapticManager.shared.notification(type == .success ? .success : type == .error ? .error : .warning)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentToast = (type, message, subtitle)
            isShowing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.hide()
        }
    }
    
    func hide() {
        withAnimation(.easeOut(duration: 0.2)) {
            isShowing = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentToast = nil
        }
    }
    
    // Convenience methods
    func success(_ message: String, subtitle: String? = nil) {
        show(.success, message: message, subtitle: subtitle)
    }
    
    func error(_ message: String, subtitle: String? = nil) {
        show(.error, message: message, subtitle: subtitle)
    }
    
    func warning(_ message: String, subtitle: String? = nil) {
        show(.warning, message: message, subtitle: subtitle)
    }
    
    func info(_ message: String, subtitle: String? = nil) {
        show(.info, message: message, subtitle: subtitle)
    }
}

/// Toast container modifier
struct ToastContainerModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                if toastManager.isShowing, let toast = toastManager.currentToast {
                    ToastView(
                        type: toast.type,
                        message: toast.message,
                        subtitle: toast.subtitle
                    )
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}

extension View {
    func toastContainer() -> some View {
        modifier(ToastContainerModifier())
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        VStack(spacing: 20) {
            ToastView(type: .success, message: "¡Tarea completada!", subtitle: "+€0.005")
            ToastView(type: .error, message: "Error de conexión")
            ToastView(type: .warning, message: "Batería baja", subtitle: "Conecta el cargador")
            ToastView(type: .info, message: "Nueva tarea disponible")
        }
        .padding()
    }
}
