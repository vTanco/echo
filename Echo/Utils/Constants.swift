import Foundation

struct Constants {
    // MARK: - App Info
    static let appName = "Echo"
    static let appVersion = "1.0.0"
    static let supportEmail = "support@echo-compute.io"
    
    // MARK: - Compute Rewards
    struct Rewards {
        static let baseRatePerHour: Double = 0.12 // €0.12 per hour base
        static let bonusMultiplierNight: Double = 1.5 // 50% bonus for night computing
        static let referralBonus: Double = 5.0 // €5 per successful referral
        static let minimumWithdrawal: Double = 10.0 // €10 minimum to withdraw
    }
    
    // MARK: - Device Requirements
    struct DeviceRequirements {
        static let minimumBatteryLevel: Int = 20
        static let recommendedBatteryLevel: Int = 80
        static let optimalTemperature: Double = 35.0 // Celsius
        static let maxTemperature: Double = 45.0
    }
    
    // MARK: - Task Simulation
    struct TaskSimulation {
        static let taskCompletionTimeMin: TimeInterval = 30 // 30 seconds minimum
        static let taskCompletionTimeMax: TimeInterval = 180 // 3 minutes maximum
        static let taskSpawnInterval: TimeInterval = 45 // New task every 45 seconds
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 20
        static let smallCornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 16
        static let screenPadding: CGFloat = 20
        static let iconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 48
    }
    
    // MARK: - Animation Durations
    struct Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.35
        static let slow: Double = 0.5
        static let pulseDuration: Double = 2.0
    }
}
