import Foundation
import Utilities

public final class BasicCalculator: CalculatorEngine {
    // MARK: - CalculatorEngine state

    private var displayValue: String = "0"
    private var accumulator: Double = 0
    private var pendingOperator: PendingOperator?
    private var shouldResetDisplay: Bool = false
    private var hasDecimal: Bool = false

    public init() {}

    // MARK: - CalculatorEngine

    public func process(_ input: String) -> String {
        switch input {
        case "C":
            reset()
        case "±":
            toggleSign()
        case "%":
            applyPercent()
        case "÷", "/":
            applyPendingOperator()
            accumulator = currentDouble
            pendingOperator = .divide
            shouldResetDisplay = true
        case "×", "*":
            applyPendingOperator()
            accumulator = currentDouble
            pendingOperator = .multiply
            shouldResetDisplay = true
        case "−", "-":
            applyPendingOperator()
            accumulator = currentDouble
            pendingOperator = .subtract
            shouldResetDisplay = true
        case "+":
            applyPendingOperator()
            accumulator = currentDouble
            pendingOperator = .add
            shouldResetDisplay = true
        case "=":
            applyPendingOperator()
            pendingOperator = nil
        case ".":
            appendDecimal()
        default:
            appendDigit(input)
        }

        return displayValue
    }

    public func evaluate() -> Double? {
        guard displayValue != "Error" else { return nil }
        return currentDouble
    }

    public func reset() {
        displayValue = "0"
        accumulator = 0
        pendingOperator = nil
        shouldResetDisplay = false
        hasDecimal = false
    }

    // MARK: - Helpers for ScientificCalculator

    /// Updates the visible display and numeric state for unary scientific operations.
    /// This intentionally does *not* modify `accumulator`/`pendingOperator`, so chained
    /// operators still behave like a real calculator.
    func overwriteDisplayValue(_ newValue: Double) {
        displayValue = newValue.displayString
        shouldResetDisplay = true
        hasDecimal = displayValue.contains(".")
    }

    /// Overwrites the entire computation state (used when finalizing multi-step operations like `xʸ`).
    func overwriteStateAfterPower(_ result: Double) {
        displayValue = result.displayString
        accumulator = result
        pendingOperator = nil
        shouldResetDisplay = true
        hasDecimal = displayValue.contains(".")
    }

    // MARK: - Internals

    private enum PendingOperator {
        case add, subtract, multiply, divide
    }

    private var currentDouble: Double {
        Double(displayValue) ?? 0
    }

    private func appendDigit(_ digit: String) {
        // This engine is designed for single-character digits; if a longer numeric token
        // gets passed, we still append it safely as a "digit blob".
        if shouldResetDisplay {
            displayValue = digit
            shouldResetDisplay = false
            hasDecimal = digit.contains(".")
        } else {
            displayValue = (displayValue == "0") ? digit : (displayValue + digit)
            hasDecimal = displayValue.contains(".")
        }

        // Cap display at a reasonable length to prevent pathological growth in tests.
        if displayValue.filter(\.isNumber).count > 18 {
            displayValue = String(displayValue.prefix(18))
        }
    }

    private func appendDecimal() {
        guard !hasDecimal else { return }
        if shouldResetDisplay {
            displayValue = "0"
            shouldResetDisplay = false
        }
        displayValue += "."
        hasDecimal = true
    }

    private func toggleSign() {
        guard displayValue != "0", displayValue != "Error" else { return }
        if displayValue.hasPrefix("-") {
            displayValue.removeFirst()
        } else {
            displayValue = "-" + displayValue
        }
    }

    private func applyPercent() {
        guard let value = Double(displayValue) else { return }
        overwriteDisplayValue(value / 100)
    }

    private func applyPendingOperator() {
        guard let op = pendingOperator else {
            accumulator = currentDouble
            return
        }

        let rhs = currentDouble
        let lhs = accumulator
        let result: Double

        switch op {
        case .add:
            result = lhs + rhs
        case .subtract:
            result = lhs - rhs
        case .multiply:
            result = lhs * rhs
        case .divide:
            guard rhs != 0 else {
                displayValue = "Error"
                return
            }
            result = lhs / rhs
        }

        accumulator = result
        displayValue = result.displayString
        shouldResetDisplay = true
        hasDecimal = displayValue.contains(".")
    }
}

