import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let accentCyan = Color("AccentCyan")
    static let accentMagenta = Color("AccentMagenta")
    static let accentViolet = Color("AccentViolet")
    static let accentGreen = Color("AccentGreen")
    static let accentOrange = Color("AccentOrange")
    static let cardBackground = Color("CardBackground")
    static let darkBackground = Color("DarkBackground")
    
    // Gradient presets
    static let neonGradient = LinearGradient(
        colors: [.accentCyan, .accentMagenta],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cosmicGradient = LinearGradient(
        colors: [.accentViolet, .accentMagenta, .accentCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let energyGradient = LinearGradient(
        colors: [.accentGreen, .accentCyan],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [.accentOrange, .accentMagenta],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - View Extensions
extension View {
    func glassBackground(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.white.opacity(0.05))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    func glowEffect(color: Color, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color.opacity(0.5), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
    }
    
    func cardStyle() -> some View {
        self
            .padding()
            .glassBackground()
    }
    
    func shimmer(delay: Double = 0) -> some View {
        modifier(ShimmerModifier(delay: delay))
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.1),
                            .white.opacity(0.3),
                            .white.opacity(0.1),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    phase = 1
                }
            }
    }
}

// MARK: - Number Formatting
extension Double {
    var euroCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: self)) ?? "€0.00"
    }
    
    var compactCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "€0.00"
    }
}

// MARK: - Date Formatting
extension Date {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    var relativeDateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let smoothSpring = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let gentleBounce = Animation.spring(response: 0.6, dampingFraction: 0.6)
}
