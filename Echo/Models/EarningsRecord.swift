import Foundation
import SwiftData

@Model
final class EarningsRecord {
    var id: UUID
    var amount: Double
    var date: Date
    var type: String // "compute", "bonus", "referral", "withdrawal"
    var sessionId: UUID?
    var notes: String?
    
    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = Date(),
        type: String = "compute",
        sessionId: UUID? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.type = type
        self.sessionId = sessionId
        self.notes = notes
    }
    
    var isWithdrawal: Bool {
        type == "withdrawal"
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: amount)) ?? "€0.00"
    }
}
