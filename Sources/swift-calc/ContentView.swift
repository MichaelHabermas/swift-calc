import SwiftUI
import ViewModels
import CoreCalculator
import Utilities

struct ContentView: View {
    @State private var vm = CalculatorViewModel()

    // Window width animates with the mode.
    private var windowWidth: CGFloat {
        switch vm.mode {
        case .basic:       return 340
        case .scientific:  return 560
        case .graph:       return 560
        }
    }

    private var windowHeight: CGFloat {
        switch vm.mode {
        case .basic, .scientific: return 560
        case .graph:              return 620
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Mode toggle — always visible
            CalculatorModeToggle(currentMode: vm.mode) { newMode in
                withAnimation(.easeInOut(duration: 0.3)) {
                    vm.setMode(newMode)
                }
            }

            switch vm.mode {
            case .basic:
                basicLayout
            case .scientific:
                scientificLayout
            case .graph:
                graphLayout
            }
        }
        .frame(width: windowWidth, height: windowHeight)
        .background(Color(white: 0.1))
        .keyboardInput(vm: vm)
        .focusedValue(\.calculatorViewModel, vm)
        .animation(.easeInOut(duration: 0.3), value: vm.mode)
    }

    // MARK: - Basic layout

    private var basicLayout: some View {
        VStack(spacing: 0) {
            CalculatorDisplay(value: vm.display)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            ButtonGrid(vm: vm)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Scientific layout

    private var scientificLayout: some View {
        VStack(spacing: 0) {
            CalculatorDisplay(value: vm.display)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)

            HStack(spacing: 0) {
                // Left: scientific function buttons
                ScientificButtonGrid(vm: vm)
                    .frame(width: 220)

                Divider()

                // Right: standard basic grid
                ButtonGrid(vm: vm)
                    .frame(width: 340)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // History panel at the bottom
            if !vm.historyEntries.isEmpty {
                HistoryView(
                    entries: vm.historyEntries,
                    onTap: { vm.restoreFromHistory($0) },
                    onClear: { withAnimation { vm.clearHistory() } }
                )
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Graph layout

    private var graphLayout: some View {
        VStack(spacing: 0) {
            GraphView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
