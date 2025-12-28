import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let trend: Trend?
    
    enum Trend {
        case up(String)
        case down(String)
        case neutral
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var text: String {
            switch self {
            case .up(let value), .down(let value): return value
            case .neutral: return ""
            }
        }
    }
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = .accentCyan,
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .frame(width: 36, height: 36)
                        .background(iconColor.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.caption)
                            Text(trend.text)
                                .font(.caption)
                        }
                        .foregroundStyle(trend.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(trend.color.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
        }
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial.opacity(0.5))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 16) {
            StatCard(
                title: "Ganancias Totales",
                value: "€47.82",
                subtitle: "Desde hace 30 días",
                icon: "dollarsign.circle.fill",
                iconColor: .accentGreen,
                trend: .up("+12%")
            )
            
            HStack(spacing: 12) {
                MiniStatCard(title: "Tareas", value: "243", icon: "checkmark.circle", color: .accentCyan)
                MiniStatCard(title: "Horas", value: "87h", icon: "clock", color: .accentMagenta)
            }
        }
        .padding()
    }
}
