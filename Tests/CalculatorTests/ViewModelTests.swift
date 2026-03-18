import XCTest
@testable import CoreCalculator
@testable import ViewModels

final class MockCalculatorEngine: CalculatorEngine {
    private(set) var processCallCount: Int = 0
    private(set) var lastInput: String = ""
    var stubbedResult: String = "42"
    var stubbedEvaluate: Double? = 42

    func process(_ input: String) -> String {
        processCallCount += 1
        lastInput = input
        return stubbedResult
    }

    func evaluate() -> Double? {
        stubbedEvaluate
    }

    func reset() {}
}

final class ViewModelTests: XCTestCase {
    func test_buttonTapped_callsEngine() {
        let mock = MockCalculatorEngine()
        let vm = CalculatorViewModel(engine: mock)

        vm.buttonTapped("5")

        XCTAssertEqual(mock.processCallCount, 1)
        XCTAssertEqual(mock.lastInput, "5")
        XCTAssertEqual(vm.display, "42")
    }
}

