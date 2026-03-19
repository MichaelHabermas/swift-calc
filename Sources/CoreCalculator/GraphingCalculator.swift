import Foundation
import Utilities

public final class GraphingCalculator: CalculatorEngine {
    private let basic = BasicCalculator()

    // Cache compiled ASTs to make repeated `evaluateExpression` calls fast
    // (e.g., sampling 200 points).
    private var astCache: [String: AST] = [:]

    public init() {}

    public func process(_ input: String) -> String {
        basic.process(input)
    }

    public func evaluate() -> Double? {
        basic.evaluate()
    }

    public func reset() {
        basic.reset()
    }

    // MARK: - Graph-specific API

    public func evaluateExpression(_ expression: String, x: Double) -> Double? {
        let key = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let ast = compile(expression: key) else { return nil }
        guard let result = ast.evaluate(x: x) else { return nil }
        return result
    }

    public func samplePoints(expression: String, xRange: ClosedRange<Double>, count: Int = 200) -> [GraphPoint] {
        guard count > 1 else { return [] }
        let step = (xRange.upperBound - xRange.lowerBound) / Double(count - 1)
        return (0..<count).compactMap { i in
            let x = xRange.lowerBound + Double(i) * step
            guard let y = evaluateExpression(expression, x: x) else { return nil }
            return GraphPoint(x: x, y: y)
        }
    }

    // MARK: - Expression compilation/evaluation

    private func compile(expression: String) -> AST? {
        if let cached = astCache[expression] { return cached }
        let tokens = tokenise(expression)
        var parser = Parser(tokens: tokens)
        guard let ast = parser.parse() else { return nil }
        astCache[expression] = ast
        return ast
    }

    private func tokenise(_ expression: String) -> [Token] {
        var tokens: [Token] = []
        tokens.reserveCapacity(expression.count)

        let scalars = Array(expression)
        var i = 0
        while i < scalars.count {
            let c = scalars[i]

            if c.isWhitespace {
                i += 1
                continue
            }

            // Numbers: digits and '.' (we keep it intentionally simple for EP-01).
            if c.isNumber || c == "." {
                var j = i
                var dotCount = 0
                while j < scalars.count {
                    let cj = scalars[j]
                    if cj == "." { dotCount += 1 }
                    if cj.isNumber || cj == "." {
                        j += 1
                        continue
                    }
                    break
                }
                let slice = String(scalars[i..<j])
                if let value = Double(slice) {
                    tokens.append(.number(value))
                }
                i = j
                continue
            }

            // Identifiers: letters (e.g. sin, cos, ln, x).
            if c.isLetter {
                var j = i
                while j < scalars.count, scalars[j].isLetter {
                    j += 1
                }
                let ident = String(scalars[i..<j])
                tokens.append(.identifier(ident))
                i = j
                continue
            }

            // Constants
            if c == "π" {
                tokens.append(.number(Double.pi))
                i += 1
                continue
            }

            if c == "e" {
                // In this evaluator `e` is treated as Euler's constant (not exponent notation).
                tokens.append(.number(M_E))
                i += 1
                continue
            }

            // Operators / parens.
            switch c {
            case "+", "-", "×", "÷", "^", "−":
                let op: String
                switch c {
                case "−": op = "-" // normalize unicode minus
                case "×": op = "*"
                case "÷": op = "/"
                case "-": op = "-"
                default: op = String(c)
                }
                tokens.append(.op(op))
            case "(":
                tokens.append(.lParen)
            case ")":
                tokens.append(.rParen)
            default:
                // Unknown token -> compilation should fail.
                return [.invalid]
            }

            i += 1
        }

        return tokens
    }

    private enum Token: Equatable {
        case number(Double)
        case identifier(String)
        case op(String)
        case lParen
        case rParen
        case invalid
    }

    private enum BinaryOp {
        case add, subtract, multiply, divide, power
    }

    private indirect enum AST {
        case number(Double)
        case variableX
        case function(name: String, arg: AST)
        case unaryMinus(AST)
        case binary(op: BinaryOp, left: AST, right: AST)

        func evaluate(x: Double) -> Double? {
            switch self {
            case .number(let v):
                return v.isFinite ? v : nil
            case .variableX:
                return x.isFinite ? x : nil
            case .unaryMinus(let inner):
                guard let v = inner.evaluate(x: x) else { return nil }
                return -v
            case .function(let name, let arg):
                guard let v = arg.evaluate(x: x) else { return nil }
                let result: Double
                switch name {
                case "sin": result = Foundation.sin(v)
                case "cos": result = Foundation.cos(v)
                case "tan": result = Foundation.tan(v)
                case "ln": result = Foundation.log(v)
                case "log": result = Foundation.log10(v)
                case "sqrt": result = Foundation.sqrt(v)
                default: return nil
                }
                return (result.isFinite && !result.isNaN) ? result : nil
            case .binary(let op, let left, let right):
                guard let l = left.evaluate(x: x), let r = right.evaluate(x: x) else { return nil }
                let result: Double
                switch op {
                case .add: result = l + r
                case .subtract: result = l - r
                case .multiply: result = l * r
                case .divide:
                    guard r != 0 else { return nil }
                    result = l / r
                case .power:
                    result = Foundation.pow(l, r)
                }
                return (result.isFinite && !result.isNaN) ? result : nil
            }
        }
    }

    private struct Parser {
        let tokens: [Token]
        var pos: Int = 0

        mutating func parse() -> AST? {
            guard !(tokens.first == .invalid) else { return nil }
            let expr = parseExpression()
            guard let expr else { return nil }
            return expr
        }

        mutating func parseExpression() -> AST? {
            guard var left = parseTerm() else { return nil }
            while pos < tokens.count {
                guard case .op(let op) = tokens[pos] else { break }
                guard op == "+" || op == "-" else { break }
                pos += 1
                guard let right = parseTerm() else { return nil }
                left = .binary(op: op == "+" ? .add : .subtract, left: left, right: right)
            }
            return left
        }

        mutating func parseTerm() -> AST? {
            guard var left = parsePower() else { return nil }
            while pos < tokens.count {
                guard case .op(let op) = tokens[pos] else { break }
                guard op == "*" || op == "/" else { break }
                pos += 1
                guard let right = parsePower() else { return nil }
                let bop: BinaryOp = (op == "*") ? .multiply : .divide
                left = .binary(op: bop, left: left, right: right)
            }
            return left
        }

        // Right-associative `^`.
        mutating func parsePower() -> AST? {
            guard let base = parseUnary() else { return nil }
            if pos < tokens.count, case .op(let op) = tokens[pos], op == "^" {
                pos += 1
                guard let exponent = parsePower() else { return nil }
                return .binary(op: .power, left: base, right: exponent)
            }
            return base
        }

        mutating func parseUnary() -> AST? {
            if pos < tokens.count, case .op(let op) = tokens[pos], op == "-" {
                pos += 1
                guard let inner = parseUnary() else { return nil }
                return .unaryMinus(inner)
            }
            return parsePrimary()
        }

        mutating func parsePrimary() -> AST? {
            guard pos < tokens.count else { return nil }
            let token = tokens[pos]
            pos += 1

            switch token {
            case .number(let v):
                return .number(v)
            case .identifier(let name):
                if name == "x" { return .variableX }
                // Function call: sin(expr), cos(expr), etc.
                let allowed = ["sin", "cos", "tan", "ln", "log", "sqrt"]
                guard allowed.contains(name) else { return nil }
                guard pos < tokens.count, tokens[pos] == .lParen else { return nil }
                pos += 1
                guard let arg = parseExpression() else { return nil }
                guard pos < tokens.count, tokens[pos] == .rParen else { return nil }
                pos += 1
                return .function(name: name, arg: arg)
            case .lParen:
                // Parenthesized expression.
                guard let expr = parseExpression() else { return nil }
                guard pos < tokens.count, tokens[pos] == .rParen else { return nil }
                pos += 1
                return expr
            default:
                return nil
            }
        }
    }
}

// MARK: - Graphing types (used by later epics)

public struct GraphPoint: Identifiable, Equatable {
    public let id = UUID()
    public let x: Double
    public let y: Double
}

