import XCTest
@testable import CoreCalculator

final class ScientificCalculatorTests: XCTestCase {
    private var calc: ScientificCalculator!

    override func setUp() {
        super.setUp()
        calc = ScientificCalculator()
        calc.angleMode = .degrees
    }

    func testSin90Degrees() {
        _ = calc.process("9")
        _ = calc.process("0")
        let result = calc.process("sin")
        guard let value = Double(result) else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 1.0, accuracy: 1e-10)
    }

    func testCos0Degrees() {
        _ = calc.process("0")
        let result = calc.process("cos")
        guard let value = Double(result) else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 1.0, accuracy: 1e-10)
    }

    func testSquareRoot() {
        _ = calc.process("1")
        _ = calc.process("6")
        let result = calc.process("√")
        guard let value = Double(result) else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 4.0, accuracy: 1e-10)
    }

    func testLog10() {
        _ = calc.process("1")
        _ = calc.process("0")
        _ = calc.process("0")
        let result = calc.process("log")
        guard let value = Double(result) else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 2.0, accuracy: 1e-10)
    }

    func testPiConstant() {
        let result = calc.process("π")
        guard let value = Double(result) else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, Double.pi, accuracy: 1e-10)
    }

    func testSquareOperation() {
        _ = calc.process("5")
        let result = calc.process("x²")
        guard let value = Double(result) else { return XCTFail("Expected numeric result") }
        XCTAssertEqual(value, 25.0, accuracy: 1e-10)
    }
}

