import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var email: String
    var displayName: String
    var totalEarnings: Double
    var totalComputeHours: Double
    var totalTasksCompleted: Int
    var createdAt: Date
    var walletAddress: String?
    
    // Preferences
    var autoStartEnabled: Bool
    var minBatteryLevel: Int
    var onlyOnWiFi: Bool
    var scheduleStart: Date
    var scheduleEnd: Date
    
    init(
        id: UUID = UUID(),
        email: String = "",
        displayName: String = "Usuario",
        totalEarnings: Double = 0.0,
        totalComputeHours: Double = 0.0,
        totalTasksCompleted: Int = 0,
        createdAt: Date = Date(),
        walletAddress: String? = nil,
        autoStartEnabled: Bool = true,
        minBatteryLevel: Int = 80,
        onlyOnWiFi: Bool = true,
        scheduleStart: Date = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date(),
        scheduleEnd: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.totalEarnings = totalEarnings
        self.totalComputeHours = totalComputeHours
        self.totalTasksCompleted = totalTasksCompleted
        self.createdAt = createdAt
        self.walletAddress = walletAddress
        self.autoStartEnabled = autoStartEnabled
        self.minBatteryLevel = minBatteryLevel
        self.onlyOnWiFi = onlyOnWiFi
        self.scheduleStart = scheduleStart
        self.scheduleEnd = scheduleEnd
    }
}
