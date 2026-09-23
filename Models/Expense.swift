import Foundation

struct ExpenseShare: Identifiable, Codable, Equatable {
    let id: UUID
    var member: String
    var amount: Double

    init(
        id: UUID = UUID(),
        member: String,
        amount: Double
    ) {
        self.id = id
        self.member = member
        self.amount = amount
    }
}

struct Expense: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var paidBy: String
    var splitMethod: SplitMethod
    var shares: [ExpenseShare]

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        paidBy: String,
        splitMethod: SplitMethod = .equal,
        shares: [ExpenseShare] = []
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.splitMethod = splitMethod
        self.shares = shares
    }
}
