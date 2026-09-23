import Foundation

struct MemberBalance: Identifiable {
    let id = UUID()
    let name: String
    var balance: Double
}

struct SettlementEngine {

    static func calculateBalances(
        for group: ExpenseGroup
    ) -> [MemberBalance] {

        var paid: [String: Double] = [:]
        var owed: [String: Double] = [:]

        for member in group.members {
            paid[member] = 0
            owed[member] = 0
        }

        for expense in group.expenses {

            paid[expense.paidBy, default: 0] += expense.amount

            // New expenses use explicit shares.
            if !expense.shares.isEmpty {

                for share in expense.shares {
                    owed[share.member, default: 0] += share.amount
                }

            } else {

                // Fallback for our existing old expenses.
                // They were split equally across all group members.
                guard !group.members.isEmpty else { continue }

                let share =
                    expense.amount / Double(group.members.count)

                for member in group.members {
                    owed[member, default: 0] += share
                }
            }
        }

        // Completed settlement payments also affect balances.
        for payment in group.settlementPayments {
            paid[payment.from, default: 0] += payment.amount
            paid[payment.to, default: 0] -= payment.amount
        }

        return group.members.map { member in

            MemberBalance(
                name: member,
                balance:
                    paid[member, default: 0] -
                    owed[member, default: 0]
            )
        }
    }

    static func calculateSettlements(
        for group: ExpenseGroup
    ) -> [Settlement] {

        let balances = calculateBalances(for: group)

        var creditors =
            balances
                .filter { $0.balance > 0.01 }
                .map {
                    (
                        name: $0.name,
                        amount: $0.balance
                    )
                }
                .sorted {
                    $0.amount > $1.amount
                }

        var debtors =
            balances
                .filter { $0.balance < -0.01 }
                .map {
                    (
                        name: $0.name,
                        amount: -$0.balance
                    )
                }
                .sorted {
                    $0.amount > $1.amount
                }

        var settlements: [Settlement] = []

        var creditorIndex = 0
        var debtorIndex = 0

        while
            creditorIndex < creditors.count &&
            debtorIndex < debtors.count {

            let amount = min(
                creditors[creditorIndex].amount,
                debtors[debtorIndex].amount
            )

            settlements.append(
                Settlement(
                    from: debtors[debtorIndex].name,
                    to: creditors[creditorIndex].name,
                    amount: amount
                )
            )

            creditors[creditorIndex].amount -= amount
            debtors[debtorIndex].amount -= amount

            if creditors[creditorIndex].amount < 0.01 {
                creditorIndex += 1
            }

            if debtors[debtorIndex].amount < 0.01 {
                debtorIndex += 1
            }
        }

        return settlements
    }
}
