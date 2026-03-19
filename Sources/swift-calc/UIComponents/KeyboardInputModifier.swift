import SwiftUI
import ViewModels

struct KeyboardInputModifier: ViewModifier {
    let vm: CalculatorViewModel

    func body(content: Content) -> some View {
        content
            .focusable()
            .onKeyPress(phases: .down) { press in
                handleKey(press)
            }
    }

    private func handleKey(_ press: KeyPress) -> KeyPress.Result {
        let key = press.key
        let ch  = press.characters

        // Digits and decimal
        if ch.count == 1 {
            let c = ch.first!
            if c.isNumber || c == "." {
                vm.buttonTapped(ch)
                return .handled
            }
        }

        // Operators
        switch key {
        case .return:
            vm.buttonTapped("=")
            return .handled
        case .escape:
            vm.buttonTapped("C")
            return .handled
        case .delete:
            // Backspace: strip last digit by re-processing all but the last char
            let current = vm.display
            guard current != "0", current != "Error", current.count > 1 else {
                vm.buttonTapped("C")
                return .handled
            }
            let trimmed = String(current.dropLast())
            vm.buttonTapped("C")
            _ = trimmed == "0" ? () : { vm.buttonTapped(trimmed) }()
            return .handled
        default:
            break
        }

        switch ch {
        case "+": vm.buttonTapped("+"); return .handled
        case "-": vm.buttonTapped("−"); return .handled
        case "*": vm.buttonTapped("×"); return .handled
        case "/": vm.buttonTapped("÷"); return .handled
        case "=": vm.buttonTapped("="); return .handled
        default: return .ignored
        }
    }
}

extension View {
    func keyboardInput(vm: CalculatorViewModel) -> some View {
        modifier(KeyboardInputModifier(vm: vm))
    }
}
