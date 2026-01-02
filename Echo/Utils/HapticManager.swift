import SwiftUI
import UIKit

/// Centralized manager for haptic feedback throughout the app
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func lightImpact() {
        impact(.light)
    }
    
    func mediumImpact() {
        impact(.medium)
    }
    
    func heavyImpact() {
        impact(.heavy)
    }
    
    func softImpact() {
        impact(.soft)
    }
    
    func rigidImpact() {
        impact(.rigid)
    }
    
    // MARK: - Notification Feedback
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func success() {
        notification(.success)
    }
    
    func warning() {
        notification(.warning)
    }
    
    func error() {
        notification(.error)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Custom Patterns
    
    func sessionStart() {
        // Double impact for session start
        impact(.heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact(.medium)
        }
    }
    
    func sessionStop() {
        // Soft descending pattern
        impact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.impact(.light)
        }
    }
    
    func taskComplete() {
        success()
    }
    
    func earning() {
        // Quick double tap for earnings
        impact(.soft)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.success()
        }
    }
    
    func buttonTap() {
        impact(.light)
    }
    
    func tabChange() {
        selection()
    }
}

// MARK: - SwiftUI View Modifier

struct HapticModifier: ViewModifier {
    let type: HapticType
    
    enum HapticType {
        case light, medium, heavy, success, error, warning, selection
    }
    
    func body(content: Content) -> some View {
        content.onTapGesture {
            switch type {
            case .light: HapticManager.shared.lightImpact()
            case .medium: HapticManager.shared.mediumImpact()
            case .heavy: HapticManager.shared.heavyImpact()
            case .success: HapticManager.shared.success()
            case .error: HapticManager.shared.error()
            case .warning: HapticManager.shared.warning()
            case .selection: HapticManager.shared.selection()
            }
        }
    }
}

extension View {
    func hapticFeedback(_ type: HapticModifier.HapticType = .light) -> some View {
        modifier(HapticModifier(type: type))
    }
}
