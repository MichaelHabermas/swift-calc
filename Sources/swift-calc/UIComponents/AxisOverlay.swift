import SwiftUI
import CoreCalculator

/// Draws X/Y axes and a uniform grid over the graph area.
struct AxisOverlay: View {
    let xRange: ClosedRange<Double>
    let yRange: ClosedRange<Double>

    @Environment(\.colorScheme) private var colorScheme

    private var gridColor: Color {
        colorScheme == .dark ? Color(white: 0.3) : Color(white: 0.75)
    }
    private var axisColor: Color {
        colorScheme == .dark ? Color(white: 0.6) : Color(white: 0.3)
    }
    private var labelColor: Color { .secondary }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Canvas { ctx, size in
                drawGrid(ctx: ctx, size: size, w: w, h: h)
                drawAxes(ctx: ctx, size: size, w: w, h: h)
            }

            // Axis labels as overlay Text views
            axisLabels(w: w, h: h)
        }
    }

    // MARK: - Canvas drawing

    private func drawGrid(ctx: GraphicsContext, size: CGSize, w: CGFloat, h: CGFloat) {
        let step = gridStep()
        var x = ceil(xRange.lowerBound / step) * step
        while x <= xRange.upperBound {
            let px = mapX(x, w: w)
            var path = Path()
            path.move(to: CGPoint(x: px, y: 0))
            path.addLine(to: CGPoint(x: px, y: h))
            ctx.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            x += step
        }

        let yStep = gridStep(for: yRange)
        var y = ceil(yRange.lowerBound / yStep) * yStep
        while y <= yRange.upperBound {
            let py = mapY(y, h: h)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: py))
            path.addLine(to: CGPoint(x: w, y: py))
            ctx.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            y += yStep
        }
    }

    private func drawAxes(ctx: GraphicsContext, size: CGSize, w: CGFloat, h: CGFloat) {
        // Y axis (x = 0)
        if xRange.lowerBound <= 0 && 0 <= xRange.upperBound {
            let px = mapX(0, w: w)
            var path = Path()
            path.move(to: CGPoint(x: px, y: 0))
            path.addLine(to: CGPoint(x: px, y: h))
            ctx.stroke(path, with: .color(axisColor), lineWidth: 1.5)
        }
        // X axis (y = 0)
        if yRange.lowerBound <= 0 && 0 <= yRange.upperBound {
            let py = mapY(0, h: h)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: py))
            path.addLine(to: CGPoint(x: w, y: py))
            ctx.stroke(path, with: .color(axisColor), lineWidth: 1.5)
        }
    }

    // MARK: - Labels

    private func axisLabels(w: CGFloat, h: CGFloat) -> some View {
        let step = gridStep()
        let yStep = gridStep(for: yRange)
        return ZStack(alignment: .topLeading) {
            // X-axis labels
            ForEach(xLabelValues(step: step), id: \.self) { val in
                let px = mapX(val, w: w)
                let py = min(h - 14, max(2, mapY(0, h: h) + 2))
                Text(formatLabel(val))
                    .font(.system(size: 9))
                    .foregroundStyle(labelColor)
                    .position(x: px, y: py)
            }
            // Y-axis labels
            ForEach(yLabelValues(step: yStep), id: \.self) { val in
                let py = mapY(val, h: h)
                let px = max(18, mapX(0, w: w) + 3)
                Text(formatLabel(val))
                    .font(.system(size: 9))
                    .foregroundStyle(labelColor)
                    .position(x: px, y: py)
            }
        }
    }

    // MARK: - Helpers

    private func gridStep() -> Double {
        let rangeWidth = xRange.upperBound - xRange.lowerBound
        return niceStep(for: rangeWidth)
    }

    private func gridStep(for range: ClosedRange<Double>) -> Double {
        let rangeHeight = range.upperBound - range.lowerBound
        return niceStep(for: rangeHeight)
    }

    private func niceStep(for range: Double) -> Double {
        let rough = range / 8.0
        let mag = pow(10.0, floor(log10(rough)))
        let norm = rough / mag
        let nice: Double = norm < 2 ? 1 : norm < 5 ? 2 : 5
        return nice * mag
    }

    private func mapX(_ x: Double, w: CGFloat) -> CGFloat {
        let frac = (x - xRange.lowerBound) / (xRange.upperBound - xRange.lowerBound)
        return CGFloat(frac) * w
    }

    private func mapY(_ y: Double, h: CGFloat) -> CGFloat {
        let frac = (y - yRange.lowerBound) / (yRange.upperBound - yRange.lowerBound)
        return h - CGFloat(frac) * h
    }

    private func xLabelValues(step: Double) -> [Double] {
        var vals: [Double] = []
        var v = ceil(xRange.lowerBound / step) * step
        while v <= xRange.upperBound {
            vals.append(v)
            v += step
        }
        return vals
    }

    private func yLabelValues(step: Double) -> [Double] {
        var vals: [Double] = []
        var v = ceil(yRange.lowerBound / step) * step
        while v <= yRange.upperBound {
            vals.append(v)
            v += step
        }
        return vals
    }

    private func formatLabel(_ val: Double) -> String {
        if abs(val) < 1e-10 { return "0" }
        if val == val.rounded() && abs(val) < 1e6 {
            return String(Int(val))
        }
        return String(format: "%.2g", val)
    }
}
