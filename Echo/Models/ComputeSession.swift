import Foundation
import SwiftData

@Model
final class ComputeSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var tasksCompleted: Int
    var earnings: Double
    var computeHours: Double
    var status: String // "active", "completed", "cancelled"
    
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        tasksCompleted: Int = 0,
        earnings: Double = 0.0,
        computeHours: Double = 0.0,
        status: String = "active"
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.tasksCompleted = tasksCompleted
        self.earnings = earnings
        self.computeHours = computeHours
        self.status = status
    }
    
    var isActive: Bool {
        status == "active"
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return String(format: "%dh %02dm", hours, minutes)
    }
}
