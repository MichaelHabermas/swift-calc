import SwiftUI
import CoreCalculator

struct CrosshairOverlay: View {
    let xRange: ClosedRange<Double>
    let yRange: ClosedRange<Double>
    let nearestPoint: GraphPoint?
    let isVisible: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            if isVisible, let pt = nearestPoint {
                let px = mapX(pt.x, w: w)
                let py = mapY(pt.y, h: h)
                ZStack {
                    // Vertical line
                    Path { path in
                        path.move(to: CGPoint(x: px, y: 0))
                        path.addLine(to: CGPoint(x: px, y: h))
                    }
                    .stroke(Color.orange.opacity(0.7), lineWidth: 1)

                    // Horizontal line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: py))
                        path.addLine(to: CGPoint(x: w, y: py))
                    }
                    .stroke(Color.orange.opacity(0.7), lineWidth: 1)

                    // Dot at intersection
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 7, height: 7)
                        .position(x: px, y: py)

                    // Coordinate label
                    coordinateLabel(pt: pt, px: px, py: py, w: w, h: h)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func coordinateLabel(pt: GraphPoint, px: CGFloat, py: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        let label = String(format: "(%.4f, %.4f)", pt.x, pt.y)
        let labelW = CGFloat(label.count * 7 + 16)
        let labelH = CGFloat(20)
        let offsetX: CGFloat = px + labelW + 4 > w ? -labelW - 4 : 4
        let offsetY: CGFloat = py - labelH - 4 < 0 ? 4 : -labelH - 4

        return Text(label)
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.75)))
            .position(x: px + offsetX + labelW / 2, y: py + offsetY + labelH / 2)
            .accessibilityLabel("Crosshair at x \(String(format: "%.4f", pt.x)), y \(String(format: "%.4f", pt.y))")
    }

    private func mapX(_ x: Double, w: CGFloat) -> CGFloat {
        let frac = (x - xRange.lowerBound) / (xRange.upperBound - xRange.lowerBound)
        return CGFloat(frac) * w
    }

    private func mapY(_ y: Double, h: CGFloat) -> CGFloat {
        let frac = (y - yRange.lowerBound) / (yRange.upperBound - yRange.lowerBound)
        return h - CGFloat(frac) * h
    }
}
