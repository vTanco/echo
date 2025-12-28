import SwiftUI

struct PulsingOrb: View {
    let isActive: Bool
    let size: CGFloat
    let primaryColor: Color
    let secondaryColor: Color
    
    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0
    @State private var innerRotation: Double = 0
    
    init(
        isActive: Bool = true,
        size: CGFloat = 200,
        primaryColor: Color = .accentCyan,
        secondaryColor: Color = .accentMagenta
    ) {
        self.isActive = isActive
        self.size = size
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
    
    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.3), secondaryColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size + CGFloat(index * 40), height: size + CGFloat(index * 40))
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .opacity(isPulsing ? 0.3 : 0.6)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: isPulsing
                    )
            }
            
            // Rotating outer ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [primaryColor, secondaryColor, primaryColor],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: size + 20, height: size + 20)
                .rotationEffect(.degrees(rotationAngle))
            
            // Inner rotating elements
            ForEach(0..<6) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [primaryColor.opacity(0.8), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 15
                        )
                    )
                    .frame(width: 20, height: 20)
                    .offset(x: size / 2 - 10)
                    .rotationEffect(.degrees(Double(index) * 60 + innerRotation))
            }
            
            // Core orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            primaryColor.opacity(0.9),
                            secondaryColor.opacity(0.6),
                            .black.opacity(0.3)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size - 20, height: size - 20)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.4), .clear],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: size / 3
                            )
                        )
                )
                .scaleEffect(isPulsing ? 1.05 : 0.95)
            
            // Center highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.8), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(isPulsing ? 1.2 : 0.8)
            
            // Activity indicator
            if isActive {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: primaryColor, radius: 10)
            } else {
                Image(systemName: "moon.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .shadow(color: primaryColor.opacity(isActive ? 0.5 : 0.2), radius: isActive ? 40 : 20)
        .onAppear {
            if isActive {
                startAnimations()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
        
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            innerRotation = -360
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 50) {
            PulsingOrb(isActive: true, size: 150)
            PulsingOrb(isActive: false, size: 100, primaryColor: .gray, secondaryColor: .gray)
        }
    }
}
