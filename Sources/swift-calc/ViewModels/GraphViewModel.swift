import Foundation
import Observation
import CoreCalculator

@Observable
@MainActor
final class GraphViewModel {
    var expression: String = "x^2"
    var xRange: ClosedRange<Double> = -10...10
    var points: [GraphPoint] = []

    private let calculator = GraphingCalculator()
    private var debounceTask: Task<Void, Never>?

    init() {
        resample()
    }

    func expressionChanged(_ newExpr: String) {
        expression = newExpr
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            guard !Task.isCancelled else { return }
            resample()
        }
    }

    func resample() {
        points = calculator.samplePoints(expression: expression, xRange: xRange)
    }

    func zoom(factor: Double) {
        let center = (xRange.lowerBound + xRange.upperBound) / 2.0
        let halfWidth = (xRange.upperBound - xRange.lowerBound) / 2.0 / factor
        let newLower = max(-1000, center - halfWidth)
        let newUpper = min(1000,  center + halfWidth)
        guard newLower < newUpper else { return }
        xRange = newLower...newUpper
        resample()
    }

    func pan(by deltaX: Double) {
        let newLower = xRange.lowerBound + deltaX
        let newUpper = xRange.upperBound + deltaX
        xRange = newLower...newUpper
        resample()
    }

    func resetZoom() {
        xRange = -10...10
        resample()
    }

    /// Convert a pixel x-coordinate (0 = left edge) inside a view of `viewWidth` to
    /// the mathematical x value within the current xRange.
    func mathX(from pixelX: Double, viewWidth: Double) -> Double {
        let fraction = pixelX / viewWidth
        return xRange.lowerBound + fraction * (xRange.upperBound - xRange.lowerBound)
    }

    /// Nearest sampled point to the given mathematical x.
    func nearestPoint(to x: Double) -> GraphPoint? {
        guard !points.isEmpty else { return nil }
        return points.min(by: { abs($0.x - x) < abs($1.x - x) })
    }
}
