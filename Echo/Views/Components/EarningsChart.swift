import SwiftUI
import Charts

struct EarningsChart: View {
    let data: [DailyEarning]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ganancias - Últimos 7 días")
                .font(.headline)
                .foregroundStyle(.white)
            
            Chart(data) { earning in
                BarMark(
                    x: .value("Día", earning.dayName),
                    y: .value("Cantidad", earning.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentCyan, .accentMagenta],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("€\(amount, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                        .foregroundStyle(.white.opacity(0.1))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(height: 180)
            
            // Summary
            HStack {
                VStack(alignment: .leading) {
                    Text("Total semana")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text(data.reduce(0) { $0 + $1.amount }.compactCurrency)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Promedio diario")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Text((data.reduce(0) { $0 + $1.amount } / Double(data.count)).compactCurrency)
                        .font(.title3.bold())
                        .foregroundStyle(.accentCyan)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .glassBackground()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        EarningsChart(data: [
            DailyEarning(date: Date(), amount: 2.5, hoursComputed: 6, tasksCompleted: 100),
            DailyEarning(date: Date().addingTimeInterval(-86400), amount: 3.2, hoursComputed: 7, tasksCompleted: 120),
            DailyEarning(date: Date().addingTimeInterval(-172800), amount: 1.8, hoursComputed: 5, tasksCompleted: 80),
            DailyEarning(date: Date().addingTimeInterval(-259200), amount: 2.9, hoursComputed: 6.5, tasksCompleted: 110),
            DailyEarning(date: Date().addingTimeInterval(-345600), amount: 2.1, hoursComputed: 5.5, tasksCompleted: 90),
            DailyEarning(date: Date().addingTimeInterval(-432000), amount: 3.5, hoursComputed: 8, tasksCompleted: 140),
            DailyEarning(date: Date().addingTimeInterval(-518400), amount: 2.7, hoursComputed: 6, tasksCompleted: 105),
        ])
        .padding()
    }
}
