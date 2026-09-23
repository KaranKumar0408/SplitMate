import Foundation

struct ExpenseGroup: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var members: [String]
    var expenses: [Expense]
    var settlementPayments: [SettlementPayment]

    init(
        id: UUID = UUID(),
        name: String,
        members: [String],
        expenses: [Expense] = [],
        settlementPayments: [SettlementPayment] = []
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
        self.settlementPayments = settlementPayments
    }

    var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var averageExpense: Double {
        guard !expenses.isEmpty else { return 0 }
        return totalExpense / Double(expenses.count)
    }

    var largestExpense: Expense? {
        expenses.max { $0.amount < $1.amount }
    }

    var topPayer: (name: String, amount: Double)? {
        guard !expenses.isEmpty else { return nil }

        var totals: [String: Double] = [:]

        for expense in expenses {
            totals[expense.paidBy, default: 0] += expense.amount
        }

        guard let result = totals.max(by: { $0.value < $1.value }) else {
            return nil
        }

        return (result.key, result.value)
    }
}
