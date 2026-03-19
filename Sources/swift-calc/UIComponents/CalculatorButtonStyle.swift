import SwiftUI

enum CalcButtonType {
    case utility    // C ± %
    case digit      // 0-9 .
    case `operator` // ÷ × − +
    case equals     // =
}

struct CalculatorButtonStyle: ButtonStyle {
    let type: CalcButtonType
    @Environment(\.colorScheme) private var colorScheme

    private var bgColor: Color {
        switch type {
        case .utility:
            return colorScheme == .dark ? Color(white: 0.50) : Color(white: 0.75)
        case .digit:
            return colorScheme == .dark ? Color(white: 0.20) : Color(white: 0.40)
        case .operator, .equals:
            return .orange
        }
    }

    private var fgColor: Color {
        switch type {
        case .utility:
            return colorScheme == .dark ? .white : .black
        default:
            return .white
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(fgColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Circle().fill(bgColor.opacity(configuration.isPressed ? 0.6 : 1.0))
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.05), value: configuration.isPressed)
    }
}
