import Foundation
import UIKit
import Combine

class DeviceMonitorService: ObservableObject {
    static let shared = DeviceMonitorService()
    
    @Published var batteryLevel: Int = 100
    @Published var isCharging: Bool = false
    @Published var isOnWiFi: Bool = true
    @Published var deviceTemperature: Double = 32.0
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    
    private var monitorTimer: Timer?
    
    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryStatus()
        startMonitoring()
    }
    
    // MARK: - Monitoring
    func startMonitoring() {
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateAllMetrics()
        }
        updateAllMetrics()
    }
    
    func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    private func updateAllMetrics() {
        updateBatteryStatus()
        updateNetworkStatus()
        updateSystemMetrics()
    }
    
    private func updateBatteryStatus() {
        let level = UIDevice.current.batteryLevel
        batteryLevel = level >= 0 ? Int(level * 100) : 100
        
        switch UIDevice.current.batteryState {
        case .charging, .full:
            isCharging = true
        default:
            isCharging = false
        }
    }
    
    private func updateNetworkStatus() {
        // Simulate WiFi detection (in production, use NWPathMonitor)
        isOnWiFi = true
    }
    
    private func updateSystemMetrics() {
        // Simulate CPU and memory usage
        if ComputeService.shared.isProcessing {
            cpuUsage = Double.random(in: 25...45)
            memoryUsage = Double.random(in: 30...50)
            deviceTemperature = Double.random(in: 35...42)
        } else {
            cpuUsage = Double.random(in: 5...15)
            memoryUsage = Double.random(in: 20...30)
            deviceTemperature = Double.random(in: 28...35)
        }
    }
    
    // MARK: - Readiness Check
    var isReadyForCompute: Bool {
        batteryLevel >= Constants.DeviceRequirements.minimumBatteryLevel &&
        deviceTemperature < Constants.DeviceRequirements.maxTemperature
    }
    
    var isOptimalForCompute: Bool {
        isCharging &&
        batteryLevel >= Constants.DeviceRequirements.recommendedBatteryLevel &&
        isOnWiFi &&
        deviceTemperature < Constants.DeviceRequirements.optimalTemperature
    }
    
    var readinessStatus: ReadinessStatus {
        if !isReadyForCompute {
            if batteryLevel < Constants.DeviceRequirements.minimumBatteryLevel {
                return .batteryLow
            }
            if deviceTemperature >= Constants.DeviceRequirements.maxTemperature {
                return .overheating
            }
            return .notReady
        }
        
        if isOptimalForCompute {
            return .optimal
        }
        
        return .ready
    }
    
    enum ReadinessStatus {
        case optimal
        case ready
        case batteryLow
        case overheating
        case notReady
        
        var message: String {
            switch self {
            case .optimal: return "Condiciones óptimas"
            case .ready: return "Listo para computar"
            case .batteryLow: return "Batería baja"
            case .overheating: return "Dispositivo caliente"
            case .notReady: return "No disponible"
            }
        }
        
        var icon: String {
            switch self {
            case .optimal: return "checkmark.circle.fill"
            case .ready: return "checkmark.circle"
            case .batteryLow: return "battery.25"
            case .overheating: return "thermometer.sun.fill"
            case .notReady: return "xmark.circle"
            }
        }
        
        var color: String {
            switch self {
            case .optimal: return "AccentGreen"
            case .ready: return "AccentCyan"
            case .batteryLow, .overheating, .notReady: return "AccentOrange"
            }
        }
    }
}
