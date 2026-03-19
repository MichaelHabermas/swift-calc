import Foundation
import Observation

import CoreCalculator
import Utilities

public enum CalculatorMode: String, CaseIterable, Sendable {
    case basic = "Basic"
    case scientific = "Scientific"
    case graph = "Graph"
}

@Observable
public final class CalculatorViewModel {
    public var display: String = "0"
    public var mode: CalculatorMode = .basic
    public var angleMode: AngleMode = .degrees {
        didSet { scientificEngine.angleMode = angleMode }
    }
    public var historyEntries: [HistoryEntry] = []

    private let basicEngine = BasicCalculator()
    private let scientificEngine = ScientificCalculator()
    private let graphingEngine = GraphingCalculator()

    // For DI testing only
    private var testEngine: (any CalculatorEngine)?

    // Expression token buffer for history recording
    private var expressionParts: [String] = []

    public init() {
        basicEngine.reset()
    }

    /// Testing initializer — injects a mock engine; mode-switching is bypassed.
    public init(engine: any CalculatorEngine) {
        testEngine = engine
        engine.reset()
        display = engine.evaluate().map { $0.displayString } ?? "0"
    }

    private var activeEngine: any CalculatorEngine {
        if let e = testEngine { return e }
        switch mode {
        case .basic:       return basicEngine
        case .scientific:  return scientificEngine
        case .graph:       return graphingEngine
        }
    }

    public func buttonTapped(_ title: String) {
        // Keep scientific engine in sync with current angle mode.
        scientificEngine.angleMode = angleMode

        let beforeDisplay = display

        switch title {
        case "C":
            expressionParts = []
            display = activeEngine.process(title)

        case "=":
            if !expressionParts.isEmpty {
                expressionParts.append(beforeDisplay)
                let expr = expressionParts.joined(separator: " ")
                display = activeEngine.process("=")
                let entry = HistoryEntry(expression: expr, result: display)
                historyEntries.insert(entry, at: 0)
                if historyEntries.count > 10 {
                    historyEntries = Array(historyEntries.prefix(10))
                }
                expressionParts = []
            } else {
                display = activeEngine.process("=")
            }

        case "+", "−", "×", "÷":
            expressionParts.append(beforeDisplay)
            expressionParts.append(title)
            display = activeEngine.process(title)

        default:
            display = activeEngine.process(title)
        }
    }

    /// Switch mode while preserving the current display value.
    public func setMode(_ newMode: CalculatorMode) {
        guard newMode != mode else { return }
        let savedDisplay = display
        mode = newMode
        expressionParts = []
        activeEngine.reset()
        if savedDisplay != "0" && savedDisplay != "Error" {
            display = activeEngine.process(savedDisplay)
        } else {
            display = "0"
        }
    }

    public func clearHistory() {
        historyEntries = []
    }

    public func restoreFromHistory(_ entry: HistoryEntry) {
        guard entry.result != "Error" else { return }
        expressionParts = []
        activeEngine.reset()
        display = activeEngine.process(entry.result)
    }
}
