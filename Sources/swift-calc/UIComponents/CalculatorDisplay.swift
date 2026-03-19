import SwiftUI

struct CalculatorDisplay: View {
    let value: String

    private var fontSize: CGFloat {
        if value.count > 9 { return max(24, 48 - CGFloat(value.count - 9) * 3) }
        return 48
    }

    var body: some View {
        HStack {
            Spacer()
            Text(value)
                .font(.system(size: fontSize, weight: .light, design: .default))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .accessibilityLabel("Display")
                .accessibilityValue(value == "Error" ? "Error, press C to clear" : value)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CalculatorDisplay(value: "123456789")
        .background(.black)
}
