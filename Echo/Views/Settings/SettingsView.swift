import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var deviceMonitor = DeviceMonitorService.shared
    
    @AppStorage("autoStartEnabled") private var autoStartEnabled = true
    @AppStorage("minBatteryLevel") private var minBatteryLevel = 80.0
    @AppStorage("onlyOnWiFi") private var onlyOnWiFi = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @State private var scheduleStart = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
    @State private var scheduleEnd = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    
    var body: some View {
        ZStack {
            MeshGradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Schedule section
                    scheduleSection
                    
                    // Compute settings
                    computeSettingsSection
                    
                    // Notifications
                    notificationsSection
                    
                    // Account
                    accountSection
                    
                    // About
                    aboutSection
                }
                .padding()
            }
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Schedule Section
    private var scheduleSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.accentMagenta)
                    Text("Programación")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                Toggle(isOn: $autoStartEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Inicio automático")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text("Iniciar sesión automáticamente cuando el dispositivo esté cargando")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .tint(.accentCyan)
                
                if autoStartEnabled {
                    Divider()
                        .background(.white.opacity(0.2))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Desde")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            DatePicker("", selection: $scheduleStart, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.white.opacity(0.5))
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Hasta")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            DatePicker("", selection: $scheduleEnd, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Compute Settings
    private var computeSettingsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "cpu.fill")
                        .foregroundStyle(.accentCyan)
                    Text("Configuración de Compute")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                // Battery threshold
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Nivel mínimo de batería")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(minBatteryLevel))%")
                            .font(.subheadline.bold())
                            .foregroundStyle(.accentCyan)
                    }
                    
                    Slider(value: $minBatteryLevel, in: 20...100, step: 5)
                        .tint(.accentCyan)
                }
                
                Divider()
                    .background(.white.opacity(0.2))
                
                Toggle(isOn: $onlyOnWiFi) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Solo con WiFi")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text("Computar solo cuando esté conectado a WiFi")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .tint(.accentCyan)
            }
        }
    }
    
    // MARK: - Notifications
    private var notificationsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.accentOrange)
                    Text("Notificaciones")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                Toggle(isOn: $notificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activar notificaciones")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text("Recibir alertas de ganancias y sesiones")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .tint(.accentCyan)
            }
        }
    }
    
    // MARK: - Account
    private var accountSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.accentViolet)
                    Text("Cuenta")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                settingsRow(icon: "envelope", title: "Email", value: "usuario@email.com")
                settingsRow(icon: "wallet.pass", title: "Método de pago", value: "PayPal")
                settingsRow(icon: "link", title: "Código de referido", value: "ECHO2024")
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar sesión")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.red)
                }
            }
        }
    }
    
    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - About
    private var aboutSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.accentGreen)
                    Text("Acerca de")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                settingsRow(icon: "doc.text", title: "Términos de servicio", value: "")
                settingsRow(icon: "lock.shield", title: "Política de privacidad", value: "")
                settingsRow(icon: "questionmark.circle", title: "Centro de ayuda", value: "")
                
                Divider()
                    .background(.white.opacity(0.2))
                
                HStack {
                    Text("Versión")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text(Constants.appVersion)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
