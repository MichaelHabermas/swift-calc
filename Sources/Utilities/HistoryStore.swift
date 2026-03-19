import Foundation

public struct HistoryEntry: Identifiable, Sendable {
    public let id: UUID
    public let expression: String
    public let result: String
    public let date: Date

    public init(expression: String, result: String, date: Date = .now) {
        self.id = UUID()
        self.expression = expression
        self.result = result
        self.date = date
    }
}
