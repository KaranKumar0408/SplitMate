import SwiftUI

struct BalancesView: View {

    @Binding var group: ExpenseGroup

    private var balances: [MemberBalance] {
        SettlementEngine.calculateBalances(
            for: group
        )
    }

    private var settlements: [Settlement] {
        SettlementEngine.calculateSettlements(
            for: group
        )
    }

    private var completedCount: Int {
        group.settlementPayments.count
    }

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 22
            ) {

                summaryCard

                Text("Member Balances")
                    .font(.title3)
                    .fontWeight(.bold)

                balanceCard

                HStack {

                    Text("Suggested Payments")
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    if completedCount > 0 {
                        Label(
                            "\(completedCount) paid",
                            systemImage:
                                "checkmark.circle.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(.green)
                    }
                }

                if settlements.isEmpty {

                    settledState

                } else {

                    ForEach(settlements) {
                        settlement in

                        settlementCard(
                            settlement
                        )
                    }
                }

                if !group
                    .settlementPayments
                    .isEmpty {

                    paymentHistory
                }

                HStack(alignment: .top) {

                    Image(
                        systemName: "info.circle"
                    )

                    Text(
                        "SplitMate matches outstanding debtor and creditor balances to generate a simplified settlement plan."
                    )
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                Spacer(minLength: 10)
            }
            .padding()
        }
        .background(
            Color(.systemGroupedBackground)
        )
        .navigationTitle("Settle Up")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Summary

    private var summaryCard: some View {

        HStack {

            VStack(alignment: .leading) {

                Text("TOTAL SPEND")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    "₹\(group.totalExpense, specifier: "%.0f")"
                )
                .font(.title)
                .fontWeight(.bold)
            }

            Spacer()

            VStack(alignment: .trailing) {

                Text("PAYMENTS MADE")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(completedCount)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding(18)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: Balances

    private var balanceCard: some View {

        VStack(spacing: 0) {

            ForEach(balances) { item in

                HStack {

                    Circle()
                        .fill(
                            Color.blue.opacity(0.12)
                        )
                        .frame(
                            width: 40,
                            height: 40
                        )
                        .overlay {

                            Text(
                                String(
                                    item.name.prefix(1)
                                )
                            )
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        }

                    Text(item.name)
                        .fontWeight(.medium)

                    Spacer()

                    if item.balance > 0.01 {

                        VStack(
                            alignment: .trailing
                        ) {

                            Text(
                                "+₹\(item.balance, specifier: "%.0f")"
                            )
                            .fontWeight(.bold)
                            .foregroundStyle(.green)

                            Text("gets back")
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                        }

                    } else if
                        item.balance < -0.01 {

                        VStack(
                            alignment: .trailing
                        ) {

                            Text(
                                "₹\(abs(item.balance), specifier: "%.0f")"
                            )
                            .fontWeight(.bold)
                            .foregroundStyle(.red)

                            Text("owes")
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                        }

                    } else {

                        Text("Settled")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }
                .padding(.vertical, 12)

                if item.id != balances.last?.id {
                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .padding(.horizontal)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: Settlement

    private func settlementCard(
        _ settlement: Settlement
    ) -> some View {

        VStack(spacing: 14) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {

                    Text(
                        "\(settlement.from) → \(settlement.to)"
                    )
                    .fontWeight(.semibold)

                    Text("Suggested payment")
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                }

                Spacer()

                Text(
                    "₹\(settlement.amount, specifier: "%.0f")"
                )
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            }

            Button {
                withAnimation(.snappy) {
                    markAsPaid(settlement)
                }
            } label: {

                Label(
                    "Mark as Paid",
                    systemImage:
                        "checkmark.circle.fill"
                )
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Color.green.opacity(0.12)
                )
                .foregroundStyle(.green)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )
            }
        }
        .padding(16)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    private func markAsPaid(
        _ settlement: Settlement
    ) {

        group.settlementPayments.append(
            SettlementPayment(
                from: settlement.from,
                to: settlement.to,
                amount: settlement.amount
            )
        )
    }

    // MARK: History

    private var paymentHistory: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Payment History")
                .font(.title3)
                .fontWeight(.bold)

            VStack(spacing: 0) {

                ForEach(
                    group.settlementPayments
                ) { payment in

                    HStack {

                        Image(
                            systemName:
                                "checkmark.circle.fill"
                        )
                        .foregroundStyle(.green)

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text(
                                "\(payment.from) paid \(payment.to)"
                            )
                            .fontWeight(.medium)

                            Text(
                                payment.date,
                                style: .date
                            )
                            .font(.caption)
                            .foregroundStyle(
                                .secondary
                            )
                        }

                        Spacer()

                        Text(
                            "₹\(payment.amount, specifier: "%.0f")"
                        )
                        .fontWeight(.semibold)
                    }
                    .padding(.vertical, 11)

                    if payment.id !=
                        group
                            .settlementPayments
                            .last?.id {

                        Divider()
                    }
                }
            }
            .padding(.horizontal)
            .background(
                Color(
                    .secondarySystemGroupedBackground
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
        }
    }

    private var settledState: some View {

        VStack(spacing: 12) {

            Image(
                systemName:
                    "checkmark.circle.fill"
            )
            .font(.system(size: 46))
            .foregroundStyle(.green)

            Text("All settled up!")
                .font(.headline)

            Text(
                "There are no outstanding payments in this group."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            Color(
                .secondarySystemGroupedBackground
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }
}
