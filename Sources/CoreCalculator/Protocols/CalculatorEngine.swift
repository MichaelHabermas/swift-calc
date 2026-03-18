import Foundation

/// The single contract every calculator engine must fulfill.
/// - `process(_:)` handles incremental button input; it returns the updated display string.
/// - `evaluate()` returns the final numeric result for the current state (or `nil` if in an error state / mid-entry).
public protocol CalculatorEngine: AnyObject {
    func process(_ input: String) -> String
    func evaluate() -> Double?
    func reset()
}

