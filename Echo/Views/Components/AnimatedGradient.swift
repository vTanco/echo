import SwiftUI

struct AnimatedGradient: View {
    @State private var animateGradient = false
    
    let colors: [Color]
    let duration: Double
    
    init(colors: [Color] = [.accentCyan, .accentMagenta, .accentViolet], duration: Double = 5.0) {
        self.colors = colors
        self.duration = duration
    }
    
    var body: some View {
        LinearGradient(
            colors: colors + colors.reversed(),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .hueRotation(.degrees(animateGradient ? 45 : 0))
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct MeshGradientBackground: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // Radial gradient circles
                let gradients: [(Color, CGPoint, CGFloat)] = [
                    (.accentCyan.opacity(0.3), CGPoint(x: size.width * 0.2, y: size.height * 0.3), 300),
                    (.accentMagenta.opacity(0.3), CGPoint(x: size.width * 0.8, y: size.height * 0.2), 350),
                    (.accentViolet.opacity(0.3), CGPoint(x: size.width * 0.5, y: size.height * 0.7), 400),
                ]
                
                for (index, gradient) in gradients.enumerated() {
                    let offsetX = sin(time * 0.5 + Double(index)) * 50
                    let offsetY = cos(time * 0.3 + Double(index)) * 30
                    
                    let center = CGPoint(
                        x: gradient.1.x + offsetX,
                        y: gradient.1.y + offsetY
                    )
                    
                    let radialGradient = Gradient(colors: [gradient.0, .clear])
                    
                    context.fill(
                        Circle().path(in: CGRect(
                            x: center.x - gradient.2,
                            y: center.y - gradient.2,
                            width: gradient.2 * 2,
                            height: gradient.2 * 2
                        )),
                        with: .radialGradient(
                            radialGradient,
                            center: center,
                            startRadius: 0,
                            endRadius: gradient.2
                        )
                    )
                }
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

#Preview {
    MeshGradientBackground()
}
