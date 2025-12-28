import SwiftUI

struct ComputeSessionView: View {
    @StateObject private var computeService = ComputeService.shared
    @StateObject private var deviceMonitor = DeviceMonitorService.shared
    @EnvironmentObject var appState: AppState
    
    @State private var showStartConfirmation = false
    
    var body: some View {
        ZStack {
            // Background
            MeshGradientBackground()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Main orb
                    orbSection
                    
                    // Session stats
                    if computeService.isProcessing {
                        sessionStatsCard
                    }
                    
                    // Active tasks
                    if !computeService.currentTasks.isEmpty {
                        activeTasksSection
                    }
                    
                    // Control button
                    controlButton
                    
                    // Info section
                    if !computeService.isProcessing {
                        infoSection
                    }
                }
                .padding()
                .padding(.top, 40)
            }
        }
        .navigationTitle("Compute")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Orb Section
    private var orbSection: some View {
        VStack(spacing: 20) {
            PulsingOrb(
                isActive: computeService.isProcessing,
                size: 180,
                primaryColor: computeService.isProcessing ? .accentCyan : .gray,
                secondaryColor: computeService.isProcessing ? .accentMagenta : .gray.opacity(0.5)
            )
            .frame(height: 280)
            
            VStack(spacing: 8) {
                Text(computeService.isProcessing ? "Procesando..." : "Inactivo")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                Text(computeService.isProcessing ? 
                     "Tu dispositivo está contribuyendo a la red" : 
                     "Presiona iniciar para comenzar a computar")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Session Stats
    private var sessionStatsCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Sesión Actual")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Live indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(.red, lineWidth: 2)
                                    .scaleEffect(1.5)
                                    .opacity(0.5)
                            )
                        
                        Text("EN VIVO")
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                    }
                }
                
                HStack(spacing: 20) {
                    sessionStat(
                        value: computeService.sessionEarnings.euroCurrency,
                        label: "Ganado",
                        icon: "dollarsign.circle",
                        color: .accentGreen
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(.white.opacity(0.2))
                    
                    sessionStat(
                        value: "\(computeService.completedTasksCount)",
                        label: "Tareas",
                        icon: "checkmark.circle",
                        color: .accentCyan
                    )
                    
                    Divider()
                        .frame(height: 40)
                        .background(.white.opacity(0.2))
                    
                    sessionStat(
                        value: "\(computeService.currentTasks.count)",
                        label: "Activas",
                        icon: "bolt.circle",
                        color: .accentMagenta
                    )
                }
            }
        }
    }
    
    private func sessionStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Active Tasks
    private var activeTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tareas Activas")
                .font(.headline)
                .foregroundStyle(.white)
            
            ForEach(computeService.currentTasks) { task in
                taskCard(task)
            }
        }
    }
    
    private func taskCard(_ task: ComputeTask) -> some View {
        GlassCard(padding: 12) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: task.type.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(task.type.color))
                        .frame(width: 32, height: 32)
                        .background(Color(task.type.color).opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.type.rawValue)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                        
                        Text(task.clientName)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text(task.formattedReward)
                        .font(.subheadline.bold())
                        .foregroundStyle(.accentGreen)
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Text("\(Int(task.progress * 100))%")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(task.type.color), Color(task.type.color).opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * task.progress, height: 6)
                                .animation(.linear(duration: 0.3), value: task.progress)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
    }
    
    // MARK: - Control Button
    private var controlButton: some View {
        Button(action: toggleSession) {
            HStack(spacing: 12) {
                Image(systemName: computeService.isProcessing ? "stop.fill" : "play.fill")
                    .font(.title2)
                
                Text(computeService.isProcessing ? "Detener Sesión" : "Iniciar Sesión")
                    .font(.headline)
            }
            .foregroundStyle(computeService.isProcessing ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Group {
                    if computeService.isProcessing {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.accentOrange, .accentMagenta],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.accentCyan, .accentMagenta],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            )
            .shadow(color: (computeService.isProcessing ? .accentOrange : .accentCyan).opacity(0.4), radius: 20, y: 10)
        }
        .disabled(!deviceMonitor.isReadyForCompute && !computeService.isProcessing)
        .opacity((!deviceMonitor.isReadyForCompute && !computeService.isProcessing) ? 0.5 : 1)
        .padding(.top, 10)
    }
    
    // MARK: - Info Section
    private var infoSection: some View {
        VStack(spacing: 16) {
            // Requirements
            GlassCard(padding: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.accentCyan)
                        Text("Requisitos para computar")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        requirementRow(met: deviceMonitor.batteryLevel >= 20, text: "Batería al menos 20%")
                        requirementRow(met: deviceMonitor.isCharging, text: "Conectado a carga (recomendado)")
                        requirementRow(met: deviceMonitor.isOnWiFi, text: "Conectado a WiFi")
                        requirementRow(met: deviceMonitor.deviceTemperature < 45, text: "Temperatura normal")
                    }
                }
            }
            
            // Tip
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.accentOrange)
                
                Text("Tip: Deja Echo ejecutándose toda la noche mientras cargas para maximizar tus ganancias.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.accentOrange.opacity(0.1))
            )
        }
    }
    
    private func requirementRow(met: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(met ? .accentGreen : .white.opacity(0.4))
                .font(.system(size: 14))
            
            Text(text)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
    
    // MARK: - Actions
    private func toggleSession() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        if computeService.isProcessing {
            computeService.stopSession()
            appState.isComputeSessionActive = false
        } else {
            computeService.startSession()
            appState.isComputeSessionActive = true
        }
    }
}

#Preview {
    NavigationStack {
        ComputeSessionView()
            .environmentObject(AppState())
    }
}
