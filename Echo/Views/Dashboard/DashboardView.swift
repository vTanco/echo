import SwiftUI

struct DashboardView: View {
    @StateObject private var computeService = ComputeService.shared
    @StateObject private var deviceMonitor = DeviceMonitorService.shared
    @StateObject private var earningsService = EarningsService.shared
    
    @State private var showStartAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                MeshGradientBackground()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome header
                        headerSection
                        
                        // Main earnings card
                        mainEarningsCard
                        
                        // Device status
                        deviceStatusCard
                        
                        // Quick actions
                        quickActionsRow
                        
                        // Earnings chart
                        EarningsChart(data: earningsService.weeklyData)
                        
                        // Recent activity
                        recentActivitySection
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, Usuario 👋")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Profile button
            Button(action: {}) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Main Earnings Card
    private var mainEarningsCard: some View {
        GlassCard {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ganancias Totales")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(earningsService.totalEarnings.compactCurrency)
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("+\(earningsService.todayEarnings.euroCurrency) hoy")
                                .font(.caption)
                                .foregroundStyle(.accentGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.accentGreen.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    // Mini orb indicator
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        computeService.isProcessing ? .accentCyan : .gray,
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: computeService.isProcessing ? "bolt.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
                
                Divider()
                    .background(.white.opacity(0.2))
                
                // Quick stats
                HStack(spacing: 30) {
                    quickStat(title: "Este mes", value: earningsService.monthlyProjection.compactCurrency, icon: "calendar")
                    quickStat(title: "Tareas", value: "\(computeService.completedTasksCount)", icon: "checkmark.circle")
                    quickStat(title: "Horas", value: "87h", icon: "clock")
                }
            }
        }
    }
    
    private func quickStat(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.accentCyan)
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Device Status
    private var deviceStatusCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Estado del Dispositivo")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Status badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(deviceMonitor.readinessStatus.color))
                            .frame(width: 8, height: 8)
                        
                        Text(deviceMonitor.readinessStatus.message)
                            .font(.caption.bold())
                            .foregroundStyle(Color(deviceMonitor.readinessStatus.color))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(deviceMonitor.readinessStatus.color).opacity(0.2))
                    .clipShape(Capsule())
                }
                
                HStack(spacing: 16) {
                    // Battery
                    statusItem(
                        icon: deviceMonitor.isCharging ? "battery.100.bolt" : "battery.75",
                        title: "Batería",
                        value: "\(deviceMonitor.batteryLevel)%",
                        color: deviceMonitor.batteryLevel > 50 ? .accentGreen : .accentOrange
                    )
                    
                    // WiFi
                    statusItem(
                        icon: deviceMonitor.isOnWiFi ? "wifi" : "wifi.slash",
                        title: "Red",
                        value: deviceMonitor.isOnWiFi ? "WiFi" : "Datos",
                        color: deviceMonitor.isOnWiFi ? .accentCyan : .accentOrange
                    )
                    
                    // Temperature
                    statusItem(
                        icon: "thermometer.medium",
                        title: "Temp",
                        value: String(format: "%.0f°C", deviceMonitor.deviceTemperature),
                        color: deviceMonitor.deviceTemperature < 40 ? .accentGreen : .accentOrange
                    )
                    
                    // CPU
                    statusItem(
                        icon: "cpu",
                        title: "CPU",
                        value: String(format: "%.0f%%", deviceMonitor.cpuUsage),
                        color: .accentMagenta
                    )
                }
            }
        }
    }
    
    private func statusItem(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Quick Actions
    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: ComputeSessionView()) {
                actionButton(
                    icon: computeService.isProcessing ? "stop.fill" : "play.fill",
                    title: computeService.isProcessing ? "Detener" : "Iniciar",
                    color: computeService.isProcessing ? .accentOrange : .accentCyan
                )
            }
            
            NavigationLink(destination: EarningsHistoryView()) {
                actionButton(icon: "arrow.up.circle.fill", title: "Retirar", color: .accentGreen)
            }
            
            NavigationLink(destination: SettingsView()) {
                actionButton(icon: "clock.fill", title: "Programar", color: .accentMagenta)
            }
        }
    }
    
    private func actionButton(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassBackground(cornerRadius: 16)
    }
    
    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actividad Reciente")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
            
            ForEach(0..<3) { index in
                recentActivityItem(
                    type: ComputeTask.TaskType.allCases[index % ComputeTask.TaskType.allCases.count],
                    client: ComputeTask.mockClients[index].name,
                    amount: Double.random(in: 0.02...0.05),
                    time: "Hace \(index + 1)h"
                )
            }
        }
    }
    
    private func recentActivityItem(type: ComputeTask.TaskType, client: String, amount: Double, time: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(type.color))
                .frame(width: 40, height: 40)
                .background(Color(type.color).opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(type.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                
                Text(client)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(amount.euroCurrency)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.accentGreen)
                
                Text(time)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial.opacity(0.3))
        )
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
}
