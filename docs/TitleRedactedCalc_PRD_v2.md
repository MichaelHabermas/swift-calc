**TitleRedactedCalc**

Product Requirements Document

*v2.0 --- Engineering Edition*

  ----------------- -----------------
  **Platform**      macOS 14+

  **Stack**         Swift 6 · SwiftUI
                    · Zero external
                    deps

  **Target**        Ship in 1--2 days

  **Version**       2.0

  **Status**        Ready for
                    Engineering
  ----------------- -----------------

**1. Product Overview**

TitleRedactedCalc is a native macOS calculator application built
entirely in SwiftUI with a pure Swift math engine. It ships in three
progressive modes --- Basic, Scientific, and Graphing --- with a landing
page and DMG installer.

*Architecture follows SOLID principles throughout: each module has a
single responsibility, behaviour is extended via protocols (never by
modifying existing code), and the ViewModel depends on a
CalculatorEngine abstraction rather than any concrete implementation.
This keeps every layer independently testable and swappable.*

------------------------------------------------------------------------

**2. Epic Overview**

  ----------- ----------------------- ----------- -------------- ------------ -------------------
  **ID**      **Epic Title**          **Phase**   **Priority**   **Points**   **Branch Prefix**

  **EP-01**   Core Calculator Engine  Phase 1     Critical       21           core/
              & SOLID Architecture                                            

  **EP-02**   Basic Calculator UI     Phase 1     Critical       13           feat/basic-ui

  **EP-03**   Scientific Calculator   Phase 2     High           13           feat/scientific
              Mode                                                            

  **EP-04**   Graphing Calculator     Phase 2     High           21           feat/graphing
              Mode                                                            

  **EP-05**   History, Polish &       Phase 2     Medium         8            feat/polish
              Accessibility                                                   

  **EP-06**   Packaging &             Phase 3     High           8            release/
              Distribution                                                    

  **EP-07**   Marketing Landing Page  Phase 4     Medium         5            feat/landing-page
  ----------- ----------------------- ----------- -------------- ------------ -------------------

  -----------------------------------------------------------------
  **EP-01 · Core Calculator Engine & SOLID Architecture**

  -----------------------------------------------------------------

+-----------------------------------------------------------------+
| **EP-01 Core Calculator Engine & SOLID Architecture**           |
+-----------------------------------------------------------------+
| **Goal:** Define all protocols, data models, and calculator     |
| engine implementations that the rest of the app depends upon.   |
| Nothing should be built until this foundation is solid.         |
|                                                                 |
| **Priority: Critical Story Points: 21 Phase: Phase 1 -- Day 1   |
| Morning**                                                       |
+-----------------------------------------------------------------+

**User Stories**

+-----------------------------------------------------------------+
| **US-01 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* a clean CalculatorEngine         |
| protocol with process() and evaluate() methods*, so that* I can |
| swap engine implementations without changing any view or        |
| viewModel code                                                  |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 1.  CalculatorEngine protocol exists in                         |
|     Modules/CoreCalculator/Protocols/                           |
|                                                                 |
| 2.  Protocol has process(\_ input: String) -\> String and       |
|     evaluate() -\> Double?                                      |
|                                                                 |
| 3.  BasicCalculator, ScientificCalculator, GraphingCalculator   |
|     all conform                                                 |
|                                                                 |
| 4.  All concrete types are final classes                        |
|                                                                 |
| 5.  Zero AppKit imports anywhere                                |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-02 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* a CalculatorViewModel that takes |
| a CalculatorEngine via dependency injection*, so that* the      |
| ViewModel is testable in isolation without any UI               |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 6.  CalculatorViewModel.init(engine:) accepts any               |
|     CalculatorEngine                                            |
|                                                                 |
| 7.  Default parameter is BasicCalculator()                      |
|                                                                 |
| 8.  \@Observable macro used (Swift 5.9+)                        |
|                                                                 |
| 9.  No direct references to UIKit or AppKit                     |
|                                                                 |
| 10. Unit test instantiates VM with a MockCalculatorEngine       |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-03 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* BasicCalculator to implement all |
| four arithmetic operations plus % and sign-toggle*, so that*    |
| basic users get a complete, correct arithmetic experience       |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 11. add, subtract, multiply, divide all return correct Double   |
|                                                                 |
| 12. Division by zero returns \'Error\' string                   |
|                                                                 |
| 13. Percentage converts current display to /100                 |
|                                                                 |
| 14. Sign toggle flips positive/negative                         |
|                                                                 |
| 15. Floating point display is trimmed (no trailing .0 on        |
|     integers)                                                   |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-04 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* ScientificCalculator to extend   |
| BasicCalculator\'s capabilities via the same CalculatorEngine   |
| protocol*, so that* scientific mode can be swapped in with zero |
| breaking changes to Views                                       |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 16. Implements sin, cos, tan in degrees and radians             |
|                                                                 |
| 17. Implements log₁₀, ln, x², √, xʸ, π, e                       |
|                                                                 |
| 18. All trig results accurate to at least 10 significant        |
|     figures                                                     |
|                                                                 |
| 19. Conforms to CalculatorEngine (no extra protocol needed)     |
|                                                                 |
| 20. Swapping engine in VM is one line of code change            |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-05 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* GraphingCalculator to evaluate a |
| String expression across an x range*, so that* the graph view   |
| has a clean data-provider it can call without knowing           |
| implementation details                                          |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 21. evaluateExpression(\_ expr: String, x: Double) -\> Double?  |
|     method exists                                               |
|                                                                 |
| 22. Supports x, sin(x), cos(x), x², x\^n forms                  |
|                                                                 |
| 23. Returns nil for undefined/complex results                   |
|                                                                 |
| 24. Performance: 200 points evaluated in \< 5 ms on M1          |
|                                                                 |
| 25. No UI dependencies imported                                 |
+-----------------------------------------------------------------+

**Features**

  ----------------- -------------------------------------------------
  **FEAT-01**       **CalculatorEngine Protocol Suite**

  **Description**   Define the core protocol and all concrete engine
                    implementations

  **Linked          **US-01 • US-02 • US-03 • US-04 • US-05**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-02**       **Dependency Injection ViewModel**

  **Description**   CalculatorViewModel accepting any
                    CalculatorEngine, with \@Observable and full unit
                    test coverage

  **Linked          **US-02**
  Stories**         
  ----------------- -------------------------------------------------

**Feature Branch & Commits**

+-----------------------------------------------------------------+
| **⎇ core/calculator-engine**                                    |
|                                                                 |
| All engine protocols, implementations, and ViewModel DI         |
+-----------------------------------------------------------------+

**Commits**

  ------------- -------------- -----------------------------------------------------
  **Hash**      **Type**       **Commit Message**

  **a1b2c3d**   **chore**      chore: scaffold Xcode SwiftUI macOS project, set
                               deployment target macOS 14

  **b2c3d4e**   **feat**       feat: add CalculatorEngine protocol with process(\_:)
                               and evaluate()

  **c3d4e5f**   **feat**       feat: implement BasicCalculator -- arithmetic,
                               percent, sign toggle

  **d4e5f6a**   **feat**       feat: implement ScientificCalculator -- trig, log,
                               power, constants

  **e5f6a7b**   **feat**       feat: implement
                               GraphingCalculator.evaluateExpression(\_:x:)

  **f6a7b8c**   **feat**       feat: add CalculatorViewModel with DI init(engine:)
                               and \@Observable

  **a7b8c9d**   **test**       test: unit tests -- BasicCalculator arithmetic edge
                               cases

  **b8c9d0e**   **test**       test: unit tests -- ScientificCalculator trig
                               accuracy

  **c9d0e1f**   **test**       test: unit tests -- ViewModel with
                               MockCalculatorEngine

  **d0e1f2a**   **refactor**   refactor: trim trailing .0 from Double display in
                               NumberFormatter+Extensions
  ------------- -------------- -----------------------------------------------------

**Subtasks**

  -------------- ------------------------------------------------- --------------
  **Task ID**    **Subtask Description**                           **Estimate**

  **ST-01-01**   Create Xcode project: File → New → macOS → App,   **30 min**
                 name TitleRedactedCalc, SwiftUI lifecycle         

  **ST-01-02**   Set deployment target to macOS 14.0 in project    **5 min**
                 settings                                          

  **ST-01-03**   Create folder structure:                          **10 min**
                 Modules/CoreCalculator/Protocols/, UIComponents/, 
                 ViewModels/, Utilities/                           

  **ST-01-04**   Write CalculatorEngine.swift protocol with        **20 min**
                 process(\_:) and evaluate()                       

  **ST-01-05**   Write BasicCalculator.swift -- handle C, ±, %, ÷, **60 min**
                 ×, −, +, =, digits 0-9, decimal                   

  **ST-01-06**   Write ScientificCalculator.swift -- sin, cos,     **60 min**
                 tan, log, ln, x², √, \^, π, e                     

  **ST-01-07**   Write GraphingCalculator.swift -- expression      **45 min**
                 parser and evaluateExpression                     

  **ST-01-08**   Write CalculatorViewModel.swift with              **30 min**
                 \@Observable, init(engine:), buttonTapped(\_:)    

  **ST-01-09**   Write NumberFormatter+Extensions.swift to clean   **20 min**
                 up Double → String display                        

  **ST-01-10**   Write 5 unit tests covering arithmetic,           **45 min**
                 divide-by-zero, trig, and VM isolation            
  -------------- ------------------------------------------------- --------------

  -----------------------------------------------------------------
  **EP-02 · Basic Calculator UI**

  -----------------------------------------------------------------

+-----------------------------------------------------------------+
| **EP-02 Basic Calculator UI**                                   |
+-----------------------------------------------------------------+
| **Goal:** Ship a polished, native-feeling basic calculator      |
| window that a first-time macOS user finds immediately familiar. |
| Keyboard support and dark/light mode are non-negotiable.        |
|                                                                 |
| **Priority: Critical Story Points: 13 Phase: Phase 1 -- Day 1   |
| Afternoon**                                                     |
+-----------------------------------------------------------------+

**User Stories**

+-----------------------------------------------------------------+
| **US-06 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **user***, I want* a large numeric display that clearly  |
| shows my current input and result*, so that* I never misread a  |
| number mid-calculation                                          |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 26. Display uses SF font, size ≥ 48pt                           |
|                                                                 |
| 27. Adapts size down if number exceeds 9 digits                 |
|                                                                 |
| 28. Right-aligned within the display area                       |
|                                                                 |
| 29. Shows \'Error\' string on invalid ops                       |
|                                                                 |
| 30. Dark/light mode adapts automatically                        |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-07 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **user***, I want* a 4×5 button grid matching Apple\'s   |
| layout (C, ±, %, ÷, 7-9, ×, 4-6, −, 1-3, +, 0, ., =)*, so that* |
| muscle memory from iOS Calculator works immediately on Mac      |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 31. Grid matches Apple\'s standard layout exactly               |
|                                                                 |
| 32. Orange accent on operator buttons (÷ × − +)                 |
|                                                                 |
| 33. Gray on utility buttons (C ± %)                             |
|                                                                 |
| 34. Dark gray on digit buttons                                  |
|                                                                 |
| 35. = button is orange, full width of last column               |
|                                                                 |
| 36. Buttons have hover and press states                         |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-08 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **user***, I want* keyboard input to work for all digit  |
| and operator keys*, so that* I can calculate at typing speed    |
| without touching the mouse                                      |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 37. 0-9 trigger corresponding digit buttons                     |
|                                                                 |
| 38. \+ - \* / trigger operators                                 |
|                                                                 |
| 39. Return or Enter triggers =                                  |
|                                                                 |
| 40. Escape triggers C (clear)                                   |
|                                                                 |
| 41. Backspace deletes last digit                                |
|                                                                 |
| 42. Period/comma triggers decimal input                         |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-09 USER STORY 2 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **user***, I want* the window to be a fixed,             |
| non-resizable size (340 × 520 pt)*, so that* the app looks      |
| intentional and polished rather than stretched                  |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 43. Window fixed at 340 × 520                                   |
|                                                                 |
| 44. No resize handle                                            |
|                                                                 |
| 45. Window title bar hidden or minimal                          |
|                                                                 |
| 46. App icon shown in Dock                                      |
|                                                                 |
| 47. Window centers on first launch                              |
+-----------------------------------------------------------------+

**Features**

  ----------------- -------------------------------------------------
  **FEAT-03**       **CalculatorDisplay Component**

  **Description**   Adaptive, right-aligned display view consuming
                    ViewModel\'s display string

  **Linked          **US-06**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-04**       **ButtonGrid Component**

  **Description**   4×5 grid with correct layout, colours,
                    hover/press states

  **Linked          **US-07**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-05**       **Keyboard Input Handler**

  **Description**   .onKeyPress modifier wired to ViewModel

  **Linked          **US-08**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-06**       **Window Configuration**

  **Description**   Fixed window size, no resize, centered on launch

  **Linked          **US-09**
  Stories**         
  ----------------- -------------------------------------------------

**Feature Branch & Commits**

+-----------------------------------------------------------------+
| **⎇ feat/basic-ui**                                             |
|                                                                 |
| All SwiftUI views for basic calculator mode                     |
+-----------------------------------------------------------------+

**Commits**

  ------------- ----------- -----------------------------------------------------
  **Hash**      **Type**    **Commit Message**

  **e1f2a3b**   **feat**    feat: add CalculatorDisplay view with adaptive font
                            size

  **f2a3b4c**   **feat**    feat: add CalculatorButtonStyle with orange/gray/dark
                            variants

  **a3b4c5d**   **feat**    feat: build ButtonGrid using SwiftUI Grid layout

  **b4c5d6e**   **feat**    feat: wire ButtonGrid buttons to
                            CalculatorViewModel.buttonTapped(\_:)

  **c5d6e7f**   **feat**    feat: add keyboard support via .onKeyPress modifier

  **d6e7f8a**   **feat**    feat: configure fixed 340×520 window in
                            TitleRedactedCalcApp.swift

  **e7f8a9b**   **feat**    feat: hide traffic lights / set minimal title bar

  **f8a9b0c**   **fix**     fix: clamp display font to prevent overflow on large
                            numbers

  **a9b0c1d**   **chore**   chore: add app accent color and dark mode color
                            assets

  **b0c1d2e**   **chore**   chore: add placeholder 1024×1024 app icon
  ------------- ----------- -----------------------------------------------------

**Subtasks**

  -------------- ------------------------------------------------- --------------
  **Task ID**    **Subtask Description**                           **Estimate**

  **ST-02-01**   Create CalculatorDisplay.swift -- Text view,      **30 min**
                 adaptive font, right-aligned                      

  **ST-02-02**   Create CalculatorButtonStyle.swift -- colour      **30 min**
                 variants via enum (utility/digit/operator/equals) 

  **ST-02-03**   Create ButtonGrid.swift using SwiftUI Grid and    **45 min**
                 GridRow                                           

  **ST-02-04**   Wire all button titles to                         **20 min**
                 ViewModel.buttonTapped()                          

  **ST-02-05**   Implement hover state (onHover modifier) and      **20 min**
                 press state (DragGesture or .buttonStyle)         

  **ST-02-06**   Add keyboard shortcuts via .focusable() +         **30 min**
                 .onKeyPress(\_:)                                  

  **ST-02-07**   Set window size in WindowGroup /                  **20 min**
                 .windowResizability(.contentSize)                 

  **ST-02-08**   Set window position to screen center on first     **15 min**
                 launch                                            

  **ST-02-09**   Add color assets (AccentColor.colorset) for       **20 min**
                 operator orange, dark/light bg                    

  **ST-02-10**   Manual test: all 19 buttons, keyboard input,      **30 min**
                 dark/light toggle, resize locked                  
  -------------- ------------------------------------------------- --------------

  -----------------------------------------------------------------
  **EP-03 · Scientific Calculator Mode**

  -----------------------------------------------------------------

+-----------------------------------------------------------------+
| **EP-03 Scientific Calculator Mode**                            |
+-----------------------------------------------------------------+
| **Goal:** Add a second view mode with expanded button layout    |
| for trigonometry, logarithms, powers, and constants. Engine     |
| swap must be one line of code.                                  |
|                                                                 |
| **Priority: High Story Points: 13 Phase: Phase 2 -- Day 2       |
| Morning**                                                       |
+-----------------------------------------------------------------+

**User Stories**

+-----------------------------------------------------------------+
| **US-10 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **power user***, I want* to switch to Scientific mode    |
| from a segmented control*, so that* I don\'t need a separate    |
| app for advanced maths                                          |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 48. Segmented control appears at top: Basic \| Scientific \|    |
|     Graph                                                       |
|                                                                 |
| 49. Switching modes animates the button grid                    |
|                                                                 |
| 50. Window width expands to 560 pt in Scientific mode           |
|                                                                 |
| 51. Switching back to Basic returns to 340 pt                   |
|                                                                 |
| 52. No data loss when switching (display preserved)             |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-11 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **power user***, I want* buttons for sin, cos, tan, log, |
| ln, x², √, π, e, and xʸ*, so that* I can perform academic and   |
| engineering calculations without leaving the app                |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 53. All 10 scientific functions are present and accessible      |
|                                                                 |
| 54. π inserts 3.14159... into display                           |
|                                                                 |
| 55. e inserts 2.71828... into display                           |
|                                                                 |
| 56. sin/cos/tan accept degree or radian input (toggle present)  |
|                                                                 |
| 57. xʸ waits for second operand then raises to power            |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-12 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **power user***, I want* a Deg/Rad toggle that persists  |
| within the session*, so that* I can switch between degrees and  |
| radians without losing context                                  |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 58. Toggle visible in Scientific mode only                      |
|                                                                 |
| 59. State stored in ViewModel, not engine                       |
|                                                                 |
| 60. Toggling immediately recomputes if last result was a trig   |
|     result                                                      |
|                                                                 |
| 61. Label clearly shows current mode (DEG / RAD)                |
|                                                                 |
| 62. Defaults to DEG on launch                                   |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-13 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **power user***, I want* a calculation history list      |
| showing the last 10 expressions*, so that* I can audit my work  |
| without re-entering expressions                                 |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 63. History list appears below display when in Scientific or    |
|     Graphing mode                                               |
|                                                                 |
| 64. Each entry shows expression and result                      |
|                                                                 |
| 65. Tapping an entry populates display with result              |
|                                                                 |
| 66. List clears when C is pressed and held (long press)         |
|                                                                 |
| 67. Scrollable, max 10 items, oldest drops off                  |
+-----------------------------------------------------------------+

**Features**

  ----------------- -------------------------------------------------
  **FEAT-07**       **Mode Segmented Control**

  **Description**   CalculatorModeToggle view, animated transitions,
                    window resize

  **Linked          **US-10**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-08**       **Scientific Button Grid**

  **Description**   Expanded grid with all 10 scientific functions
                    plus Deg/Rad toggle

  **Linked          **US-11 • US-12**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-09**       **Calculation History**

  **Description**   HistoryView component, HistoryStore model,
                    clear-on-long-press

  **Linked          **US-13**
  Stories**         
  ----------------- -------------------------------------------------

**Feature Branch & Commits**

+-----------------------------------------------------------------+
| **⎇ feat/scientific-mode**                                      |
|                                                                 |
| Scientific engine, expanded button grid, Deg/Rad toggle,        |
| history                                                         |
+-----------------------------------------------------------------+

**Commits**

  ------------- ---------- -----------------------------------------------------
  **Hash**      **Type**   **Commit Message**

  **c1d2e3f**   **feat**   feat: add CalculatorMode enum
                           (basic/scientific/graph)

  **d2e3f4a**   **feat**   feat: add CalculatorModeToggle segmented control view

  **e3f4a5b**   **feat**   feat: animate window width change on mode switch (340
                           → 560)

  **f4a5b6c**   **feat**   feat: build ScientificButtonGrid with 10 extra
                           function buttons

  **a5b6c7d**   **feat**   feat: add Deg/Rad toggle stored in ViewModel

  **b6c7d8e**   **feat**   feat: wire trig buttons through ScientificCalculator
                           engine

  **c7d8e9f**   **feat**   feat: wire log, ln, x², √, π, e, xʸ

  **d8e9f0a**   **feat**   feat: add HistoryStore (ObservableObject, last 10
                           entries)

  **e9f0a1b**   **feat**   feat: build HistoryView list component

  **f0a1b2c**   **feat**   feat: long-press C to clear history

  **a1b2c3e**   **test**   test: unit test ScientificCalculator trig edge cases
                           (0, 90, 180 deg)
  ------------- ---------- -----------------------------------------------------

**Subtasks**

  -------------- ------------------------------------------------- --------------
  **Task ID**    **Subtask Description**                           **Estimate**

  **ST-03-01**   Add CalculatorMode enum with cases .basic,        **15 min**
                 .scientific, .graph                               

  **ST-03-02**   Add \@Published var mode: CalculatorMode to       **10 min**
                 CalculatorViewModel                               

  **ST-03-03**   Build CalculatorModeToggle.swift as a             **20 min**
                 Picker(.segmented)                                

  **ST-03-04**   Animate window width in TitleRedactedCalcApp      **30 min**
                 using .frame(width:) + withAnimation              

  **ST-03-05**   Build ScientificButtonGrid.swift with rows for    **45 min**
                 scientific functions                              

  **ST-03-06**   Add degRadMode: Bool to ViewModel; toggle button  **20 min**
                 in ScientificButtonGrid                           

  **ST-03-07**   Implement trig, log, power routing in             **45 min**
                 ScientificCalculator.process()                    

  **ST-03-08**   Create HistoryEntry struct (id, expression,       **10 min**
                 result, date)                                     

  **ST-03-09**   Create HistoryStore: append on evaluate(), capped **20 min**
                 at 10                                             

  **ST-03-10**   Build HistoryView: List of HistoryEntry rows, tap **30 min**
                 to restore                                        

  **ST-03-11**   Add long-press gesture on C button to trigger     **20 min**
                 history.clear()                                   

  **ST-03-12**   Manual test: all trig functions in deg and rad,   **30 min**
                 history cap, restore flow                         
  -------------- ------------------------------------------------- --------------

  -----------------------------------------------------------------
  **EP-04 · Graphing Calculator Mode**

  -----------------------------------------------------------------

+-----------------------------------------------------------------+
| **EP-04 Graphing Calculator Mode**                              |
+-----------------------------------------------------------------+
| **Goal:** Render a real-time interactive graph of y = f(x).     |
| User types an expression, graph updates live. Pinch-to-zoom and |
| pan gesture supported.                                          |
|                                                                 |
| **Priority: High Story Points: 21 Phase: Phase 2 -- Day 2       |
| Afternoon**                                                     |
+-----------------------------------------------------------------+

**User Stories**

+-----------------------------------------------------------------+
| **US-14 USER STORY 8 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **student***, I want* to type a function like sin(x) or  |
| x² and see a live graph immediately*, so that* I can explore    |
| mathematical behaviour without a separate graphing tool         |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 68. Graph updates within 100 ms of last keystroke               |
|                                                                 |
| 69. Supported functions: x², sin(x), cos(x), tan(x), ln(x),     |
|     x\^n                                                        |
|                                                                 |
| 70. Graph renders 200 sampled points across the visible x-range |
|                                                                 |
| 71. Undefined points (tan discontinuities, ln(negative)) leave  |
|     a gap                                                       |
|                                                                 |
| 72. Y-axis auto-scales to the visible range                     |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-15 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **student***, I want* axis labels and grid lines on the  |
| graph*, so that* I can read coordinates and understand scale at |
| a glance                                                        |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 73. X and Y axes drawn with contrasting color                   |
|                                                                 |
| 74. Grid lines every 1 unit (or scaled unit if zoomed)          |
|                                                                 |
| 75. Axis labels at each gridline intersection                   |
|                                                                 |
| 76. Origin is labeled (0,0)                                     |
|                                                                 |
| 77. Labels adapt size for dark and light mode                   |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-16 USER STORY 5 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **student***, I want* to pinch-to-zoom and pan the graph |
| with trackpad gestures*, so that* I can explore different       |
| ranges without typing new values                                |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 78. Pinch gesture changes x-range symmetrically                 |
|                                                                 |
| 79. Two-finger pan shifts the viewport                          |
|                                                                 |
| 80. Min zoom: x in -1000...1000; Max zoom: x in -0.01...0.01    |
|                                                                 |
| 81. Zoom resets to x in -10...10 on double-click                |
|                                                                 |
| 82. Graph immediately re-samples after gesture ends             |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-17 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **student***, I want* to see a crosshair with            |
| coordinates when I hover over the graph*, so that* I can read   |
| exact values at any point                                       |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 83. Crosshair appears on hover (mouse move)                     |
|                                                                 |
| 84. Shows (x, f(x)) value at cursor position                    |
|                                                                 |
| 85. Snaps to nearest calculated point                           |
|                                                                 |
| 86. Crosshair hides when cursor leaves graph area               |
|                                                                 |
| 87. Coordinates shown to 4 decimal places                       |
+-----------------------------------------------------------------+

**Features**

  ----------------- -------------------------------------------------
  **FEAT-10**       **Real-Time Graph Renderer**

  **Description**   GraphView using Swift Charts LineMark,
                    live-updates on expression change

  **Linked          **US-14**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-11**       **Axis & Grid Overlay**

  **Description**   Overlay view drawing axes, grid lines, and labels

  **Linked          **US-15**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-12**       **Gesture Controls**

  **Description**   Pinch-to-zoom, two-finger pan, double-click reset

  **Linked          **US-16**
  Stories**         
  ----------------- -------------------------------------------------

  ----------------- -------------------------------------------------
  **FEAT-13**       **Hover Crosshair**

  **Description**   Crosshair overlay with coordinate readout

  **Linked          **US-17**
  Stories**         
  ----------------- -------------------------------------------------

**Feature Branch & Commits**

+-----------------------------------------------------------------+
| **⎇ feat/graphing-mode**                                        |
|                                                                 |
| Graph view, axes, gesture zoom/pan, hover crosshair             |
+-----------------------------------------------------------------+

**Commits**

  ------------- ---------- -----------------------------------------------------
  **Hash**      **Type**   **Commit Message**

  **b2c3d4f**   **feat**   feat: add GraphViewModel with xRange, expression, and
                           points \[\]

  **c3d4e5a**   **feat**   feat: implement samplePoints() in GraphingCalculator
                           -- 200 pts

  **d4e5f6b**   **feat**   feat: build GraphView using Swift Charts LineMark

  **e5f6a7c**   **feat**   feat: add AxisOverlay drawing x/y lines and grid

  **f6a7b8d**   **feat**   feat: add axis labels adapting to current xRange
                           scale

  **a7b8c9e**   **feat**   feat: implement MagnifyGesture for pinch-to-zoom on
                           graph

  **b8c9d0f**   **feat**   feat: implement DragGesture for two-finger pan

  **c9d0e1a**   **feat**   feat: double-click resets to default x range -10...10

  **d0e1f2b**   **feat**   feat: add CrosshairOverlay with onHover mouse
                           tracking

  **e1f2a3c**   **feat**   feat: expression text field in graph mode wired to
                           GraphViewModel

  **f2a3b4d**   **fix**    fix: skip NaN/Inf points to leave gaps at
                           discontinuities

  **a3b4c5e**   **test**   test: snapshot test graph renders for sin(x) in
                           default range
  ------------- ---------- -----------------------------------------------------

**Subtasks**

  -------------- ------------------------------------------------- --------------
  **Task ID**    **Subtask Description**                           **Estimate**

  **ST-04-01**   Create GraphPoint struct (x: Double, y: Double),  **10 min**
                 Identifiable                                      

  **ST-04-02**   Add GraphViewModel: \@Observable, expression:     **20 min**
                 String, xRange, points                            

  **ST-04-03**   Implement samplePoints() -- map range to 200 x    **30 min**
                 values, call evaluateExpression()                 

  **ST-04-04**   Build GraphView.swift using Chart { LineMark }    **40 min**
                 with point data                                   

  **ST-04-05**   Build AxisOverlay using Canvas or Path for axes   **45 min**
                 and grid lines                                    

  **ST-04-06**   Add dynamic axis label view that adjusts to       **30 min**
                 xRange scale                                      

  **ST-04-07**   Add .onReceive of expression changes to           **20 min**
                 debounce + re-sample (100 ms)                     

  **ST-04-08**   Implement MagnifyGesture handler: shrink/expand   **30 min**
                 xRange, clamp bounds                              

  **ST-04-09**   Implement DragGesture handler: shift xRange by    **25 min**
                 drag delta                                        

  **ST-04-10**   Add TapGesture (count: 2) to reset xRange to      **10 min**
                 -10...10                                          

  **ST-04-11**   Build CrosshairOverlay: onHover tracks mouse,     **40 min**
                 snaps to nearest point                            

  **ST-04-12**   Add graph expression TextField above graph in     **15 min**
                 graphing mode                                     

  **ST-04-13**   Manual test: sin(x), cos(x), x², x\^3, ln(x),     **30 min**
                 tan(x) discontinuities                            
  -------------- ------------------------------------------------- --------------

  -----------------------------------------------------------------
  **EP-05 · History, Polish & Accessibility**

  -----------------------------------------------------------------

+-----------------------------------------------------------------+
| **EP-05 History, Polish & Accessibility**                       |
+-----------------------------------------------------------------+
| **Goal:** Final quality pass: VoiceOver labels, animations,     |
| error states, menubar integration, and anything that makes the  |
| app feel like a 5-star product on the App Store.                |
|                                                                 |
| **Priority: Medium Story Points: 8 Phase: Phase 2 -- Day 2 Late |
| Afternoon**                                                     |
+-----------------------------------------------------------------+

**User Stories**

+-----------------------------------------------------------------+
| **US-18 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **VoiceOver user***, I want* every button to have an     |
| accessibility label and hint*, so that* I can use the           |
| calculator fully without sight                                  |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 88. Every button has .accessibilityLabel and .accessibilityHint |
|                                                                 |
| 89. Display reads out current value on change                   |
|                                                                 |
| 90. Error state says \'Error, press C to clear\'                |
|                                                                 |
| 91. VoiceOver navigation order follows reading order            |
|                                                                 |
| 92. App passes Accessibility Inspector with zero warnings       |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-19 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **user***, I want* smooth animations when switching      |
| modes and clearing the display*, so that* the app feels premium |
| and responsive                                                  |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 93. Mode switch: 0.3 s ease-in-out animation                    |
|                                                                 |
| 94. Button press: 0.05 s scale-down feedback                    |
|                                                                 |
| 95. Display flip animation on = pressed                         |
|                                                                 |
| 96. Clear animation: display fades to 0 then back               |
|                                                                 |
| 97. No janky redraws or layout jumps                            |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-20 USER STORY 2 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **user***, I want* a macOS menu bar item (Edit → Copy    |
| Result) so I can paste my result anywhere*, so that* I don\'t   |
| need to manually select and copy the display text               |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 98. ⌘C in focus copies display value to pasteboard              |
|                                                                 |
| 99. Menu: Edit → Copy Result (⌘C)                               |
|                                                                 |
| 100. Menu: Edit → Paste (⌘V) pastes a number into display       |
|                                                                 |
| 101. Menu: View → Basic / Scientific / Graph mirrors the        |
|      segmented control                                          |
|                                                                 |
| 102. App menu shows correct About box with version              |
+-----------------------------------------------------------------+

**Feature Branch & Commits**

+-----------------------------------------------------------------+
| **⎇ feat/polish-accessibility**                                 |
|                                                                 |
| Accessibility labels, animations, menu bar, final QA            |
+-----------------------------------------------------------------+

**Commits**

  ------------- ----------- -----------------------------------------------------
  **Hash**      **Type**    **Commit Message**

  **b4c5d6f**   **feat**    feat: add .accessibilityLabel and .accessibilityHint
                            to all buttons

  **c5d6e7a**   **feat**    feat: add .accessibilityValue to display (announces
                            on change)

  **d6e7f8b**   **feat**    feat: add mode switch animation .easeInOut(duration:
                            0.3)

  **e7f8a9c**   **feat**    feat: add button press scale animation

  **f8a9b0d**   **feat**    feat: add display clear fade animation

  **a9b0c1e**   **feat**    feat: implement Edit → Copy Result and ⌘C shortcut

  **b0c1d2f**   **feat**    feat: implement Edit → Paste number into display

  **c1d2e3a**   **feat**    feat: add View menu mirroring mode segmented control

  **d2e3f4b**   **chore**   chore: set CFBundleShortVersionString to 1.0.0 in
                            Info.plist

  **e3f4a5c**   **fix**     fix: pass Accessibility Inspector zero-warning audit
  ------------- ----------- -----------------------------------------------------

**Subtasks**

  -------------- ------------------------------------------------- --------------
  **Task ID**    **Subtask Description**                           **Estimate**

  **ST-05-01**   Audit every button in ButtonGrid and              **30 min**
                 ScientificButtonGrid, add .accessibilityLabel     

  **ST-05-02**   Add .accessibilityValue(viewModel.display) to     **10 min**
                 CalculatorDisplay                                 

  **ST-05-03**   Wrap mode switch in                               **10 min**
                 withAnimation(.easeInOut(duration: 0.3))          

  **ST-05-04**   Add .scaleEffect on button tap via \@State        **20 min**
                 isPressed bool                                    

  **ST-05-05**   Add .transition(.opacity) on display clear        **15 min**

  **ST-05-06**   Add Commands block in App struct for Edit and     **30 min**
                 View menus                                        

  **ST-05-07**   Wire ⌘C to                                        **15 min**
                 NSPasteboard.general.setString(display)           

  **ST-05-08**   Wire ⌘V to parse clipboard string into display if **20 min**
                 valid number                                      

  **ST-05-09**   Run Accessibility Inspector, fix any remaining    **30 min**
                 warnings                                          

  **ST-05-10**   Final manual test pass: all modes, all gestures,  **30 min**
                 all keyboard shortcuts                            
  -------------- ------------------------------------------------- --------------

  -----------------------------------------------------------------
  **EP-06 · Packaging & Distribution**

  -----------------------------------------------------------------

+-----------------------------------------------------------------+
| **EP-06 Packaging & Distribution**                              |
+-----------------------------------------------------------------+
| **Goal:** Archive the app, sign it with Developer ID, create a  |
| DMG with drag-to-Applications, and publish a notarised          |
| download.                                                       |
|                                                                 |
| **Priority: High Story Points: 8 Phase: Phase 3 -- Day 2        |
| Evening**                                                       |
+-----------------------------------------------------------------+

**User Stories**

+-----------------------------------------------------------------+
| **US-21 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **end user***, I want* to download a DMG that I drag to  |
| Applications and double-click to launch*, so that* I can        |
| install the app in under 30 seconds with zero friction          |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 103. DMG mounts cleanly, shows app icon + Applications alias    |
|                                                                 |
| 104. App launches without Gatekeeper warnings                   |
|                                                                 |
| 105. No quarantine attribute blockers for signed builds         |
|                                                                 |
| 106. DMG background is clean (no text spam)                     |
|                                                                 |
| 107. File size \< 5 MB                                          |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-22 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* a CI-compatible build script     |
| that produces the DMG in one command*, so that* any team member |
| can cut a release without knowing Xcode internals               |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 108. build.sh accepts VERSION and SIGNING_IDENTITY env vars     |
|                                                                 |
| 109. Runs xcodebuild archive → export → hdiutil in sequence     |
|                                                                 |
| 110. Exits non-zero on any failure                              |
|                                                                 |
| 111. Outputs TitleRedactedCalc-{version}.dmg in dist/           |
|                                                                 |
| 112. README documents the one-line release command              |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-23 USER STORY 2 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* the app to pass Apple            |
| notarisation so downloaded builds run on any Mac*, so that*     |
| users on fresh Macs can open it without disabling Gatekeeper    |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 113. App signed with Developer ID Application certificate       |
|                                                                 |
| 114. Hardened Runtime enabled                                   |
|                                                                 |
| 115. Notarisation ticket stapled to app                         |
|                                                                 |
| 116. xcrun notarytool submit exits 0                            |
|                                                                 |
| 117. DMG also signed and notarised                              |
+-----------------------------------------------------------------+

**Feature Branch & Commits**

+-----------------------------------------------------------------+
| **⎇ release/v1.0.0**                                            |
|                                                                 |
| Archive, sign, notarise, create DMG, tag release                |
+-----------------------------------------------------------------+

**Commits**

  ------------- ----------- -----------------------------------------------------
  **Hash**      **Type**    **Commit Message**

  **f4a5b6d**   **chore**   chore: enable Hardened Runtime and add
                            entitlements.plist

  **a5b6c7e**   **chore**   chore: create ExportOptions.plist for Developer ID
                            distribution

  **b6c7d8f**   **chore**   chore: write build.sh -- archive → export → notarise
                            → dmg

  **c7d8e9a**   **feat**    feat: add custom DMG background (512×384 PNG)

  **d8e9f0b**   **chore**   chore: notarise app bundle via xcrun notarytool

  **e9f0a1c**   **chore**   chore: staple notarisation ticket with xcrun stapler

  **f0a1b2d**   **chore**   chore: create TitleRedactedCalc-1.0.0.dmg via hdiutil

  **a1b2c3f**   **docs**    docs: update README with one-line release
                            instructions

  **b2c3d4a**   **chore**   chore: tag git v1.0.0 and push
  ------------- ----------- -----------------------------------------------------

**Subtasks**

  -------------- ------------------------------------------------- --------------
  **Task ID**    **Subtask Description**                           **Estimate**

  **ST-06-01**   Enable Hardened Runtime in Signing & Capabilities **10 min**
                 tab                                               

  **ST-06-02**   Create TitleRedactedCalc.entitlements (empty for  **10 min**
                 basic app)                                        

  **ST-06-03**   Create ExportOptions.plist with method:           **15 min**
                 developer-id                                      

  **ST-06-04**   Run Product → Archive in Xcode, confirm Archive   **20 min**
                 Organizer entry                                   

  **ST-06-05**   Export via Distribute App → Developer ID → export **15 min**
                 .app to dist/                                     

  **ST-06-06**   Run xcrun notarytool submit on exported .app,     **20 min**
                 wait for status: Accepted                         

  **ST-06-07**   Run xcrun stapler staple on notarised .app        **5 min**

  **ST-06-08**   Create DMG: hdiutil create -volname               **10 min**
                 TitleRedactedCalc -srcfolder \...                 

  **ST-06-09**   Sign DMG with codesign \--sign \'Developer ID     **10 min**
                 Application: \...\'                               

  **ST-06-10**   Write build.sh combining all steps with error     **30 min**
                 handling                                          

  **ST-06-11**   Test DMG install on a clean Mac user account      **20 min**

  **ST-06-12**   Tag release: git tag v1.0.0 && git push origin    **5 min**
                 v1.0.0                                            
  -------------- ------------------------------------------------- --------------

  -----------------------------------------------------------------
  **EP-07 · Marketing Landing Page**

  -----------------------------------------------------------------

+-----------------------------------------------------------------+
| **EP-07 Marketing Landing Page**                                |
+-----------------------------------------------------------------+
| **Goal:** One-page static site on GitHub Pages or Netlify:      |
| hero, feature highlights, download button, screenshots, and SEO |
| metadata.                                                       |
|                                                                 |
| **Priority: Medium Story Points: 5 Phase: Phase 4 -- Day 2      |
| Evening**                                                       |
+-----------------------------------------------------------------+

**User Stories**

+-----------------------------------------------------------------+
| **US-24 USER STORY 3 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **prospective user***, I want* a landing page that       |
| clearly communicates what the app does and lets me download it  |
| in one click*, so that* I can evaluate and install the app in   |
| under 60 seconds                                                |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 118. Hero: app name, one-line tagline, download button above    |
|      the fold                                                   |
|                                                                 |
| 119. Download button links directly to .dmg                     |
|                                                                 |
| 120. Screenshots showing Basic and Scientific and Graph modes   |
|                                                                 |
| 121. Feature grid: 3--4 bullet highlights                       |
|                                                                 |
| 122. Footer: version, macOS requirement, privacy note (\'no     |
|      telemetry\')                                               |
+-----------------------------------------------------------------+

+-----------------------------------------------------------------+
| **US-25 USER STORY 2 pts**                                      |
+-----------------------------------------------------------------+
| *As a* **developer***, I want* the landing page to have correct |
| Open Graph and SEO meta tags*, so that* the page previews       |
| correctly when shared on Slack, Twitter, iMessage               |
|                                                                 |
| **Acceptance Criteria:**                                        |
|                                                                 |
| 123. \<title\> and \<meta description\> set                     |
|                                                                 |
| 124. og:title, og:description, og:image set                     |
|                                                                 |
| 125. og:image is a clean 1200×630 screenshot                    |
|                                                                 |
| 126. Canonical URL set                                          |
|                                                                 |
| 127. Page scores ≥ 90 on Lighthouse (performance,               |
|      accessibility, SEO)                                        |
+-----------------------------------------------------------------+

**Feature Branch & Commits**

+-----------------------------------------------------------------+
| **⎇ feat/landing-page**                                         |
|                                                                 |
| index.html, assets, deployment config                           |
+-----------------------------------------------------------------+

**Commits**

  ------------- ----------- -----------------------------------------------------
  **Hash**      **Type**    **Commit Message**

  **c3d4e5b**   **feat**    feat: scaffold index.html with hero, features,
                            download sections

  **d4e5f6c**   **feat**    feat: add responsive CSS (system font stack, SF Blue
                            accents)

  **e5f6a7d**   **feat**    feat: add Basic + Scientific + Graph mode screenshots

  **f6a7b8e**   **feat**    feat: add Open Graph and SEO meta tags

  **a7b8c9f**   **feat**    feat: add CNAME / Netlify config for custom domain

  **b8c9d0a**   **chore**   chore: deploy to GitHub Pages / Netlify, verify live
                            URL

  **c9d0e1b**   **fix**     fix: Lighthouse audit fixes (image alt tags,
                            contrast, aria)
  ------------- ----------- -----------------------------------------------------

**Subtasks**

  -------------- ------------------------------------------------- --------------
  **Task ID**    **Subtask Description**                           **Estimate**

  **ST-07-01**   Write index.html: \<head\> with all meta/OG tags, **30 min**
                 hero section                                      

  **ST-07-02**   Add features grid section (3-4 features, emoji    **20 min**
                 icons)                                            

  **ST-07-03**   Add screenshots section with \<img\> or           **20 min**
                 \<picture\> elements                              

  **ST-07-04**   Write inline CSS or link styles.css (no           **30 min**
                 frameworks, keeps it fast)                        

  **ST-07-05**   Point download href to GitHub release DMG asset   **10 min**
                 URL                                               

  **ST-07-06**   Take og:image screenshot (1200×630), save as      **15 min**
                 og-image.png                                      

  **ST-07-07**   Push to GitHub, enable Pages from main branch     **10 min**
                 /docs or /root                                    

  **ST-07-08**   Run Lighthouse in Chrome DevTools, fix any scores **20 min**
                 \< 90                                             
  -------------- ------------------------------------------------- --------------

  -----------------------------------------------------------------
  **Sprint Plan & Timeline**

  -----------------------------------------------------------------

**3. Sprint Plan**

  ---------- ----------- -------------------------------------- ---------
  **Time**   **Epic**    **Work**                               **Est**

  **Day 1    **EP-01**   Scaffold Xcode project, SOLID          **2 h**
  09:00**                architecture, protocols,               
                         BasicCalculator                        

  **Day 1    **EP-01**   ScientificCalculator,                  **2 h**
  11:00**                GraphingCalculator engines, unit tests 

  **Day 1    **EP-02**   CalculatorDisplay, ButtonGrid,         **2 h**
  13:00**                CalculatorButtonStyle                  

  **Day 1    **EP-02**   Keyboard support, window config, color **2 h**
  15:00**                assets, manual test pass               

  **Day 1    **---**     Buffer, polish, commit, push, daily    **1 h**
  17:00**                wrap                                   

  **Day 2    **EP-03**   ScientificButtonGrid, mode toggle,     **2 h**
  09:00**                window resize animation                

  **Day 2    **EP-03**   Deg/Rad toggle, HistoryStore,          **2 h**
  11:00**                HistoryView                            

  **Day 2    **EP-04**   GraphView, AxisOverlay, expression     **2 h**
  13:00**                sampler                                

  **Day 2    **EP-04**   Gesture zoom/pan, crosshair overlay,   **1.5 h**
  15:00**                final graph test                       

  **Day 2    **EP-05**   Accessibility labels, animations, menu **1.5 h**
  16:30**                bar                                    

  **Day 2    **EP-06**   Archive, sign, notarise, DMG,          **1.5 h**
  18:00**                build.sh, tag v1.0.0                   

  **Day 2    **EP-07**   Landing page, deploy, Lighthouse,      **1.5 h**
  19:30**                done!                                  
  ---------- ----------- -------------------------------------- ---------

**4. Definition of Done**

**A story or feature is Done when ALL of the following are true:**

- Code is merged into main via pull request from the feature branch

- All acceptance criteria pass (manually verified)

- Xcode shows zero warnings and zero errors

- Accessibility Inspector shows zero issues for the changed views

- Unit tests (if applicable) pass with xcodebuild test

- Commit messages follow Conventional Commits
  (feat/fix/chore/test/refactor/docs)

- No third-party dependencies added without explicit approval

- Dark mode and light mode tested

**5. Non-Functional Requirements**

  ------------------- ------------------------------------------------
  **Requirement**     **Specification**

  **Language**        100% Swift 6. No Objective-C bridging headers.

  **UI Framework**    100% SwiftUI. No AppKit views or
                      NSViewController.

  **Dependencies**    Zero external packages. All SPM dependencies
                      must be zero.

  **Deployment        macOS 14.0 (Sonoma) minimum.
  Target**            

  **App Size**        Final .app bundle \< 5 MB.

  **Performance**     Graph re-samples 200 points in \< 100 ms on M1.

  **Accessibility**   Zero Accessibility Inspector warnings before
                      release.

  **Theming**         Fully supports Dark Mode and Light Mode
                      automatically.

  **Privacy**         Zero telemetry, zero network requests, zero
                      tracking.

  **Distribution**    Developer ID signed + Apple notarised DMG.
  ------------------- ------------------------------------------------

------------------------------------------------------------------------

*TitleRedactedCalc PRD v2.0 · Confidential · Engineering Edition*
