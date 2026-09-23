import Foundation

struct Settlement: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let amount: Double
}

struct SettlementPayment: Identifiable, Codable, Equatable {
    let id: UUID
    var from: String
    var to: String
    var amount: Double
    var date: Date

    init(
        id: UUID = UUID(),
        from: String,
        to: String,
        amount: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.amount = amount
        self.date = date
    }
}
