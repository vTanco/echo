import SwiftUI

/// Animated loading view with pulsing orb
struct LoadingView: View {
    @State private var isAnimating = false
    var message: String = "Cargando..."
    var showMessage: Bool = true
    
    var body: some View {
        VStack(spacing: 24) {
            // Mini pulsing orb
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.accentCyan.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                
                // Main orb
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentCyan, .accentMagenta],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .accentCyan.opacity(0.5), radius: 20)
                
                // Inner core
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 20, height: 20)
                    .blur(radius: 2)
            }
            .animation(
                Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            if showMessage {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

/// Full screen loading overlay
struct LoadingOverlay: View {
    var message: String = "Cargando..."
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                LoadingView(message: message, showMessage: true)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

/// Skeleton placeholder for loading states
struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 20
    var cornerRadius: CGFloat = 8
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .shimmer()
    }
}

/// Skeleton card for loading states
struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonView(width: 40, height: 40, cornerRadius: 20)
                VStack(alignment: .leading, spacing: 6) {
                    SkeletonView(width: 120, height: 14)
                    SkeletonView(width: 80, height: 12)
                }
            }
            SkeletonView(height: 16)
            SkeletonView(width: 200, height: 14)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        VStack(spacing: 30) {
            LoadingView()
            SkeletonCard()
        }
    }
}
