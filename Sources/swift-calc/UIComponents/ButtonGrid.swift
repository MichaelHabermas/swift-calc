import SwiftUI
import ViewModels

// Standard Apple-like 4×5 button layout.
struct ButtonGrid: View {
    @Bindable var vm: CalculatorViewModel
    var onLongPressC: (() -> Void)? = nil

    private let layout: [[String]] = [
        ["C",  "±",  "%",  "÷"],
        ["7",  "8",  "9",  "×"],
        ["4",  "5",  "6",  "−"],
        ["1",  "2",  "3",  "+"],
        ["0",        ".",  "="],
    ]

    // Row 5 uses a wide zero button.
    var body: some View {
        GeometryReader { geo in
            let cols  = 4
            let rows  = 5
            let pad   = CGFloat(12)
            let btnW  = (geo.size.width  - pad * CGFloat(cols + 1)) / CGFloat(cols)
            let btnH  = (geo.size.height - pad * CGFloat(rows + 1)) / CGFloat(rows)

            VStack(spacing: pad) {
                ForEach(0..<5, id: \.self) { row in
                    if row < 4 {
                        HStack(spacing: pad) {
                            ForEach(layout[row], id: \.self) { title in
                                calcButton(title: title, width: btnW, height: btnH)
                            }
                        }
                    } else {
                        // Bottom row: wide zero
                        HStack(spacing: pad) {
                            zeroButton(width: btnW * 2 + pad, height: btnH)
                            calcButton(title: ".",  width: btnW, height: btnH)
                            calcButton(title: "=",  width: btnW, height: btnH)
                        }
                    }
                }
            }
            .padding(pad)
        }
    }

    @ViewBuilder
    private func calcButton(title: String, width: CGFloat, height: CGFloat) -> some View {
        let type = buttonType(for: title)
        Button {
            vm.buttonTapped(title)
        } label: {
            Text(title)
        }
        .buttonStyle(CalculatorButtonStyle(type: type))
        .frame(width: width, height: height)
        .accessibilityLabel(accessibilityLabel(for: title))
        .accessibilityHint(accessibilityHint(for: title))
    }

    @ViewBuilder
    private func zeroButton(width: CGFloat, height: CGFloat) -> some View {
        Button {
            vm.buttonTapped("0")
        } label: {
            HStack {
                Text("0")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.leading, 24)
                Spacer()
            }
        }
        .frame(width: width, height: height)
        .background(Capsule().fill(buttonBgColor(for: "0")))
        .scaleEffect(1.0)
        .accessibilityLabel("Zero")
        .accessibilityHint("Digit zero")
    }

    private func buttonBgColor(for title: String) -> Color {
        // Used only for the zero wide button; matches CalculatorButtonStyle digit color.
        Color(white: 0.20)
    }

    private func buttonType(for title: String) -> CalcButtonType {
        switch title {
        case "C", "±", "%": return .utility
        case "÷", "×", "−", "+": return .operator
        case "=": return .equals
        default: return .digit
        }
    }

    private func accessibilityLabel(for title: String) -> String {
        switch title {
        case "±": return "Plus minus"
        case "%": return "Percent"
        case "÷": return "Divide"
        case "×": return "Multiply"
        case "−": return "Subtract"
        case "+": return "Add"
        case "=": return "Equals"
        case "C": return "Clear"
        case ".": return "Decimal point"
        default: return title
        }
    }

    private func accessibilityHint(for title: String) -> String {
        switch title {
        case "C": return "Clears current input. Long press to clear history."
        case "=": return "Evaluates the expression"
        case "±": return "Toggles positive or negative"
        case "%": return "Converts to percentage"
        default: return ""
        }
    }
}
