# AGENTS.md — TitleRedactedCalc

AI coding agent instructions for this repository. Read this before writing any code.

---

## Project Overview

**TitleRedactedCalc** is a native macOS calculator app built entirely in Swift 6 + SwiftUI with zero
external dependencies. It ships three progressive modes — Basic, Scientific, and Graphing — packaged
as a Developer ID–signed, notarized DMG with a static marketing landing page.

| Attribute    | Value                                             |
| ------------ | ------------------------------------------------- |
| Platform     | macOS 14+ (Sonoma)                                |
| Language     | Swift 6 (100%)                                    |
| UI Framework | SwiftUI only — no AppKit, no UIKit                |
| Dependencies | Zero — no SPM, no Carthage, no CocoaPods          |
| Window       | Fixed 340×520 (Basic), 560×520 (Scientific/Graph) |
| Privacy      | Zero telemetry, zero network requests             |

---

## Architecture

The codebase follows **SOLID principles** with a strict four-layer module hierarchy. Dependencies
flow inward only — UI never imports Core directly; Core never imports UI.

```text
UIComponents → ViewModels → CoreCalculator → ExpressionParser
                         → Utilities
```

### SOLID Applied

| Principle                   | How                                                                       |
| --------------------------- | ------------------------------------------------------------------------- |
| **S** Single Responsibility | One job per file: engines compute, views render, utilities format/store   |
| **O** Open/Closed           | New mode = new engine + new view + one enum case; existing code untouched |
| **L** Liskov Substitution   | All engines conform to `CalculatorEngine`; callers never break on swap    |
| **I** Interface Segregation | `CalculatorEngine` protocol is minimal: `process`, `evaluate`, `reset`    |
| **D** Dependency Inversion  | `CalculatorViewModel` depends on the protocol, never on a concrete engine |

---

## Module & File Map

```
TitleRedactedCalc/
├── TitleRedactedCalcApp.swift          ← App entry point, WindowGroup config
├── ContentView.swift                   ← Root view, mode routing
│
├── Modules/
│   ├── CoreCalculator/
│   │   ├── Protocols/
│   │   │   └── CalculatorEngine.swift  ← Shared protocol (process/evaluate/reset)
│   │   ├── BasicCalculator.swift
│   │   ├── ScientificCalculator.swift
│   │   └── GraphingCalculator.swift    ← Also owns evaluateExpression(_:x:)
│   │
│   ├── UIComponents/
│   │   ├── CalculatorDisplay.swift
│   │   ├── CalculatorButtonStyle.swift
│   │   ├── ButtonGrid.swift
│   │   ├── ScientificButtonGrid.swift
│   │   ├── CalculatorModeToggle.swift
│   │   ├── GraphView.swift
│   │   ├── AxisOverlay.swift
│   │   ├── CrosshairOverlay.swift
│   │   ├── HistoryView.swift
│   │   └── KeyboardInputModifier.swift
│   │
│   ├── ViewModels/
│   │   ├── CalculatorViewModel.swift   ← @Observable, init(engine:), buttonTapped
│   │   └── GraphViewModel.swift        ← expression, xRange, points, samplePoints()
│   │
│   └── Utilities/
│       ├── NumberFormatter+Extensions.swift
│       └── HistoryStore.swift          ← Append + cap at 10 entries
│
├── Resources/
│   ├── Assets.xcassets/
│   └── TitleRedactedCalc.entitlements
│
└── Tests/
    ├── BasicCalculatorTests.swift
    ├── ScientificCalculatorTests.swift
    └── ViewModelTests.swift
```

---

## Key Protocols & Extension Points

### `CalculatorEngine` (the only protocol you extend to add a mode)

```swift
protocol CalculatorEngine: AnyObject {
    func process(_ input: String) -> String
    func evaluate() -> Double?
    func reset()
}
```

- All concrete engines are `final class`.
- **To add a new mode:** create a new `final class` conforming to `CalculatorEngine`, add a case to
  `CalculatorMode`, and wire it in `CalculatorViewModel`. Do not modify existing engines.

### `CalculatorViewModel`

```swift
@Observable
final class CalculatorViewModel {
    init(engine: any CalculatorEngine = BasicCalculator())
    func buttonTapped(_ title: String)
    var display: String
    var mode: CalculatorMode
    var angleUnit: AngleUnit  // .deg | .rad — Scientific mode only
}
```

### `GraphViewModel`

```swift
@Observable
final class GraphViewModel {
    var expression: String
    var xRange: ClosedRange<Double>   // default -10...10
    var points: [(x: Double, y: Double)]
    func samplePoints()               // evaluates 200 points; debounced ~100 ms
}
```

---

## Coding Conventions

- **Swift 6 strict concurrency** — all new code must compile with Swift 6 language mode enabled.
- **`@Observable` macro** — use instead of `ObservableObject`/`@Published`.
- **No AppKit** — never import AppKit. For clipboard use `NSPasteboard` only inside a `Commands`
  block.
- **No third-party packages** — any package addition requires explicit user approval.
- **No Objective-C** — no bridging headers, no `@objc` attributes unless forced by an OS API.
- **Final classes** — all engine and view model types are `final class`.
- **Formatter** — use `NumberFormatter+Extensions` for all display string formatting; do not inline
  format logic in views.
- **Error display** — invalid operations return the string `"Error"` from the engine; views display
  it verbatim. The user clears it with `C`.
- **Floating point display** — trim trailing `.0` on integers (handled by
  `NumberFormatter+Extensions`).

---

## Branch Naming

| Epic                       | Prefix              |
| -------------------------- | ------------------- |
| Core engine & architecture | `core/`             |
| Basic UI                   | `feat/basic-ui`     |
| Scientific mode            | `feat/scientific`   |
| Graphing mode              | `feat/graphing`     |
| Polish & accessibility     | `feat/polish`       |
| Packaging & distribution   | `release/`          |
| Landing page               | `feat/landing-page` |

---

## Commit Messages

Follow **Conventional Commits**:

```
feat(core): add ScientificCalculator trig functions
fix(ui): correct button grid spacing in scientific mode
test(vm): add MockCalculatorEngine isolation tests
chore(build): update build.sh notarization step
docs: update AGENTS.md module map
refactor(graph): extract samplePoints into GraphViewModel
```

Types: `feat` · `fix` · `test` · `chore` · `docs` · `refactor`

---

## Build & Test

```bash
# Build
xcodebuild -scheme TitleRedactedCalc -configuration Debug build

# Clean build (use before PR)
xcodebuild -scheme TitleRedactedCalc clean build

# Run tests
xcodebuild test -scheme TitleRedactedCalc -destination 'platform=macOS'

# Create signed DMG (requires SIGNING_IDENTITY and VERSION env vars)
./build.sh
```

Tests live in `Tests/` and cover three areas:

- `BasicCalculatorTests` — arithmetic, %, sign toggle, division by zero
- `ScientificCalculatorTests` — trig accuracy (≥10 significant figures), log/ln, power, constants
- `ViewModelTests` — DI isolation via `MockCalculatorEngine`

**CI gate:** `xcodebuild test` must pass before merging any epic branch.

---

## Definition of Done

A story or feature is **Done** when ALL of the following are true:

- [ ] Code merged into `main` via pull request from the correct feature branch
- [ ] All acceptance criteria verified and ticked off in the PR description
- [ ] Xcode shows **zero warnings, zero errors** on a clean build (`Cmd+Shift+K` → `Cmd+B`)
- [ ] **Accessibility Inspector shows zero warnings** for every view touched in the PR
- [ ] Unit tests (where applicable) pass via `xcodebuild test`
- [ ] Commit messages follow Conventional Commits
- [ ] No third-party dependencies added without explicit approval
- [ ] Both **Dark Mode and Light Mode** tested manually

---

## Hard Constraints (Never Violate)

| Constraint           | Detail                                                                      |
| -------------------- | --------------------------------------------------------------------------- |
| No AppKit views      | Zero `NSViewController`, `NSView`, or AppKit view hierarchies               |
| No external packages | No SPM, Carthage, or CocoaPods dependencies                                 |
| No Objective-C       | No bridging headers; no `.m` files                                          |
| No telemetry         | Zero network requests; zero analytics; zero data collection                 |
| macOS 14+ only       | Deployment target is macOS 14.0 (Sonoma); do not use APIs unavailable there |
| App size < 5 MB      | Final `.app` bundle must remain under 5 MB before DMG creation              |
| Graph performance    | 200 sampled points must evaluate in < 100 ms on M1                          |
| Accessibility        | Zero Accessibility Inspector warnings before any release build              |

---

## Epics at a Glance

| ID    | Title                            | Branch              | Phase      | Priority |
| ----- | -------------------------------- | ------------------- | ---------- | -------- |
| EP-01 | Core Engine & SOLID Architecture | `core/`             | Day 1 AM   | Critical |
| EP-02 | Basic Calculator UI              | `feat/basic-ui`     | Day 1 PM   | Critical |
| EP-03 | Scientific Calculator Mode       | `feat/scientific`   | Day 2 AM   | High     |
| EP-04 | Graphing Calculator Mode         | `feat/graphing`     | Day 2 PM   | High     |
| EP-05 | Polish & Accessibility           | `feat/polish`       | Day 2 Late | Medium   |
| EP-06 | Packaging & Distribution         | `release/`          | Day 2 Eve  | High     |
| EP-07 | Marketing Landing Page           | `feat/landing-page` | Day 2 Eve  | Medium   |

Full epic → feature → user story → task breakdown: `docs/PRD-v2.md` Reference implementation
snippets: `SNIPPETS.md`

---

## Phase Gates

Before moving between phases, verify manually:

1. **EP-01 → EP-02**: engines + VM DI work; all basic inputs render and evaluate correctly.
2. **EP-02 done**: pixel-perfect 4×5 grid; keyboard input covers
   digits/operators/backspace/enter/escape/decimal; window is fixed size.
3. **EP-03/EP-04 done**: mode switching animates; DEG/RAD trig is accurate; graph updates within 100
   ms; crosshair snaps and shows coordinates; history caps at 10.
4. **EP-05 done**: Accessibility Inspector zero warnings; Cmd+C/Cmd+V work; View menu mirrors
   segmented control.
5. **EP-06 done**: DMG installs cleanly on a clean Mac account with no Gatekeeper warnings.
6. **EP-07 done**: landing page renders on desktop and mobile; Lighthouse ≥ 90 all categories; DMG
   link works end-to-end.

---

## Success Metrics (Release Target)

| Metric                    | Target              |
| ------------------------- | ------------------- |
| Downloads (Month 1)       | 500+                |
| Lighthouse score          | ≥ 90 all categories |
| App bundle size           | < 5 MB              |
| Accessibility warnings    | 0                   |
| Graph render time (M1)    | < 100 ms            |
| User satisfaction         | ≥ 4.5 / 5.0         |
| Support tickets (Month 1) | < 10                |
