import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "cpu.fill",
            title: "Tu móvil, un superordenador",
            description: "Tu smartphone tiene un procesador potente que pasa horas sin uso mientras duermes. Echo lo pone a trabajar.",
            color: .accentCyan
        ),
        OnboardingPage(
            icon: "moon.stars.fill",
            title: "Computa mientras duermes",
            description: "Conecta tu móvil a cargar por la noche y Echo utilizará tu CPU/GPU para tareas de IA, renderizado 3D e investigación científica.",
            color: .accentMagenta
        ),
        OnboardingPage(
            icon: "dollarsign.circle.fill",
            title: "Gana dinero pasivamente",
            description: "Por cada tarea completada, recibes micropagos que se acumulan. Sin esfuerzo, monetiza un activo que ya posees.",
            color: .accentGreen
        ),
        OnboardingPage(
            icon: "globe.europe.africa.fill",
            title: "Descentraliza la nube",
            description: "Forma parte de una red global de computación distribuida. Menos dependencia de mega-servidores, más poder para las personas.",
            color: .accentViolet
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            MeshGradientBackground()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Saltar") {
                            withAnimation(.smoothSpring) {
                                currentPage = pages.count - 1
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding()
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], isAnimating: isAnimating)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicators and button
                VStack(spacing: 30) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pages[index].color : .white.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.smoothSpring, value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button(action: handleAction) {
                        HStack(spacing: 12) {
                            Text(currentPage == pages.count - 1 ? "Comenzar" : "Siguiente")
                                .font(.headline)
                            
                            Image(systemName: currentPage == pages.count - 1 ? "arrow.right" : "chevron.right")
                                .font(.headline)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: pages[currentPage].color.opacity(0.5), radius: 20, y: 10)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private func handleAction() {
        if currentPage < pages.count - 1 {
            withAnimation(.smoothSpring) {
                currentPage += 1
            }
        } else {
            withAnimation(.smoothSpring) {
                appState.completeOnboarding()
            }
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isAnimating: Bool
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = -30
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                
                // Icon container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [page.color.opacity(0.3), page.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [page.color, .white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: page.color, radius: 20)
                }
                .scaleEffect(iconScale)
                .rotationEffect(.degrees(iconRotation))
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 30)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                iconScale = 1.0
                iconRotation = 0
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
