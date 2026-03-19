import SwiftUI
import ViewModels
import CoreCalculator

/// Extended scientific function buttons rendered to the left of the basic grid.
struct ScientificButtonGrid: View {
    @Bindable var vm: CalculatorViewModel

    private let sciButtons: [[String]] = [
        ["sin",  "cos",  "tan"],
        ["log",  "ln",   "x²"],
        ["√",    "xʸ",   "π"],
        ["e",    "(",    ")"],
        ["",     "",     ""],   // spacer row aligns with bottom of basic grid
    ]

    var body: some View {
        GeometryReader { geo in
            let cols = 3
            let rows = 5
            let pad  = CGFloat(12)
            let btnW = (geo.size.width  - pad * CGFloat(cols + 1)) / CGFloat(cols)
            let btnH = (geo.size.height - pad * CGFloat(rows + 1)) / CGFloat(rows)

            VStack(spacing: 0) {
                // DEG / RAD toggle at the top
                degRadToggle
                    .padding(.horizontal, pad)
                    .padding(.top, pad)
                    .padding(.bottom, 4)

                VStack(spacing: pad) {
                    ForEach(0..<sciButtons.count, id: \.self) { row in
                        HStack(spacing: pad) {
                            ForEach(sciButtons[row], id: \.self) { title in
                                if title.isEmpty {
                                    Spacer().frame(width: btnW, height: btnH)
                                } else {
                                    sciButton(title: title, width: btnW, height: btnH)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, pad)
                .padding(.bottom, pad)
            }
        }
    }

    private var degRadToggle: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    vm.angleMode = vm.angleMode == .degrees ? .radians : .degrees
                }
            } label: {
                Text(vm.angleMode == .degrees ? "DEG" : "RAD")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.blue.opacity(0.7)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(vm.angleMode == .degrees ? "Degrees mode" : "Radians mode")
            .accessibilityHint("Tap to switch angle unit")
            Spacer()
        }
    }

    @ViewBuilder
    private func sciButton(title: String, width: CGFloat, height: CGFloat) -> some View {
        Button {
            vm.buttonTapped(title)
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .medium))
        }
        .buttonStyle(CalculatorButtonStyle(type: .utility))
        .frame(width: width, height: height)
        .accessibilityLabel(sciLabel(for: title))
        .accessibilityHint(sciHint(for: title))
    }

    private func sciLabel(for title: String) -> String {
        switch title {
        case "sin": return "Sine"
        case "cos": return "Cosine"
        case "tan": return "Tangent"
        case "log": return "Logarithm base 10"
        case "ln":  return "Natural logarithm"
        case "x²":  return "Square"
        case "√":   return "Square root"
        case "xʸ":  return "X to the power of Y"
        case "π":   return "Pi"
        case "e":   return "Euler's number"
        default:    return title
        }
    }

    private func sciHint(for title: String) -> String {
        switch title {
        case "xʸ": return "Enter base, tap xʸ, then enter exponent, then equals"
        case "π":  return "Inserts 3.14159…"
        case "e":  return "Inserts 2.71828…"
        default:   return ""
        }
    }
}
