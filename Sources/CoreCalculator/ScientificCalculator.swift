import Foundation
import Utilities

public enum AngleMode {
    case degrees
    case radians
}

public final class ScientificCalculator: CalculatorEngine {
    private let basic = BasicCalculator()

    // Used for forward trig functions (sin/cos/tan).
    var angleMode: AngleMode = .degrees

    private var waitingForPowerExponent: Bool = false
    private var powerBase: Double = 0

    public init() {}

    public func process(_ input: String) -> String {
        // Handle the multi-step `xʸ` (base first, exponent later).
        if waitingForPowerExponent {
            if input == "=" {
                waitingForPowerExponent = false
                guard let exp = basic.evaluate() else { return "Error" }
                let result = pow(powerBase, exp)
                guard result.isFinite, !result.isNaN else { return "Error" }
                basic.overwriteStateAfterPower(result)
                return result.displayString
            }

            // Allow exponent entry to proceed; if a non-numeric token arrives, cancel the power flow.
            if input == "." || (input.count == 1 && input.first?.isNumber == true) {
                return basic.process(input)
            } else {
                waitingForPowerExponent = false
                powerBase = 0
            }
        }

        switch input {
        case "C":
            waitingForPowerExponent = false
            powerBase = 0
            return basic.process(input)

        // Trig
        case "sin":
            return applyUnary(convertAngles: true) { Foundation.sin($0) }
        case "cos":
            return applyUnary(convertAngles: true) { Foundation.cos($0) }
        case "tan":
            return applyUnary(convertAngles: true) { Foundation.tan($0) }

        // Logs
        case "log":
            return applyUnary(convertAngles: false) { Foundation.log10($0) }
        case "ln":
            return applyUnary(convertAngles: false) { Foundation.log($0) }

        // Power/roots
        case "x²":
            return applyUnary(convertAngles: false) { $0 * $0 }
        case "√":
            return applyUnary(convertAngles: false) { Foundation.sqrt($0) }
        case "xʸ":
            waitingForPowerExponent = true
            if let base = basic.evaluate() {
                powerBase = base
                // Keep the display as the base and ensure the next digit replaces it.
                basic.overwriteDisplayValue(base)
                return base.displayString
            } else {
                waitingForPowerExponent = false
                powerBase = 0
                return "Error"
            }

        // Constants
        case "π":
            let pi = Double.pi
            basic.overwriteDisplayValue(pi)
            return pi.displayString
        case "e":
            let e = M_E
            basic.overwriteDisplayValue(e)
            return Double(e).displayString

        // Delegate everything else (digits/operators/=/./%/±/etc) to BasicCalculator.
        default:
            return basic.process(input)
        }
    }

    public func evaluate() -> Double? {
        basic.evaluate()
    }

    public func reset() {
        waitingForPowerExponent = false
        powerBase = 0
        basic.reset()
    }

    private func applyUnary(convertAngles: Bool, _ transform: (Double) -> Double) -> String {
        guard let value = basic.evaluate() else { return "Error" }

        let input: Double
        if convertAngles {
            switch angleMode {
            case .degrees:
                input = value * .pi / 180
            case .radians:
                input = value
            }
        } else {
            input = value
        }

        let result = transform(input)
        guard result.isFinite, !result.isNaN else { return "Error" }

        basic.overwriteDisplayValue(result)
        return result.displayString
    }
}

