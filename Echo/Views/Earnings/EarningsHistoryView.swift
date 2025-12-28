import SwiftUI

struct EarningsHistoryView: View {
    @StateObject private var earningsService = EarningsService.shared
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showWithdrawSheet = false
    
    enum TimePeriod: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case all = "Todo"
    }
    
    var body: some View {
        ZStack {
            MeshGradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Balance card
                    balanceCard
                    
                    // Period selector
                    periodSelector
                    
                    // Stats grid
                    statsGrid
                    
                    // Earnings chart
                    EarningsChart(data: earningsService.weeklyData)
                    
                    // Projections
                    projectionsCard
                    
                    // Transaction history
                    transactionHistory
                }
                .padding()
            }
        }
        .navigationTitle("Ganancias")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showWithdrawSheet) {
            WithdrawView()
        }
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        GlassCard {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Balance Disponible")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Text(earningsService.totalEarnings.compactCurrency)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .accentCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Button(action: { showWithdrawSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Retirar Fondos")
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.accentGreen, .accentCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!earningsService.canWithdraw)
                .opacity(earningsService.canWithdraw ? 1 : 0.5)
                
                if !earningsService.canWithdraw {
                    Text("Mínimo para retirar: \(Constants.Rewards.minimumWithdrawal.compactCurrency)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.smoothSpring) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(selectedPeriod == period ? .black : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedPeriod == period ?
                            AnyShapeStyle(Color.accentCyan) :
                            AnyShapeStyle(Color.clear)
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial.opacity(0.5))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Hoy",
                value: earningsService.todayEarnings.compactCurrency,
                icon: "sun.max.fill",
                iconColor: .accentOrange
            )
            
            StatCard(
                title: "Esta Semana",
                value: earningsService.weekEarnings.compactCurrency,
                icon: "calendar",
                iconColor: .accentCyan
            )
        }
    }
    
    // MARK: - Projections Card
    private var projectionsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(.accentViolet)
                    Text("Proyecciones")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                HStack(spacing: 20) {
                    projectionItem(
                        title: "Mensual",
                        value: earningsService.monthlyProjection.compactCurrency,
                        icon: "calendar",
                        color: .accentCyan
                    )
                    
                    Divider()
                        .frame(height: 50)
                        .background(.white.opacity(0.2))
                    
                    projectionItem(
                        title: "Anual",
                        value: earningsService.yearlyProjection.compactCurrency,
                        icon: "calendar.badge.clock",
                        color: .accentMagenta
                    )
                }
            }
        }
    }
    
    private func projectionItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Transaction History
    private var transactionHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Historial")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Ver todo") {}
                    .font(.caption)
                    .foregroundStyle(.accentCyan)
            }
            
            ForEach(0..<5) { index in
                transactionRow(
                    type: index == 2 ? "withdrawal" : "compute",
                    amount: index == 2 ? -10.0 : Double.random(in: 0.5...2.5),
                    date: Date().addingTimeInterval(-Double(index) * 86400)
                )
            }
        }
    }
    
    private func transactionRow(type: String, amount: Double, date: Date) -> some View {
        HStack(spacing: 12) {
            Image(systemName: type == "withdrawal" ? "arrow.up.circle.fill" : "cpu.fill")
                .font(.system(size: 18))
                .foregroundStyle(type == "withdrawal" ? .accentOrange : .accentCyan)
                .frame(width: 40, height: 40)
                .background((type == "withdrawal" ? Color.accentOrange : Color.accentCyan).opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(type == "withdrawal" ? "Retiro" : "Sesión de Compute")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                
                Text(date.relativeDateString)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text((amount >= 0 ? "+" : "") + amount.compactCurrency)
                .font(.subheadline.bold())
                .foregroundStyle(amount >= 0 ? .accentGreen : .accentOrange)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial.opacity(0.3))
        )
    }
}

#Preview {
    NavigationStack {
        EarningsHistoryView()
    }
}
