import Foundation
import SwiftData
import Combine

class EarningsService: ObservableObject {
    static let shared = EarningsService()
    
    @Published var totalEarnings: Double = 0.0
    @Published var todayEarnings: Double = 0.0
    @Published var weekEarnings: Double = 0.0
    @Published var pendingWithdrawal: Double = 0.0
    @Published var weeklyData: [DailyEarning] = []
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Data Loading
    private func loadMockData() {
        // Simulate historical earnings
        totalEarnings = Double.random(in: 25...75)
        todayEarnings = Double.random(in: 0.5...3.0)
        weekEarnings = Double.random(in: 8...20)
        pendingWithdrawal = 0.0
        
        // Generate weekly data
        weeklyData = generateWeeklyData()
    }
    
    private func generateWeeklyData() -> [DailyEarning] {
        let calendar = Calendar.current
        var data: [DailyEarning] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            
            let earning = DailyEarning(
                date: date,
                amount: Double.random(in: 0.8...3.5),
                hoursComputed: Double.random(in: 5...8),
                tasksCompleted: Int.random(in: 50...150)
            )
            data.append(earning)
        }
        
        return data
    }
    
    // MARK: - Earnings Management
    func addEarnings(_ amount: Double) {
        totalEarnings += amount
        todayEarnings += amount
        weekEarnings += amount
    }
    
    func requestWithdrawal(amount: Double) -> Bool {
        guard amount <= totalEarnings else { return false }
        guard amount >= Constants.Rewards.minimumWithdrawal else { return false }
        
        pendingWithdrawal = amount
        totalEarnings -= amount
        
        return true
    }
    
    // MARK: - Projections
    var monthlyProjection: Double {
        let dailyAverage = weekEarnings / 7.0
        return dailyAverage * 30
    }
    
    var yearlyProjection: Double {
        monthlyProjection * 12
    }
    
    var canWithdraw: Bool {
        totalEarnings >= Constants.Rewards.minimumWithdrawal
    }
}

struct DailyEarning: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let hoursComputed: Double
    let tasksCompleted: Int
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}
