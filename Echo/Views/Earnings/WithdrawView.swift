import SwiftUI

struct WithdrawView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var earningsService = EarningsService.shared
    
    @State private var withdrawAmount: String = ""
    @State private var selectedMethod: WithdrawMethod = .paypal
    @State private var showConfirmation = false
    @State private var isProcessing = false
    @State private var showSuccess = false
    
    enum WithdrawMethod: String, CaseIterable {
        case paypal = "PayPal"
        case bank = "Transferencia Bancaria"
        case crypto = "Cripto (USDC)"
        
        var icon: String {
            switch self {
            case .paypal: return "p.circle.fill"
            case .bank: return "building.columns.fill"
            case .crypto: return "bitcoinsign.circle.fill"
            }
        }
        
        var fee: String {
            switch self {
            case .paypal: return "0.5%"
            case .bank: return "Gratis"
            case .crypto: return "Gas fee"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if showSuccess {
                    successView
                } else {
                    mainContent
                }
            }
            .navigationTitle("Retirar Fondos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Balance display
                VStack(spacing: 8) {
                    Text("Disponible")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text(earningsService.totalEarnings.compactCurrency)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.top)
                
                // Amount input
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cantidad a retirar")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        
                        HStack {
                            Text("€")
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.5))
                            
                            TextField("0.00", text: $withdrawAmount)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .keyboardType(.decimalPad)
                        }
                        
                        // Quick amount buttons
                        HStack(spacing: 12) {
                            quickAmountButton("€10")
                            quickAmountButton("€25")
                            quickAmountButton("€50")
                            quickAmountButton("Máx")
                        }
                    }
                }
                
                // Withdrawal methods
                GlassCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Método de retiro")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        
                        ForEach(WithdrawMethod.allCases, id: \.self) { method in
                            methodRow(method)
                        }
                    }
                }
                
                // Summary
                if let amount = Double(withdrawAmount), amount > 0 {
                    GlassCard {
                        VStack(spacing: 12) {
                            summaryRow(title: "Cantidad", value: "€\(withdrawAmount)")
                            summaryRow(title: "Comisión (\(selectedMethod.fee))", value: "-€0.05")
                            
                            Divider()
                                .background(.white.opacity(0.2))
                            
                            HStack {
                                Text("Total a recibir")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("€\(String(format: "%.2f", amount - 0.05))")
                                    .font(.headline)
                                    .foregroundStyle(.accentGreen)
                            }
                        }
                    }
                }
                
                // Withdraw button
                Button(action: processWithdrawal) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Confirmar Retiro")
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.accentGreen, .accentCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(Double(withdrawAmount) ?? 0 < Constants.Rewards.minimumWithdrawal || isProcessing)
                .opacity((Double(withdrawAmount) ?? 0 < Constants.Rewards.minimumWithdrawal) ? 0.5 : 1)
                
                Text("Mínimo de retiro: \(Constants.Rewards.minimumWithdrawal.compactCurrency)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding()
        }
    }
    
    private func quickAmountButton(_ text: String) -> some View {
        Button(action: {
            if text == "Máx" {
                withdrawAmount = String(format: "%.2f", earningsService.totalEarnings)
            } else {
                withdrawAmount = String(text.dropFirst())
            }
        }) {
            Text(text)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private func methodRow(_ method: WithdrawMethod) -> some View {
        Button(action: { selectedMethod = method }) {
            HStack(spacing: 12) {
                Image(systemName: method.icon)
                    .font(.title2)
                    .foregroundStyle(selectedMethod == method ? .accentCyan : .white.opacity(0.6))
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                    
                    Text("Comisión: \(method.fee)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: selectedMethod == method ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedMethod == method ? .accentCyan : .white.opacity(0.3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedMethod == method ? Color.accentCyan.opacity(0.1) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedMethod == method ? Color.accentCyan : .clear, lineWidth: 1)
                    )
            )
        }
    }
    
    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }
    
    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(.accentGreen.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.accentGreen)
            }
            
            VStack(spacing: 12) {
                Text("¡Retiro Solicitado!")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                Text("Recibirás €\(withdrawAmount) en tu cuenta de \(selectedMethod.rawValue) en 1-3 días hábiles.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button("Listo") {
                dismiss()
            }
            .font(.headline)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.accentGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding()
        }
    }
    
    // MARK: - Actions
    private func processWithdrawal() {
        isProcessing = true
        
        // Simulate processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            withAnimation(.smoothSpring) {
                showSuccess = true
            }
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

#Preview {
    WithdrawView()
}
