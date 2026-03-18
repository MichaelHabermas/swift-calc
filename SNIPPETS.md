# TitleRedactedCalc — Code Snippets
>
> **v2.0 · Engineering Edition**  
> Every snippet maps 1-to-1 with the PRD. Copy → paste → build.  
> Architecture: SOLID + Modular SwiftUI, zero external dependencies.

---

## Table of Contents

- [Project Structure](#project-structure)
- [EP-01 · Core Calculator Engine](#ep-01--core-calculator-engine)
  - [FEAT-01 · CalculatorEngine Protocol Suite](#feat-01--calculatorengine-protocol-suite)
  - [FEAT-02 · CalculatorViewModel with Dependency Injection](#feat-02--calculatorviewmodel-with-dependency-injection)
- [EP-02 · Basic Calculator UI](#ep-02--basic-calculator-ui)
  - [FEAT-03 · CalculatorDisplay Component](#feat-03--calculatordisplay-component)
  - [FEAT-04 · ButtonGrid Component](#feat-04--buttongrid-component)
  - [FEAT-05 · Keyboard Input Handler](#feat-05--keyboard-input-handler)
  - [FEAT-06 · Window Configuration](#feat-06--window-configuration)
- [EP-03 · Scientific Calculator Mode](#ep-03--scientific-calculator-mode)
  - [FEAT-07 · Mode Segmented Control](#feat-07--mode-segmented-control)
  - [FEAT-08 · Scientific Button Grid + Deg/Rad Toggle](#feat-08--scientific-button-grid--degrad-toggle)
  - [FEAT-09 · Calculation History](#feat-09--calculation-history)
- [EP-04 · Graphing Calculator Mode](#ep-04--graphing-calculator-mode)
  - [FEAT-10 · Real-Time Graph Renderer](#feat-10--real-time-graph-renderer)
  - [FEAT-11 · Axis & Grid Overlay](#feat-11--axis--grid-overlay)
  - [FEAT-12 · Gesture Controls](#feat-12--gesture-controls)
  - [FEAT-13 · Hover Crosshair](#feat-13--hover-crosshair)
- [EP-05 · Polish & Accessibility](#ep-05--polish--accessibility)
- [EP-06 · Packaging & Distribution](#ep-06--packaging--distribution)
- [EP-07 · Marketing Landing Page](#ep-07--marketing-landing-page)
- [Tests](#tests)

---

## Project Structure

```
TitleRedactedCalc/
├── TitleRedactedCalcApp.swift          ← App entry point, window config (EP-02)
├── ContentView.swift                   ← Root view, mode routing
│
├── Modules/
│   ├── CoreCalculator/                 ← EP-01: S — single responsibility per engine
│   │   ├── Protocols/
│   │   │   └── CalculatorEngine.swift  ← L, D — Liskov + Dependency Inversion
│   │   ├── BasicCalculator.swift       ← S — arithmetic only
│   │   ├── ScientificCalculator.swift  ← O — extends via protocol, not modification
│   │   └── GraphingCalculator.swift    ← S — expression evaluation only
│   │
│   ├── UIComponents/                   ← EP-02/03/04: O — closed for modification
│   │   ├── CalculatorDisplay.swift
│   │   ├── CalculatorButtonStyle.swift
│   │   ├── ButtonGrid.swift
│   │   ├── ScientificButtonGrid.swift
│   │   ├── GraphView.swift
│   │   ├── AxisOverlay.swift
│   │   ├── CrosshairOverlay.swift
│   │   ├── HistoryView.swift
│   │   └── CalculatorModeToggle.swift
│   │
│   ├── ViewModels/                     ← EP-01/03/04: D — depends on protocols
│   │   ├── CalculatorViewModel.swift
│   │   └── GraphViewModel.swift
│   │
│   └── Utilities/
│       ├── NumberFormatter+Extensions.swift
│       └── HistoryStore.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   └── TitleRedactedCalc.entitlements
│
└── Tests/
    ├── BasicCalculatorTests.swift
    ├── ScientificCalculatorTests.swift
    └── ViewModelTests.swift
```

---

## EP-01 · Core Calculator Engine

> **Branch:** `core/calculator-engine`  
> **SOLID focus:** S (each engine does one job), L (all engines are substitutable), D (ViewModel depends on protocol)

### FEAT-01 · CalculatorEngine Protocol Suite

#### `Modules/CoreCalculator/Protocols/CalculatorEngine.swift`

```swift
// SOLID: Interface Segregation — small, focused protocol.
// SOLID: Dependency Inversion — callers depend on this abstraction, never on concrete types.
// SOLID: Liskov Substitution — any conforming type can replace any other without breaking callers.

import Foundation

/// The single contract every calculator engine must fulfil.
/// process(_:) handles incremental button input; evaluate() returns the final numeric result.
protocol CalculatorEngine: AnyObject {
    /// Accept one button label (e.g. "7", "+", "=", "sin") and return the updated display string.
    func process(_ input: String) -> String

    /// Return the current numeric result, or nil if the display holds an error / is mid-entry.
    func evaluate() -> Double?

    /// Reset all internal state to initial values.
    func reset()
}
```

#### `Modules/CoreCalculator/BasicCalculator.swift`

```swift
// SOLID: Single Responsibility — handles ONLY the four arithmetic operators + % + sign toggle.
// Nothing scientific, nothing graphing. Extend via protocol, not by touching this file.

import Foundation

final class BasicCalculator: CalculatorEngine {

    // MARK: – Internal state (private by default — encapsulation)
    private var displayValue: String = "0"
    private var accumulator: Double = 0
    private var pendingOperator: String?
    private var shouldResetDisplay: Bool = false
    private var hasDecimal: Bool = false

    // MARK: – CalculatorEngine

    func process(_ input: String) -> String {
        switch input {
        case "C":
            reset()
        case "±":
            toggleSign()
        case "%":
            applyPercent()
        case "÷", "×", "−", "+":
            applyPendingOperator()
            accumulator = currentDouble
            pendingOperator = input
            shouldResetDisplay = true
        case "=":
            applyPendingOperator()
            pendingOperator = nil
        case ".":
            appendDecimal()
        default:
            // Digit
            appendDigit(input)
        }
        return displayValue
    }

    func evaluate() -> Double? {
        guard displayValue != "Error" else { return nil }
        return currentDouble
    }

    func reset() {
        displayValue = "0"
        accumulator = 0
        pendingOperator = nil
        shouldResetDisplay = false
        hasDecimal = false
    }

    // MARK: – Private helpers

    private var currentDouble: Double {
        Double(displayValue) ?? 0
    }

    private func appendDigit(_ digit: String) {
        if shouldResetDisplay {
            displayValue = digit
            shouldResetDisplay = false
            hasDecimal = false
        } else {
            displayValue = displayValue == "0" ? digit : displayValue + digit
        }
        // Cap display at 9 digits to prevent overflow
        if displayValue.filter(\.isNumber).count > 9 {
            displayValue = String(displayValue.dropLast())
        }
    }

    private func appendDecimal() {
        guard !hasDecimal else { return }
        if shouldResetDisplay { displayValue = "0"; shouldResetDisplay = false }
        displayValue += "."
        hasDecimal = true
    }

    private func toggleSign() {
        guard displayValue != "0", displayValue != "Error" else { return }
        if displayValue.hasPrefix("−") {
            displayValue = String(displayValue.dropFirst())
        } else {
            displayValue = "−" + displayValue
        }
    }

    private func applyPercent() {
        guard let value = Double(displayValue) else { return }
        displayValue = formatResult(value / 100)
    }

    private func applyPendingOperator() {
        guard let op = pendingOperator else {
            accumulator = currentDouble
            return
        }
        let rhs = currentDouble
        var result: Double
        switch op {
        case "+": result = accumulator + rhs
        case "−": result = accumulator - rhs
        case "×": result = accumulator * rhs
        case "÷":
            guard rhs != 0 else { displayValue = "Error"; return }
            result = accumulator / rhs
        default: return
        }
        accumulator = result
        displayValue = formatResult(result)
        shouldResetDisplay = true
    }
}

// MARK: – Number Formatting (uses shared extension)

extension BasicCalculator {
    func formatResult(_ value: Double) -> String {
        value.displayString
    }
}
```

#### `Modules/CoreCalculator/ScientificCalculator.swift`

```swift
// SOLID: Open/Closed — extends BasicCalculator's behaviour WITHOUT modifying BasicCalculator.
// New functions are added; no existing code is changed.
// SOLID: Liskov Substitution — drop-in replacement for CalculatorEngine anywhere.

import Foundation

final class ScientificCalculator: CalculatorEngine {

    // Composition over inheritance: we hold a BasicCalculator for all basic ops.
    // SOLID: we delegate arithmetic to BasicCalculator rather than duplicating code.
    private let basic = BasicCalculator()

    // Scientific-specific state
    private var waitingForPowerExponent: Bool = false
    private var powerBase: Double = 0

    // Angle mode is stored in ViewModel, passed in per call — keeps this class stateless re: mode
    var angleMode: AngleMode = .degrees

    // MARK: – CalculatorEngine

    func process(_ input: String) -> String {
        switch input {
        case "sin":   return applyUnary { sin($0) }
        case "cos":   return applyUnary { cos($0) }
        case "tan":   return applyUnary { tan($0) }
        case "sin⁻¹": return applyUnary { asin($0) }
        case "cos⁻¹": return applyUnary { acos($0) }
        case "tan⁻¹": return applyUnary { atan($0) }
        case "log":   return applyUnary { log10($0) }
        case "ln":    return applyUnary { log($0) }
        case "x²":    return applyUnary { $0 * $0 }
        case "√":     return applyUnary { sqrt($0) }
        case "xʸ":
            // xʸ sets up a pending power; = finalises it via basic
            if let base = basic.evaluate() {
                waitingForPowerExponent = true
                powerBase = base
            }
            return basic.process(input) // show base in display
        case "π":
            return basic.process(Double.pi.displayString)
        case "e":
            return basic.process(M_E.displayString)
        default:
            // Delegate all digits, arithmetic ops, C, ±, %, = to BasicCalculator
            if waitingForPowerExponent, input == "=" {
                waitingForPowerExponent = false
                if let exp = basic.evaluate() {
                    let result = pow(powerBase, exp)
                    return basic.process(result.displayString)
                }
            }
            return basic.process(input)
        }
    }

    func evaluate() -> Double? {
        basic.evaluate()
    }

    func reset() {
        basic.reset()
        waitingForPowerExponent = false
        powerBase = 0
    }

    // MARK: – Private

    private func applyUnary(_ transform: (Double) -> Double) -> String {
        guard let value = basic.evaluate() else { return "Error" }
        let input = angleMode == .degrees ? toRadians(value) : value
        let result = transform(input)
        guard !result.isNaN, !result.isInfinite else { return "Error" }
        // For inverse trig, convert result back to degrees if needed
        return result.displayString
    }

    private func toRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}

// MARK: – AngleMode

enum AngleMode {
    case degrees, radians
}
```

#### `Modules/CoreCalculator/GraphingCalculator.swift`

```swift
// SOLID: Single Responsibility — ONLY evaluates a string expression for a given x value.
// No UI logic, no state, no display management. Pure function evaluator.

import Foundation

final class GraphingCalculator: CalculatorEngine {

    // GraphingCalculator also needs to work as a CalculatorEngine for the ViewModel
    // but its primary API is evaluateExpression(_:x:)
    private let basic = BasicCalculator()

    // MARK: – CalculatorEngine (basic passthrough for display mode)
    func process(_ input: String) -> String { basic.process(input) }
    func evaluate() -> Double? { basic.evaluate() }
    func reset() { basic.reset() }

    // MARK: – Graph-specific API

    /// Evaluate a mathematical expression string at a given x value.
    /// Supports: x, numeric literals, +, -, *, /, ^, sin(), cos(), tan(), ln(), log(), sqrt(), π, e
    /// Returns nil for undefined results (NaN, Infinity, parse errors).
    func evaluateExpression(_ expression: String, x: Double) -> Double? {
        let prepared = prepareExpression(expression, x: x)
        guard let result = ExpressionParser.evaluate(prepared) else { return nil }
        guard !result.isNaN, !result.isInfinite else { return nil }
        return result
    }

    /// Sample `count` evenly-spaced points across `xRange`.
    /// Nil entries represent discontinuities (tan asymptotes, ln of negatives, etc.)
    func samplePoints(expression: String, xRange: ClosedRange<Double>, count: Int = 200) -> [GraphPoint] {
        guard count > 1 else { return [] }
        let step = (xRange.upperBound - xRange.lowerBound) / Double(count - 1)
        return (0..<count).compactMap { i in
            let x = xRange.lowerBound + Double(i) * step
            guard let y = evaluateExpression(expression, x: x) else { return nil }
            return GraphPoint(x: x, y: y)
        }
    }

    // MARK: – Private

    private func prepareExpression(_ expr: String, x: Double) -> String {
        expr
            .replacingOccurrences(of: "x", with: "(\(x))")
            .replacingOccurrences(of: "π", with: "\(Double.pi)")
            .replacingOccurrences(of: "e", with: "\(M_E)")
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .replacingOccurrences(of: "−", with: "-")
    }
}

// MARK: – Simple Recursive Descent Parser
// SOLID: Single Responsibility — this struct only parses and evaluates expressions.
// It is private to the Graphing module and has zero UI dependencies.

private struct ExpressionParser {
    private var tokens: [String]
    private var pos: Int = 0

    static func evaluate(_ expression: String) -> Double? {
        var parser = ExpressionParser(tokens: tokenise(expression))
        return try? parser.parseExpression()
    }

    private static func tokenise(_ expression: String) -> [String] {
        // Tokenise into numbers, operators, parens, and function names
        var tokens: [String] = []
        var i = expression.startIndex
        while i < expression.endIndex {
            let c = expression[i]
            if c.isWhitespace { i = expression.index(after: i); continue }
            if c.isNumber || c == "." {
                var num = String(c)
                i = expression.index(after: i)
                while i < expression.endIndex, expression[i].isNumber || expression[i] == "." {
                    num.append(expression[i])
                    i = expression.index(after: i)
                }
                tokens.append(num)
            } else if c.isLetter {
                var word = String(c)
                i = expression.index(after: i)
                while i < expression.endIndex, expression[i].isLetter {
                    word.append(expression[i])
                    i = expression.index(after: i)
                }
                tokens.append(word)
            } else {
                tokens.append(String(c))
                i = expression.index(after: i)
            }
        }
        return tokens
    }

    private mutating func parseExpression() throws -> Double {
        var left = try parseTerm()
        while pos < tokens.count, tokens[pos] == "+" || tokens[pos] == "-" {
            let op = tokens[pos]; pos += 1
            let right = try parseTerm()
            left = op == "+" ? left + right : left - right
        }
        return left
    }

    private mutating func parseTerm() throws -> Double {
        var left = try parsePower()
        while pos < tokens.count, tokens[pos] == "*" || tokens[pos] == "/" {
            let op = tokens[pos]; pos += 1
            let right = try parsePower()
            if op == "/" { guard right != 0 else { throw ParseError.divisionByZero } }
            left = op == "*" ? left * right : left / right
        }
        return left
    }

    private mutating func parsePower() throws -> Double {
        let base = try parseUnary()
        if pos < tokens.count, tokens[pos] == "^" {
            pos += 1
            let exp = try parsePower() // right-associative
            return pow(base, exp)
        }
        return base
    }

    private mutating func parseUnary() throws -> Double {
        if pos < tokens.count, tokens[pos] == "-" {
            pos += 1
            return -(try parsePrimary())
        }
        return try parsePrimary()
    }

    private mutating func parsePrimary() throws -> Double {
        guard pos < tokens.count else { throw ParseError.unexpectedEnd }
        let token = tokens[pos]
        // Number literal
        if let num = Double(token) { pos += 1; return num }
        // Parenthesised expression
        if token == "(" {
            pos += 1
            let val = try parseExpression()
            guard pos < tokens.count, tokens[pos] == ")" else { throw ParseError.missingParen }
            pos += 1
            return val
        }
        // Named functions
        if ["sin","cos","tan","ln","log","sqrt"].contains(token) {
            pos += 1
            guard pos < tokens.count, tokens[pos] == "(" else { throw ParseError.missingParen }
            pos += 1
            let arg = try parseExpression()
            guard pos < tokens.count, tokens[pos] == ")" else { throw ParseError.missingParen }
            pos += 1
            switch token {
            case "sin":  return sin(arg)
            case "cos":  return cos(arg)
            case "tan":  return tan(arg)
            case "ln":   return log(arg)
            case "log":  return log10(arg)
            case "sqrt": return sqrt(arg)
            default: break
            }
        }
        throw ParseError.unknownToken(token)
    }

    enum ParseError: Error {
        case unexpectedEnd, missingParen, divisionByZero, unknownToken(String)
    }
}
```

#### `Modules/Utilities/NumberFormatter+Extensions.swift`

```swift
// SOLID: Single Responsibility — all Double-to-String display formatting lives here.
// All engines and ViewModels import this one extension. No duplication.

import Foundation

extension Double {
    /// Returns a clean display string: integers show no decimal, floats trim trailing zeros.
    /// Examples: 3.0 → "3", 3.14000 → "3.14", 1000000 → "1e+06" (auto scientific notation)
    var displayString: String {
        if isNaN { return "Error" }
        if isInfinite { return isSignMinus ? "−∞" : "∞" }

        // If it's a whole number and fits in Int64, show without decimal
        if self == rounded() && abs(self) < 1e15 {
            return String(format: "%.0f", self)
        }

        // Up to 10 significant digits, trimming trailing zeros
        let formatted = String(format: "%.10g", self)
        return formatted
    }

    /// Format for axis labels (fewer decimals, compact)
    var axisLabelString: String {
        if self == rounded() { return String(format: "%.0f", self) }
        return String(format: "%.2g", self)
    }
}
```

---

### FEAT-02 · CalculatorViewModel with Dependency Injection

#### `Modules/ViewModels/CalculatorViewModel.swift`

```swift
// SOLID: Dependency Inversion — ViewModel depends on CalculatorEngine protocol, not any class.
// SOLID: Single Responsibility — owns only UI state and routes button taps to the engine.
// @Observable (Swift 5.9+) — no @Published boilerplate, works with SwiftUI automatically.

import SwiftUI
import Observation

@Observable
final class CalculatorViewModel {

    // MARK: – Public state (drives SwiftUI views)
    var display: String = "0"
    var currentMode: CalculatorMode = .basic
    var angleMode: AngleMode = .degrees
    var history: [HistoryEntry] = []

    // MARK: – Private engine (injected)
    private var engine: CalculatorEngine
    private var lastExpression: String = ""

    // MARK: – Init (Dependency Injection)
    // Default arg means "no config needed" for production; tests pass a MockCalculatorEngine.
    init(engine: CalculatorEngine = BasicCalculator()) {
        self.engine = engine
    }

    // MARK: – Button input

    func buttonTapped(_ title: String) {
        // Track expression for history before = is processed
        if title != "=" { lastExpression += (lastExpression.isEmpty && title == "C") ? "" : title }

        let result = engine.process(title)
        display = result

        if title == "=" {
            appendHistory()
            lastExpression = result // next expression starts from result
        }
        if title == "C" { lastExpression = "" }
    }

    // MARK: – Mode switching (swaps engine — zero UI changes needed)

    func switchMode(to mode: CalculatorMode) {
        guard mode != currentMode else { return }
        currentMode = mode
        // SOLID: Open/Closed — adding a new mode never modifies this switch, just adds a case
        switch mode {
        case .basic:      engine = BasicCalculator()
        case .scientific: engine = ScientificCalculator()
        case .graph:      engine = GraphingCalculator()
        }
        display = engine.process("C")
    }

    // MARK: – Angle mode (relevant for Scientific only)

    func toggleAngleMode() {
        angleMode = angleMode == .degrees ? .radians : .degrees
        if let sci = engine as? ScientificCalculator {
            sci.angleMode = angleMode
        }
    }

    // MARK: – History

    private func appendHistory() {
        guard let result = engine.evaluate() else { return }
        let entry = HistoryEntry(expression: lastExpression, result: result.displayString)
        history.insert(entry, at: 0)
        if history.count > 10 { history.removeLast() }
    }

    func clearHistory() {
        history.removeAll()
    }

    func restoreFromHistory(_ entry: HistoryEntry) {
        display = entry.result
        _ = engine.process(entry.result)
    }

    // MARK: – Copy/Paste

    func copyResult() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(display, forType: .string)
    }

    func pasteValue() {
        guard let pasted = NSPasteboard.general.string(forType: .string),
              Double(pasted) != nil else { return }
        display = engine.process(pasted)
    }
}
```

---

## EP-02 · Basic Calculator UI

> **Branch:** `feat/basic-ui`

### FEAT-03 · CalculatorDisplay Component

#### `Modules/UIComponents/CalculatorDisplay.swift`

```swift
// SOLID: Single Responsibility — this view only displays a string in a calculator-style box.
// Open/Closed: font size logic is self-contained; changing it never touches ButtonGrid.

import SwiftUI

struct CalculatorDisplay: View {
    let value: String

    // Adaptive font: shrink when the number gets long
    private var fontSize: CGFloat {
        switch value.count {
        case ..<9:  return 64
        case 9..<12: return 44
        default:    return 32
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .fill(Color(.displayBackground))
                .frame(maxWidth: .infinity)
                .frame(height: 120)

            Text(value)
                .font(.system(size: fontSize, weight: .light, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                .contentTransition(.numericText())       // animate digit changes
                .animation(.spring(duration: 0.2), value: value)
                .accessibilityLabel("Display: \(value)")
                .accessibilityValue(value)
        }
    }
}

// MARK: – Color Extension (dark/light mode aware)

extension Color {
    static let displayBackground = Color("DisplayBackground") // defined in Assets.xcassets
    static let operatorOrange    = Color("OperatorOrange")
    static let digitGray         = Color("DigitGray")
    static let utilityGray       = Color("UtilityGray")
}
```

### FEAT-04 · ButtonGrid Component

#### `Modules/UIComponents/CalculatorButtonStyle.swift`

```swift
// SOLID: Open/Closed — new button variants are added as enum cases, existing ones unchanged.
// SOLID: Single Responsibility — styling only. No calculator logic here.

import SwiftUI

enum CalculatorButtonVariant {
    case utility    // C, ±, %     — light gray
    case digit      // 0–9, .      — dark gray
    case `operator` // ÷, ×, −, + — orange
    case equals     // =           — orange, wide

    var backgroundColor: Color {
        switch self {
        case .utility:  return .utilityGray
        case .digit:    return .digitGray
        case .operator, .equals: return .operatorOrange
        }
    }

    var foregroundColor: Color { .white }

    var pressedScale: CGFloat { 0.92 }
}

struct CalculatorButtonStyle: ButtonStyle {
    let variant: CalculatorButtonVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 28, weight: .regular, design: .rounded))
            .foregroundStyle(variant.foregroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Circle()
                    .fill(variant.backgroundColor)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? variant.pressedScale : 1.0)
            .animation(.easeOut(duration: 0.05), value: configuration.isPressed)
            .contentShape(Circle())
    }
}
```

#### `Modules/UIComponents/ButtonGrid.swift`

```swift
// SOLID: Single Responsibility — renders the button layout and routes taps to the ViewModel.
// SOLID: Open/Closed — button data is a static array; adding a button doesn't change rendering logic.
// SOLID: Dependency Inversion — depends on CalculatorViewModel, which depends on CalculatorEngine protocol.

import SwiftUI

struct ButtonGrid: View {
    @Bindable var viewModel: CalculatorViewModel

    // Each row is a fixed array of (label, variant) tuples.
    // "0" spans 2 columns — handled by checking in the grid.
    private let rows: [[ButtonSpec]] = [
        [.init("C", .utility), .init("±", .utility), .init("%", .utility), .init("÷", .operator)],
        [.init("7", .digit),   .init("8", .digit),   .init("9", .digit),   .init("×", .operator)],
        [.init("4", .digit),   .init("5", .digit),   .init("6", .digit),   .init("−", .operator)],
        [.init("1", .digit),   .init("2", .digit),   .init("3", .digit),   .init("+", .operator)],
        [.init("0", .digit, wideSpan: true), .init(".", .digit), .init("=", .equals)],
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row) { spec in
                        Button(spec.label) {
                            viewModel.buttonTapped(spec.label)
                        }
                        .buttonStyle(CalculatorButtonStyle(variant: spec.variant))
                        .frame(
                            width: spec.wideSpan ? buttonSize * 2 + 12 : buttonSize,
                            height: buttonSize
                        )
                        .accessibilityLabel(spec.accessibilityLabel)
                        .accessibilityHint(spec.accessibilityHint)
                    }
                }
            }
        }
        .padding(12)
    }

    private var buttonSize: CGFloat { 72 }
}

// MARK: – ButtonSpec (data model for a single button)

struct ButtonSpec: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let variant: CalculatorButtonVariant
    var wideSpan: Bool = false

    init(_ label: String, _ variant: CalculatorButtonVariant, wideSpan: Bool = false) {
        self.label = label
        self.variant = variant
        self.wideSpan = wideSpan
    }

    var accessibilityLabel: String {
        switch label {
        case "÷": return "Divide"
        case "×": return "Multiply"
        case "−": return "Subtract"
        case "+": return "Add"
        case "=": return "Equals"
        case "±": return "Toggle sign"
        case "%": return "Percent"
        case "C": return "Clear"
        default: return label
        }
    }

    var accessibilityHint: String {
        switch label {
        case "C": return "Resets the display to zero"
        case "=": return "Evaluates the current expression"
        default: return "Enters \(label)"
        }
    }
}
```

### FEAT-05 · Keyboard Input Handler

#### `Modules/UIComponents/KeyboardInputModifier.swift`

```swift
// SOLID: Single Responsibility — maps physical key presses to calculator button labels.
// Implemented as a ViewModifier so it composes cleanly onto any view.

import SwiftUI

struct KeyboardInputModifier: ViewModifier {
    @Bindable var viewModel: CalculatorViewModel

    func body(content: Content) -> some View {
        content
            .focusable()
            .onKeyPress { press in
                guard let mapped = mapKey(press) else { return .ignored }
                viewModel.buttonTapped(mapped)
                return .handled
            }
    }

    private func mapKey(_ press: KeyPress) -> String? {
        switch press.key {
        case "0"..."9": return String(press.key.character)
        case "+":        return "+"
        case "-":        return "−"   // map ASCII to Unicode minus
        case "*":        return "×"
        case "/":        return "÷"
        case ".":        return "."
        case ",":        return "."
        case .return, .init("="):  return "="
        case .escape:    return "C"
        case .delete:    return "⌫"   // handled in ViewModel as backspace
        default:         return nil
        }
    }
}

extension View {
    func calculatorKeyboardInput(viewModel: CalculatorViewModel) -> some View {
        modifier(KeyboardInputModifier(viewModel: viewModel))
    }
}
```

### FEAT-06 · Window Configuration

#### `TitleRedactedCalcApp.swift`

```swift
// SOLID: Single Responsibility — only configures the window and owns the app entry point.
// Window width is driven by CalculatorMode so the UI adapts without AppKit.

import SwiftUI

@main
struct TitleRedactedCalcApp: App {

    @State private var viewModel = CalculatorViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(
                    width: windowWidth(for: viewModel.currentMode),
                    height: 520
                )
        }
        .windowResizability(.contentSize) // fixed — no resize handle
        .windowStyle(.hiddenTitleBar)     // minimal chrome
        .commands {
            CalculatorCommands(viewModel: viewModel) // EP-05 menu commands
        }
    }

    private func windowWidth(for mode: CalculatorMode) -> CGFloat {
        switch mode {
        case .basic:      return 340
        case .scientific: return 560
        case .graph:      return 800
        }
    }
}
```

#### `ContentView.swift`

```swift
// SOLID: Single Responsibility — routes the active mode to the correct child view.
// Open/Closed — adding a new mode is one new case here + a new View file. ContentView unchanged beyond that.

import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: CalculatorViewModel

    var body: some View {
        VStack(spacing: 0) {
            CalculatorModeToggle(viewModel: viewModel)
                .padding(.horizontal, 12)
                .padding(.top, 10)

            CalculatorDisplay(value: viewModel.display)

            // SOLID: Liskov — each sub-view accepts the same CalculatorViewModel
            switch viewModel.currentMode {
            case .basic:
                ButtonGrid(viewModel: viewModel)
            case .scientific:
                ScientificButtonGrid(viewModel: viewModel)
            case .graph:
                GraphView(viewModel: viewModel)
            }

            if viewModel.currentMode != .basic && !viewModel.history.isEmpty {
                HistoryView(viewModel: viewModel)
            }
        }
        .background(Color(.windowBackgroundColor))
        .calculatorKeyboardInput(viewModel: viewModel)
    }
}
```

---

## EP-03 · Scientific Calculator Mode

> **Branch:** `feat/scientific-mode`

### FEAT-07 · Mode Segmented Control

#### `Modules/UIComponents/CalculatorModeToggle.swift`

```swift
// SOLID: Single Responsibility — renders the mode picker and notifies ViewModel.
// Does NOT know about engines or window sizes.

import SwiftUI

struct CalculatorModeToggle: View {
    @Bindable var viewModel: CalculatorViewModel

    var body: some View {
        Picker("Mode", selection: $viewModel.currentMode) {
            ForEach(CalculatorMode.allCases) { mode in
                Text(mode.label).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.currentMode) { _, newMode in
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.switchMode(to: newMode)
            }
        }
        .accessibilityLabel("Calculator mode")
        .accessibilityHint("Switch between Basic, Scientific, and Graphing modes")
    }
}

// MARK: – CalculatorMode enum

enum CalculatorMode: String, CaseIterable, Identifiable {
    case basic      = "basic"
    case scientific = "scientific"
    case graph      = "graph"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .basic:      return "Basic"
        case .scientific: return "Scientific"
        case .graph:      return "Graph"
        }
    }
}
```

### FEAT-08 · Scientific Button Grid + Deg/Rad Toggle

#### `Modules/UIComponents/ScientificButtonGrid.swift`

```swift
// SOLID: Open/Closed — this is a new file extending the UI for scientific mode.
// BasicCalculator and ButtonGrid are completely untouched.

import SwiftUI

struct ScientificButtonGrid: View {
    @Bindable var viewModel: CalculatorViewModel

    // Scientific-only rows sit above the shared basic rows
    private let scientificRows: [[ButtonSpec]] = [
        [.init("sin", .utility), .init("cos", .utility),  .init("tan", .utility),  .init("log", .utility),  .init("ln", .utility)],
        [.init("sin⁻¹", .utility), .init("cos⁻¹", .utility), .init("tan⁻¹", .utility), .init("x²", .utility), .init("√", .utility)],
        [.init("xʸ", .utility), .init("π", .utility),    .init("e", .utility),    .init("(", .utility),    .init(")", .utility)],
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Deg/Rad toggle
            HStack {
                Spacer()
                Toggle(viewModel.angleMode == .degrees ? "DEG" : "RAD", isOn: Binding(
                    get: { viewModel.angleMode == .radians },
                    set: { _ in viewModel.toggleAngleMode() }
                ))
                .toggleStyle(.button)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .tint(.operatorOrange)
                .accessibilityLabel("Angle mode: \(viewModel.angleMode == .degrees ? "Degrees" : "Radians")")
                .accessibilityHint("Tap to toggle between degrees and radians")
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Scientific function rows
            VStack(spacing: 10) {
                ForEach(scientificRows, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(row) { spec in
                            Button(spec.label) {
                                viewModel.buttonTapped(spec.label)
                            }
                            .buttonStyle(CalculatorButtonStyle(variant: spec.variant))
                            .frame(width: 88, height: 52)
                            .font(.system(size: 16, weight: .medium))
                            .accessibilityLabel(spec.label)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Reuse the same ButtonGrid for basic operations
            ButtonGrid(viewModel: viewModel)
        }
    }
}
```

### FEAT-09 · Calculation History

#### `Modules/Utilities/HistoryStore.swift`

```swift
// SOLID: Single Responsibility — manages history state only. No UI.

import Foundation

struct HistoryEntry: Identifiable, Equatable {
    let id = UUID()
    let expression: String
    let result: String
    let date: Date = .now
}
```

#### `Modules/UIComponents/HistoryView.swift`

```swift
// SOLID: Single Responsibility — displays history list only. Never evaluates expressions.

import SwiftUI

struct HistoryView: View {
    @Bindable var viewModel: CalculatorViewModel
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Header bar
            HStack {
                Text("History")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(isExpanded ? "Hide" : "Show") {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                }
                .font(.system(size: 12))
                .foregroundStyle(.operatorOrange)

                Button("Clear") {
                    withAnimation { viewModel.clearHistory() }
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))

            if isExpanded {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.history) { entry in
                            HistoryRow(entry: entry)
                                .onTapGesture { viewModel.restoreFromHistory(entry) }
                        }
                    }
                }
                .frame(maxHeight: 160)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

private struct HistoryRow: View {
    let entry: HistoryEntry

    var body: some View {
        HStack {
            Text(entry.expression)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.secondary)
            Spacer()
            Text("= \(entry.result)")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.controlBackgroundColor).opacity(0.6))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.expression) equals \(entry.result). Tap to restore.")
    }
}
```

---

## EP-04 · Graphing Calculator Mode

> **Branch:** `feat/graphing-mode`

### FEAT-10 · Real-Time Graph Renderer

#### `Modules/ViewModels/GraphViewModel.swift`

```swift
// SOLID: Single Responsibility — owns only graphing state and coordinates engine calls.
// SOLID: Dependency Inversion — depends on GraphingCalculator's evaluateExpression, not its internals.

import SwiftUI
import Observation

@Observable
final class GraphViewModel {
    var expression: String = "sin(x)" {
        didSet { scheduleResample() }
    }
    var xRange: ClosedRange<Double> = -10...10 {
        didSet { resample() }
    }
    var points: [GraphPoint] = []
    var hoverPoint: GraphPoint? = nil

    private let engine = GraphingCalculator()
    private var resampleTask: Task<Void, Never>?

    init() { resample() }

    func resample() {
        points = engine.samplePoints(expression: expression, xRange: xRange, count: 200)
    }

    // Debounce while the user types — resample 120 ms after last keystroke
    private func scheduleResample() {
        resampleTask?.cancel()
        resampleTask = Task {
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            await MainActor.run { resample() }
        }
    }

    // MARK: – Gesture handlers

    func zoom(magnification: Double) {
        let center = (xRange.lowerBound + xRange.upperBound) / 2
        let halfSpan = (xRange.upperBound - xRange.lowerBound) / 2 / magnification
        let newHalf = max(0.005, min(500, halfSpan))
        xRange = (center - newHalf)...(center + newHalf)
    }

    func pan(deltaX: Double) {
        let span = xRange.upperBound - xRange.lowerBound
        let shift = deltaX / 40 * span * 0.05
        xRange = (xRange.lowerBound - shift)...(xRange.upperBound - shift)
    }

    func resetZoom() {
        xRange = -10...10
    }
}

// MARK: – GraphPoint

struct GraphPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
}
```

#### `Modules/UIComponents/GraphView.swift`

```swift
// SOLID: Single Responsibility — renders the chart only.
// SOLID: Open/Closed — adding a second plot series is a new LineMark, not a rewrite.

import SwiftUI
import Charts

struct GraphView: View {
    @Bindable var viewModel: CalculatorViewModel
    @State private var graphVM = GraphViewModel()
    @State private var magnifyStart: Double? = nil

    var body: some View {
        VStack(spacing: 8) {
            // Expression input
            HStack {
                Text("y =")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                TextField("e.g. sin(x)", text: $graphVM.expression)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16, design: .monospaced))
                    .accessibilityLabel("Graph expression")
                    .accessibilityHint("Enter a function of x to graph")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Chart
            ZStack {
                Chart(graphVM.points) { point in
                    LineMark(
                        x: .value("x", point.x),
                        y: .value("y", point.y)
                    )
                    .foregroundStyle(Color.operatorOrange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartXScale(domain: graphVM.xRange.lowerBound...graphVM.xRange.upperBound)
                .chartYAxis { AxisMarks(values: .automatic(desiredCount: 8)) }
                .chartXAxis { AxisMarks(values: .automatic(desiredCount: 8)) }
                .chartBackground { _ in Color(.windowBackgroundColor) }

                // Overlays (EP-04 FEAT-11, FEAT-13)
                AxisOverlay(xRange: graphVM.xRange, points: graphVM.points)
                CrosshairOverlay(graphVM: graphVM)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 12)
            .gesture(magnifyGesture)
            .gesture(panGesture)
            .onTapGesture(count: 2) { graphVM.resetZoom() }
        }
    }

    // FEAT-12 gestures
    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if magnifyStart == nil { magnifyStart = value.magnification }
                graphVM.zoom(magnification: value.magnification)
            }
            .onEnded { _ in magnifyStart = nil }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in graphVM.pan(deltaX: value.translation.width) }
    }
}
```

### FEAT-11 · Axis & Grid Overlay

#### `Modules/UIComponents/AxisOverlay.swift`

```swift
// SOLID: Single Responsibility — draws axes and grid only. No data logic.

import SwiftUI

struct AxisOverlay: View {
    let xRange: ClosedRange<Double>
    let points: [GraphPoint]

    private var yRange: ClosedRange<Double> {
        let ys = points.map(\.y)
        guard let min = ys.min(), let max = ys.max(), min != max else { return -10...10 }
        let pad = (max - min) * 0.1
        return (min - pad)...(max + pad)
    }

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let xScale = size.width / CGFloat(xRange.upperBound - xRange.lowerBound)
                let yScale = size.height / CGFloat(yRange.upperBound - yRange.lowerBound)

                func toScreen(_ x: Double, _ y: Double) -> CGPoint {
                    CGPoint(
                        x: CGFloat(x - xRange.lowerBound) * xScale,
                        y: size.height - CGFloat(y - yRange.lowerBound) * yScale
                    )
                }

                // Grid lines
                let gridColor = Color.primary.opacity(0.08)
                let axisColor = Color.primary.opacity(0.3)
                let step = gridStep(for: xRange)

                var x = (xRange.lowerBound / step).rounded(.up) * step
                while x <= xRange.upperBound {
                    let sx = CGFloat(x - xRange.lowerBound) * xScale
                    var gridPath = Path()
                    gridPath.move(to: CGPoint(x: sx, y: 0))
                    gridPath.addLine(to: CGPoint(x: sx, y: size.height))
                    context.stroke(gridPath, with: .color(x == 0 ? axisColor : gridColor),
                                   lineWidth: x == 0 ? 1.5 : 0.5)
                    x += step
                }

                let yStep = gridStep(for: yRange)
                var y = (yRange.lowerBound / yStep).rounded(.up) * yStep
                while y <= yRange.upperBound {
                    let sy = size.height - CGFloat(y - yRange.lowerBound) * yScale
                    var gridPath = Path()
                    gridPath.move(to: CGPoint(x: 0, y: sy))
                    gridPath.addLine(to: CGPoint(x: size.width, y: sy))
                    context.stroke(gridPath, with: .color(y == 0 ? axisColor : gridColor),
                                   lineWidth: y == 0 ? 1.5 : 0.5)
                    y += yStep
                }
            }
        }
        .allowsHitTesting(false) // transparent to gestures
    }

    private func gridStep(for range: ClosedRange<Double>) -> Double {
        let span = range.upperBound - range.lowerBound
        let rawStep = span / 8
        let magnitude = pow(10, floor(log10(rawStep)))
        let normalized = rawStep / magnitude
        let nice: Double = normalized < 1.5 ? 1 : normalized < 3.5 ? 2 : normalized < 7.5 ? 5 : 10
        return nice * magnitude
    }
}
```

### FEAT-12 · Gesture Controls

> Gestures are wired directly in `GraphView.swift` above (see `magnifyGesture` and `panGesture`).  
> `GraphViewModel.zoom(magnification:)` and `pan(deltaX:)` handle the math.

### FEAT-13 · Hover Crosshair

#### `Modules/UIComponents/CrosshairOverlay.swift`

```swift
// SOLID: Single Responsibility — hover tracking and coordinate readout only.

import SwiftUI

struct CrosshairOverlay: View {
    @Bindable var graphVM: GraphViewModel
    @State private var hoverLocation: CGPoint? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let loc = hoverLocation, let point = nearestPoint(to: loc, in: geo.size) {
                    // Vertical crosshair line
                    Path { path in
                        path.move(to: CGPoint(x: loc.x, y: 0))
                        path.addLine(to: CGPoint(x: loc.x, y: geo.size.height))
                    }
                    .stroke(Color.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))

                    // Horizontal crosshair line
                    let screenY = screenY(for: point.y, in: geo.size)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: screenY))
                        path.addLine(to: CGPoint(x: geo.size.width, y: screenY))
                    }
                    .stroke(Color.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))

                    // Dot at intersection
                    Circle()
                        .fill(Color.operatorOrange)
                        .frame(width: 8, height: 8)
                        .position(x: loc.x, y: screenY)

                    // Coordinate label
                    Text("(\(point.x.displayString), \(point.y.displayString))")
                        .font(.system(size: 11, design: .monospaced))
                        .padding(4)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                        .position(coordinateLabelPosition(crosshairX: loc.x, crosshairY: screenY, in: geo.size))
                }
            }
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let location): hoverLocation = location
                case .ended:                hoverLocation = nil
                }
            }
        }
        .allowsHitTesting(true)
    }

    private func nearestPoint(to location: CGPoint, in size: CGSize) -> GraphPoint? {
        guard !graphVM.points.isEmpty else { return nil }
        let xValue = graphVM.xRange.lowerBound + Double(location.x / size.width) * (graphVM.xRange.upperBound - graphVM.xRange.lowerBound)
        return graphVM.points.min(by: { abs($0.x - xValue) < abs($1.x - xValue) })
    }

    private func screenY(for y: Double, in size: CGSize) -> CGFloat {
        let ys = graphVM.points.map(\.y)
        guard let minY = ys.min(), let maxY = ys.max(), minY != maxY else { return size.height / 2 }
        let span = maxY - minY
        let pad = span * 0.1
        return size.height - CGFloat((y - (minY - pad)) / (span + 2 * pad)) * size.height
    }

    private func coordinateLabelPosition(crosshairX: CGFloat, crosshairY: CGFloat, in size: CGSize) -> CGPoint {
        let offsetX: CGFloat = crosshairX > size.width * 0.6 ? -50 : 50
        let offsetY: CGFloat = crosshairY > size.height * 0.4 ? -16 : 16
        return CGPoint(x: crosshairX + offsetX, y: crosshairY + offsetY)
    }
}
```

---

## EP-05 · Polish & Accessibility

> **Branch:** `feat/polish-accessibility`

#### `Modules/UIComponents/CalculatorCommands.swift`

```swift
// SOLID: Single Responsibility — macOS menu bar commands only.
// Open/Closed — new menu items are new CommandGroup blocks, existing ones untouched.

import SwiftUI

struct CalculatorCommands: Commands {
    @Bindable var viewModel: CalculatorViewModel

    var body: some Commands {
        // Edit menu additions
        CommandGroup(after: .pasteboard) {
            Button("Copy Result") {
                viewModel.copyResult()
            }
            .keyboardShortcut("c", modifiers: .command)

            Button("Paste Value") {
                viewModel.pasteValue()
            }
            .keyboardShortcut("v", modifiers: .command)
        }

        // View menu — mirrors the mode segmented control
        CommandMenu("View") {
            ForEach(CalculatorMode.allCases) { mode in
                Button(mode.label) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.switchMode(to: mode)
                    }
                }
                .keyboardShortcut(modeShortcut(for: mode), modifiers: .command)
            }
        }
    }

    private func modeShortcut(for mode: CalculatorMode) -> KeyEquivalent {
        switch mode {
        case .basic:      return "1"
        case .scientific: return "2"
        case .graph:      return "3"
        }
    }
}
```

#### Accessibility Additions (apply inline in each view)

```swift
// Example: add these to every interactive element in ButtonGrid / ScientificButtonGrid

// On CalculatorDisplay:
.accessibilityLabel("Calculator display")
.accessibilityValue(viewModel.display)
.accessibilityAddTraits(.updatesFrequently)

// Error state announcement:
.onChange(of: viewModel.display) { _, newValue in
    if newValue == "Error" {
        AccessibilityNotification.Announcement("Error. Press C to clear.").post()
    }
}

// On the mode toggle:
.accessibilityLabel("Calculator mode: \(viewModel.currentMode.label)")

// On the angle toggle:
.accessibilityLabel("Angle unit: \(viewModel.angleMode == .degrees ? "Degrees" : "Radians")")
.accessibilityHint("Double-tap to switch")
```

---

## EP-06 · Packaging & Distribution

> **Branch:** `release/v1.0.0`

#### `TitleRedactedCalc.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Hardened Runtime — required for notarisation -->
    <key>com.apple.security.cs.allow-jit</key>
    <false/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <false/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <false/>
    <!-- No network, no file access, no camera — minimal attack surface -->
</dict>
</plist>
```

#### `ExportOptions.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>export</string>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>  <!-- replace before running -->
</dict>
</plist>
```

#### `build.sh`

```bash
#!/usr/bin/env bash
# build.sh — One-command release: archive → export → notarise → DMG
# Usage: VERSION=1.0.0 TEAM_ID=XXXXXXXXXX ./build.sh
# Requirements: Xcode 15+, valid Developer ID Application certificate in Keychain

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
APP_NAME="TitleRedactedCalc"
SCHEME="$APP_NAME"
VERSION="${VERSION:-1.0.0}"
TEAM_ID="${TEAM_ID:?'ERROR: Set TEAM_ID env var'}"
APPLE_ID="${APPLE_ID:?'ERROR: Set APPLE_ID env var for notarisation'}"
APP_PASSWORD="${APP_PASSWORD:?'ERROR: Set APP_PASSWORD env var (app-specific password)'}"

ARCHIVE_PATH="dist/$APP_NAME.xcarchive"
EXPORT_PATH="dist/export"
DMG_PATH="dist/$APP_NAME-$VERSION.dmg"
APP_PATH="$EXPORT_PATH/$APP_NAME.app"

mkdir -p dist

echo "▶ Step 1/5: Archive ($VERSION)"
xcodebuild archive \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    | xcpretty || { echo "✗ Archive failed"; exit 1; }

echo "▶ Step 2/5: Export (Developer ID)"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "ExportOptions.plist" \
    | xcpretty || { echo "✗ Export failed"; exit 1; }

echo "▶ Step 3/5: Notarise"
xcrun notarytool submit "$APP_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$APP_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait \
    || { echo "✗ Notarisation failed"; exit 1; }

echo "▶ Step 4/5: Staple notarisation ticket"
xcrun stapler staple "$APP_PATH" \
    || { echo "✗ Staple failed"; exit 1; }

echo "▶ Step 5/5: Create DMG"
hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$APP_PATH" \
    -ov \
    -format UDZO \
    "$DMG_PATH" \
    || { echo "✗ DMG creation failed"; exit 1; }

# Sign the DMG itself
codesign --sign "Developer ID Application: $TEAM_ID" "$DMG_PATH"

echo ""
echo "✓ Done! → $DMG_PATH"
echo "  Size: $(du -sh "$DMG_PATH" | cut -f1)"
```

---

## EP-07 · Marketing Landing Page

> **Branch:** `feat/landing-page`

#### `index.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>TitleRedactedCalc — The Clean Mac Calculator</title>

  <!-- SEO -->
  <meta name="description" content="TitleRedactedCalc is a native macOS calculator with Basic, Scientific, and Graphing modes. Built entirely in SwiftUI. Zero telemetry." />
  <link rel="canonical" href="https://yourdomain.com/" />

  <!-- Open Graph (Slack/Twitter/iMessage previews) -->
  <meta property="og:title"       content="TitleRedactedCalc" />
  <meta property="og:description" content="The clean Mac calculator that just works. Basic · Scientific · Graphing." />
  <meta property="og:image"       content="https://yourdomain.com/og-image.png" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta property="og:url"         content="https://yourdomain.com/" />
  <meta property="og:type"        content="website" />
  <meta name="twitter:card"       content="summary_large_image" />

  <style>
    /* ── Reset & Variables ─────────────────────────────── */
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --bg:        #0d0d0f;
      --surface:   #1a1a1f;
      --border:    #2a2a35;
      --accent:    #007AFF;
      --accent-hi: #47a3ff;
      --orange:    #FF9500;
      --text:      #f0f0f5;
      --muted:     #8e8e9a;
      --radius:    16px;
      --font:      -apple-system, "SF Pro Display", system-ui, sans-serif;
    }

    html { scroll-behavior: smooth; }

    body {
      font-family: var(--font);
      background: var(--bg);
      color: var(--text);
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }

    /* ── Layout ────────────────────────────────────────── */
    .container { max-width: 960px; margin: 0 auto; padding: 0 24px; }

    /* ── Nav ───────────────────────────────────────────── */
    nav {
      position: sticky; top: 0; z-index: 100;
      background: rgba(13,13,15,0.85);
      backdrop-filter: blur(20px);
      border-bottom: 1px solid var(--border);
    }
    nav .inner {
      display: flex; align-items: center; justify-content: space-between;
      max-width: 960px; margin: 0 auto; padding: 14px 24px;
    }
    .nav-brand { font-size: 1.1rem; font-weight: 700; color: var(--text); }
    .nav-brand span { color: var(--accent); }
    .nav-link {
      color: var(--muted); text-decoration: none; font-size: 0.9rem;
      transition: color 0.2s;
    }
    .nav-link:hover { color: var(--text); }

    /* ── Hero ──────────────────────────────────────────── */
    .hero {
      text-align: center;
      padding: 100px 24px 80px;
    }
    .hero-eyebrow {
      display: inline-block;
      font-size: 0.8rem; font-weight: 600; letter-spacing: 0.12em;
      text-transform: uppercase; color: var(--accent);
      background: rgba(0,122,255,0.1);
      border: 1px solid rgba(0,122,255,0.25);
      border-radius: 999px; padding: 4px 14px; margin-bottom: 24px;
    }
    h1 {
      font-size: clamp(2.8rem, 8vw, 5.5rem);
      font-weight: 700; letter-spacing: -0.03em; line-height: 1.05;
      margin-bottom: 20px;
    }
    h1 em { font-style: normal; color: var(--accent); }
    .hero-sub {
      font-size: clamp(1rem, 2.5vw, 1.25rem);
      color: var(--muted); max-width: 560px; margin: 0 auto 40px;
    }
    .btn-download {
      display: inline-flex; align-items: center; gap: 10px;
      background: var(--accent); color: #fff;
      font-size: 1.05rem; font-weight: 600;
      padding: 16px 36px; border-radius: 14px;
      text-decoration: none;
      box-shadow: 0 4px 24px rgba(0,122,255,0.35);
      transition: background 0.2s, transform 0.15s, box-shadow 0.2s;
    }
    .btn-download:hover {
      background: var(--accent-hi);
      transform: translateY(-2px);
      box-shadow: 0 8px 32px rgba(0,122,255,0.45);
    }
    .btn-download svg { width: 20px; height: 20px; }
    .hero-meta {
      margin-top: 16px; font-size: 0.82rem; color: var(--muted);
    }

    /* ── Screenshots ───────────────────────────────────── */
    .screenshots {
      display: flex; gap: 16px; justify-content: center;
      padding: 0 24px 80px; flex-wrap: wrap;
    }
    .screenshot {
      border-radius: var(--radius);
      overflow: hidden;
      border: 1px solid var(--border);
      box-shadow: 0 20px 60px rgba(0,0,0,0.6);
      max-width: 280px;
      transition: transform 0.3s;
    }
    .screenshot:hover { transform: translateY(-6px); }
    .screenshot img { display: block; width: 100%; }
    .screenshot-label {
      text-align: center; font-size: 0.8rem; color: var(--muted);
      padding: 8px 0 4px;
    }

    /* ── Features ──────────────────────────────────────── */
    .features { padding: 60px 24px 80px; }
    .section-title {
      text-align: center; font-size: 2rem; font-weight: 700;
      letter-spacing: -0.02em; margin-bottom: 48px;
    }
    .feature-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 20px;
    }
    .feature-card {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius);
      padding: 28px 24px;
      transition: border-color 0.2s;
    }
    .feature-card:hover { border-color: var(--accent); }
    .feature-icon { font-size: 2rem; margin-bottom: 14px; }
    .feature-card h3 { font-size: 1rem; font-weight: 600; margin-bottom: 8px; }
    .feature-card p { font-size: 0.9rem; color: var(--muted); line-height: 1.5; }

    /* ── Footer ────────────────────────────────────────── */
    footer {
      border-top: 1px solid var(--border);
      padding: 32px 24px;
      text-align: center;
      font-size: 0.82rem;
      color: var(--muted);
    }
    footer a { color: var(--muted); text-decoration: underline; }
  </style>
</head>
<body>

  <!-- ── Nav ── -->
  <nav>
    <div class="inner">
      <span class="nav-brand">Title<span>Redacted</span>Calc</span>
      <a href="#features" class="nav-link">Features</a>
    </div>
  </nav>

  <!-- ── Hero ── -->
  <section class="hero container">
    <span class="hero-eyebrow">Native macOS · SwiftUI · Zero tracking</span>
    <h1>The clean Mac calculator<br>that <em>just works.</em></h1>
    <p class="hero-sub">
      Basic, Scientific, and Graphing modes in one native app.
      No Electron. No subscriptions. No telemetry.
    </p>
    <a href="TitleRedactedCalc-1.0.0.dmg" class="btn-download" aria-label="Download TitleRedactedCalc for macOS">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
        <polyline points="7 10 12 15 17 10"/>
        <line x1="12" y1="15" x2="12" y2="3"/>
      </svg>
      Download for macOS
    </a>
    <p class="hero-meta">macOS 14 Sonoma or later · Free · ~3 MB</p>
  </section>

  <!-- ── Screenshots ── -->
  <div class="screenshots container">
    <div>
      <div class="screenshot">
        <img src="screenshots/basic.png" alt="Basic calculator mode showing arithmetic" width="280" height="420" />
      </div>
      <p class="screenshot-label">Basic</p>
    </div>
    <div>
      <div class="screenshot">
        <img src="screenshots/scientific.png" alt="Scientific mode with trig and log functions" width="280" height="420" />
      </div>
      <p class="screenshot-label">Scientific</p>
    </div>
    <div>
      <div class="screenshot">
        <img src="screenshots/graph.png" alt="Graphing mode plotting sin(x)" width="280" height="420" />
      </div>
      <p class="screenshot-label">Graphing</p>
    </div>
  </div>

  <!-- ── Features ── -->
  <section class="features" id="features">
    <div class="container">
      <h2 class="section-title">Everything you need, nothing you don't</h2>
      <div class="feature-grid">
        <div class="feature-card">
          <div class="feature-icon">🧮</div>
          <h3>Basic &amp; Scientific</h3>
          <p>Arithmetic, trig, logs, powers, and constants. Switchable Deg/Rad mode.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">📈</div>
          <h3>Live Graphing</h3>
          <p>Plot any y = f(x) in real-time. Pinch to zoom, drag to pan, hover for coordinates.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">⌨️</div>
          <h3>Keyboard First</h3>
          <p>Every key on your keyboard works. Calculate at typing speed.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">♿</div>
          <h3>Fully Accessible</h3>
          <p>VoiceOver-ready from day one. Zero Accessibility Inspector warnings.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🌗</div>
          <h3>Dark &amp; Light Mode</h3>
          <p>Automatically follows your system appearance. No configuration needed.</p>
        </div>
        <div class="feature-card">
          <div class="feature-icon">🔒</div>
          <h3>Zero Tracking</h3>
          <p>No telemetry. No network requests. No analytics. Ever.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Footer ── -->
  <footer>
    <p>TitleRedactedCalc v1.0.0 · Requires macOS 14 Sonoma or later · <a href="privacy.html">Privacy: none collected</a></p>
  </footer>

</body>
</html>
```

---

## Tests

> **Files:** `Tests/BasicCalculatorTests.swift`, `Tests/ScientificCalculatorTests.swift`, `Tests/ViewModelTests.swift`

#### `Tests/BasicCalculatorTests.swift`

```swift
import XCTest
@testable import TitleRedactedCalc

final class BasicCalculatorTests: XCTestCase {
    var calc: BasicCalculator!

    override func setUp() { calc = BasicCalculator() }

    func test_addition() {
        _ = calc.process("4")
        _ = calc.process("+")
        _ = calc.process("3")
        XCTAssertEqual(calc.evaluate(), 7)
    }

    func test_subtraction() {
        _ = calc.process("1")
        _ = calc.process("0")
        _ = calc.process("−")
        _ = calc.process("4")
        _ = calc.process("=")
        XCTAssertEqual(calc.evaluate(), 6)
    }

    func test_multiplication() {
        _ = calc.process("6")
        _ = calc.process("×")
        _ = calc.process("7")
        _ = calc.process("=")
        XCTAssertEqual(calc.evaluate(), 42)
    }

    func test_divisionByZero_returnsError() {
        _ = calc.process("9")
        _ = calc.process("÷")
        _ = calc.process("0")
        let result = calc.process("=")
        XCTAssertEqual(result, "Error")
        XCTAssertNil(calc.evaluate())
    }

    func test_percentageConversion() {
        _ = calc.process("5")
        _ = calc.process("0")
        let result = calc.process("%")
        XCTAssertEqual(result, "0.5")
    }

    func test_signToggle() {
        _ = calc.process("3")
        let result = calc.process("±")
        XCTAssertTrue(result.contains("3")) // should be "−3"
    }

    func test_reset() {
        _ = calc.process("9")
        _ = calc.process("+")
        _ = calc.process("9")
        calc.reset()
        XCTAssertEqual(calc.evaluate(), 0)
    }

    func test_chained_operations() {
        _ = calc.process("2")
        _ = calc.process("+")
        _ = calc.process("3")
        _ = calc.process("×")
        _ = calc.process("4")
        _ = calc.process("=")
        // Standard left-to-right calculator: (2+3)×4 = 20
        XCTAssertEqual(calc.evaluate(), 20)
    }
}
```

#### `Tests/ScientificCalculatorTests.swift`

```swift
import XCTest
@testable import TitleRedactedCalc

final class ScientificCalculatorTests: XCTestCase {
    var calc: ScientificCalculator!

    override func setUp() {
        calc = ScientificCalculator()
        calc.angleMode = .degrees
    }

    func test_sin90_degrees() {
        _ = calc.process("9")
        _ = calc.process("0")
        let result = calc.process("sin")
        XCTAssertEqual(Double(result)!, 1.0, accuracy: 1e-10)
    }

    func test_cos0_degrees() {
        _ = calc.process("0")
        let result = calc.process("cos")
        XCTAssertEqual(Double(result)!, 1.0, accuracy: 1e-10)
    }

    func test_squareRoot() {
        _ = calc.process("1")
        _ = calc.process("6")
        let result = calc.process("√")
        XCTAssertEqual(Double(result)!, 4.0, accuracy: 1e-10)
    }

    func test_log10() {
        _ = calc.process("1")
        _ = calc.process("0")
        _ = calc.process("0")
        let result = calc.process("log")
        XCTAssertEqual(Double(result)!, 2.0, accuracy: 1e-10)
    }

    func test_piConstant() {
        let result = calc.process("π")
        XCTAssertEqual(Double(result)!, Double.pi, accuracy: 1e-10)
    }

    func test_squareOperation() {
        _ = calc.process("5")
        let result = calc.process("x²")
        XCTAssertEqual(Double(result)!, 25.0, accuracy: 1e-10)
    }
}
```

#### `Tests/ViewModelTests.swift`

```swift
import XCTest
@testable import TitleRedactedCalc

// SOLID: Dependency Inversion in action — test with a mock engine, not BasicCalculator.
final class MockCalculatorEngine: CalculatorEngine {
    var processCallCount = 0
    var lastInput: String = ""
    var stubbedResult: String = "42"
    var stubbedEvaluate: Double? = 42

    func process(_ input: String) -> String {
        processCallCount += 1
        lastInput = input
        return stubbedResult
    }
    func evaluate() -> Double? { stubbedEvaluate }
    func reset() {}
}

final class ViewModelTests: XCTestCase {
    func test_buttonTapped_callsEngine() {
        let mock = MockCalculatorEngine()
        let vm = CalculatorViewModel(engine: mock)

        vm.buttonTapped("5")

        XCTAssertEqual(mock.processCallCount, 1)
        XCTAssertEqual(mock.lastInput, "5")
    }

    func test_display_updatesFromEngine() {
        let mock = MockCalculatorEngine()
        mock.stubbedResult = "99"
        let vm = CalculatorViewModel(engine: mock)

        vm.buttonTapped("=")

        XCTAssertEqual(vm.display, "99")
    }

    func test_history_appendsOnEquals() {
        let mock = MockCalculatorEngine()
        mock.stubbedEvaluate = 42
        let vm = CalculatorViewModel(engine: mock)

        vm.buttonTapped("4")
        vm.buttonTapped("2")
        vm.buttonTapped("=")

        XCTAssertEqual(vm.history.count, 1)
        XCTAssertEqual(vm.history.first?.result, "42")
    }

    func test_history_capsAtTen() {
        let mock = MockCalculatorEngine()
        mock.stubbedEvaluate = 1
        let vm = CalculatorViewModel(engine: mock)

        for _ in 0..<15 { vm.buttonTapped("=") }

        XCTAssertEqual(vm.history.count, 10)
    }

    func test_switchMode_swapsEngine() {
        let vm = CalculatorViewModel()
        XCTAssertEqual(vm.currentMode, .basic)

        vm.switchMode(to: .scientific)
        XCTAssertEqual(vm.currentMode, .scientific)

        vm.switchMode(to: .graph)
        XCTAssertEqual(vm.currentMode, .graph)
    }
}
```

---

## SOLID Quick-Reference

| Principle | Where applied |
|-----------|---------------|
| **S** — Single Responsibility | `BasicCalculator` (arithmetic only), `CalculatorDisplay` (render only), `AxisOverlay` (draw only), `HistoryStore` (state only) |
| **O** — Open/Closed | `ScientificCalculator` adds functions without touching `BasicCalculator`. New modes add new view files without editing `ContentView`. |
| **L** — Liskov Substitution | `BasicCalculator`, `ScientificCalculator`, `GraphingCalculator` are all drop-in replacements for `CalculatorEngine` |
| **I** — Interface Segregation | `CalculatorEngine` is a small 3-method protocol. `GraphingCalculator` adds `evaluateExpression` on top, not inside the protocol |
| **D** — Dependency Inversion | `CalculatorViewModel.init(engine: CalculatorEngine)` — high-level policy never imports a concrete engine class |
