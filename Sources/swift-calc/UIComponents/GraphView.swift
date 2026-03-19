import SwiftUI
import Charts
import CoreCalculator

struct GraphView: View {
    @State private var gvm = GraphViewModel()
    @State private var hoverLocation: CGPoint? = nil
    @State private var viewSize: CGSize = .zero

    private var yRange: ClosedRange<Double> {
        let ys = gvm.points.map(\.y)
        guard let minY = ys.min(), let maxY = ys.max(), minY < maxY else {
            return -10...10
        }
        let pad = (maxY - minY) * 0.1
        return (minY - pad)...(maxY + pad)
    }

    private var nearestPoint: GraphPoint? {
        guard let loc = hoverLocation, viewSize.width > 0 else { return nil }
        let mathX = gvm.mathX(from: loc.x, viewWidth: viewSize.width)
        return gvm.nearestPoint(to: mathX)
    }

    var body: some View {
        VStack(spacing: 0) {
            expressionField
            chartArea
        }
    }

    private var expressionField: some View {
        HStack {
            Text("y =")
                .foregroundStyle(.secondary)
                .font(.system(size: 14))
            TextField("expression, e.g. sin(x)", text: $gvm.expression)
                .font(.system(size: 14, design: .monospaced))
                .textFieldStyle(.plain)
                .onSubmit { gvm.resample() }
                .onChange(of: gvm.expression) { _, new in
                    gvm.expressionChanged(new)
                }
                .accessibilityLabel("Function expression")
                .accessibilityHint("Enter a function of x, for example x squared or sin of x")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private var chartArea: some View {
        ZStack {
            // Background
            Color(white: 0.08)

            GeometryReader { geo in
                let _ = Task { @MainActor in viewSize = geo.size }

                // Axis grid and labels
                AxisOverlay(xRange: gvm.xRange, yRange: yRange)

                // Chart line
                Chart(gvm.points) { pt in
                    LineMark(
                        x: .value("x", pt.x),
                        y: .value("y", pt.y)
                    )
                    .foregroundStyle(Color.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartXScale(domain: gvm.xRange.lowerBound...gvm.xRange.upperBound)
                .chartYScale(domain: yRange.lowerBound...yRange.upperBound)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartPlotStyle { plot in
                    plot.frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Crosshair
                CrosshairOverlay(
                    xRange: gvm.xRange,
                    yRange: yRange,
                    nearestPoint: nearestPoint,
                    isVisible: hoverLocation != nil
                )
            }
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(let loc): hoverLocation = loc
            case .ended:           hoverLocation = nil
            }
        }
        .gesture(
            MagnifyGesture()
                .onEnded { value in
                    gvm.zoom(factor: value.magnification)
                }
        )
        .gesture(
            DragGesture(minimumDistance: 4)
                .onChanged { value in
                    guard viewSize.width > 0 else { return }
                    let xSpan = gvm.xRange.upperBound - gvm.xRange.lowerBound
                    let deltaX = -Double(value.translation.width) / Double(viewSize.width) * xSpan
                    gvm.pan(by: deltaX)
                }
        )
        .onTapGesture(count: 2) {
            gvm.resetZoom()
        }
        .accessibilityLabel("Graph area")
        .accessibilityHint("Shows the graph of the entered function. Pinch to zoom, drag to pan, double-tap to reset zoom.")
    }
}
