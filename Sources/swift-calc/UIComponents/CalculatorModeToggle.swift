import SwiftUI
import ViewModels

struct CalculatorModeToggle: View {
    let currentMode: CalculatorMode
    let onModeChange: (CalculatorMode) -> Void

    var body: some View {
        // Use a custom Binding so writes go through onModeChange (which calls
        // vm.setMode), not directly to vm.mode. This ensures display-preservation
        // logic in setMode always runs before the mode property is updated.
        Picker("Mode", selection: Binding(
            get: { currentMode },
            set: { onModeChange($0) }
        )) {
            ForEach(CalculatorMode.allCases, id: \.self) { m in
                Text(m.rawValue).tag(m)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityLabel("Calculator mode")
        .accessibilityHint("Switch between Basic, Scientific, and Graph modes")
    }
}
