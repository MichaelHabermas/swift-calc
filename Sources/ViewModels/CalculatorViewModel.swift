import Foundation
import Observation

import CoreCalculator
import Utilities

@Observable
public final class CalculatorViewModel {
    public var display: String

    private var engine: any CalculatorEngine

    // Dependency Injection: callers can provide any engine conforming to `CalculatorEngine`.
    public init(engine: any CalculatorEngine = BasicCalculator()) {
        self.engine = engine
        // Keep initialization side-effect-free with respect to `process(_:)` (important for DI tests).
        engine.reset()
        self.display = engine.evaluate().map(\.displayString) ?? "0"
    }

    public func buttonTapped(_ title: String) {
        display = engine.process(title)
    }
}

