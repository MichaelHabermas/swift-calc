import SwiftUI
import ViewModels
import AppKit

@main
struct TitleRedactedCalcApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 340, height: 560)
        .commands {
            AppCommands()
        }
    }
}

// MARK: - Menu bar commands (EP-05)

struct AppCommands: Commands {
    @FocusedValue(\.calculatorViewModel) private var vm: CalculatorViewModel?

    var body: some Commands {
        // Edit menu additions
        CommandGroup(after: .pasteboard) {
            Button("Copy Result") {
                guard let vm else { return }
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(vm.display, forType: .string)
            }
            .keyboardShortcut("c", modifiers: .command)

            Button("Paste") {
                guard let vm,
                      let str = NSPasteboard.general.string(forType: .string),
                      let _ = Double(str) else { return }
                vm.buttonTapped("C")
                vm.buttonTapped(str)
            }
            .keyboardShortcut("v", modifiers: .command)
        }

        // View menu — mirror segmented control
        CommandMenu("View") {
            Button("Basic Mode") {
                vm?.setMode(.basic)
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("Scientific Mode") {
                vm?.setMode(.scientific)
            }
            .keyboardShortcut("2", modifiers: .command)

            Button("Graph Mode") {
                vm?.setMode(.graph)
            }
            .keyboardShortcut("3", modifiers: .command)
        }
    }
}

// MARK: - Focused value key for sharing ViewModel to menu commands

private struct CalcVMKey: FocusedValueKey {
    typealias Value = CalculatorViewModel
}

extension FocusedValues {
    var calculatorViewModel: CalculatorViewModel? {
        get { self[CalcVMKey.self] }
        set { self[CalcVMKey.self] = newValue }
    }
}
