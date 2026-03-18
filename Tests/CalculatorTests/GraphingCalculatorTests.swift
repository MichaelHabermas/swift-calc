import XCTest
@testable import CoreCalculator

final class GraphingCalculatorTests: XCTestCase {
    private var calc: GraphingCalculator!

    override func setUp() {
        super.setUp()
        calc = GraphingCalculator()
    }

    func testSinAtPiOverTwo() {
        let result = calc.evaluateExpression("sin(x)", x: Double.pi / 2)
        guard let value = result else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 1.0, accuracy: 1e-10)
    }

    func testCosAtZero() {
        let result = calc.evaluateExpression("cos(x)", x: 0)
        guard let value = result else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 1.0, accuracy: 1e-10)
    }

    func testXPowerTwo() {
        let result = calc.evaluateExpression("x^2", x: 3)
        guard let value = result else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 9.0, accuracy: 1e-10)
    }

    func testUndefinedReturnsNil() {
        // sqrt(-1) is not real.
        let result = calc.evaluateExpression("sqrt(x)", x: -1)
        XCTAssertNil(result)
    }
}

