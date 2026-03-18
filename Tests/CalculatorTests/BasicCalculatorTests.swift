import XCTest
@testable import CoreCalculator

final class BasicCalculatorTests: XCTestCase {
    private var calc: BasicCalculator!

    override func setUp() {
        super.setUp()
        calc = BasicCalculator()
    }

    func testAddition() {
        _ = calc.process("4")
        _ = calc.process("+")
        _ = calc.process("3")
        _ = calc.process("=")
        guard let value = calc.evaluate() else { return XCTFail("Expected a numeric result") }
        XCTAssertEqual(value, 7, accuracy: 1e-10)
    }

    func testSubtraction() {
        _ = calc.process("1")
        _ = calc.process("0")
        _ = calc.process("-")
        _ = calc.process("4")
        _ = calc.process("=")
        guard let value = calc.evaluate() else { return XCTFail("Expected a numeric result") }
        XCTAssertEqual(value, 6, accuracy: 1e-10)
    }

    func testMultiplication() {
        _ = calc.process("6")
        _ = calc.process("*")
        _ = calc.process("7")
        _ = calc.process("=")
        guard let value = calc.evaluate() else { return XCTFail("Expected a numeric result") }
        XCTAssertEqual(value, 42, accuracy: 1e-10)
    }

    func testDivisionByZeroReturnsError() {
        _ = calc.process("9")
        _ = calc.process("/")
        _ = calc.process("0")
        let result = calc.process("=")
        XCTAssertEqual(result, "Error")
        XCTAssertNil(calc.evaluate())
    }

    func testPercentageConversion() {
        _ = calc.process("5")
        _ = calc.process("0")
        let result = calc.process("%")
        XCTAssertEqual(result, "0.5")
    }

    func testSignToggle() {
        _ = calc.process("3")
        let result = calc.process("±")
        XCTAssertEqual(result, "-3")
    }

    func testReset() {
        _ = calc.process("9")
        _ = calc.process("+")
        _ = calc.process("9")
        calc.reset()
        guard let value = calc.evaluate() else { return XCTFail("Expected a numeric result") }
        XCTAssertEqual(value, 0, accuracy: 1e-10)
    }

    func testChainedOperationsLeftToRight() {
        _ = calc.process("2")
        _ = calc.process("+")
        _ = calc.process("3")
        _ = calc.process("*")
        _ = calc.process("4")
        _ = calc.process("=")
        guard let value = calc.evaluate() else { return XCTFail("Expected a numeric result") }
        XCTAssertEqual(value, 20, accuracy: 1e-10)
    }
}

