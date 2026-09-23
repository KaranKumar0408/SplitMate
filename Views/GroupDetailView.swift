import SwiftUI

struct GroupDetailView: View {

    @Binding var group: ExpenseGroup
    @State private var showingAddExpense = false

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 24) {

                summaryCard

                InsightsView(group: group)

                HStack {

                    Text("Expenses")
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text("\(group.expenses.count)")
                        .foregroundStyle(.secondary)
                }

                if group.expenses.isEmpty {

                    emptyExpenses

                } else {

                    VStack(spacing: 0) {

                        ForEach(group.expenses) { expense in

                            ExpenseRow(expense: expense)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteExpense(expense)
                                    } label: {
                                        Label(
                                            "Delete Expense",
                                            systemImage: "trash"
                                        )
                                    }
                                }

                            if expense.id != group.expenses.last?.id {

                                Divider()
                                    .padding(.leading, 54)
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

                Button {

                    showingAddExpense = true

                } label: {

                    Label(
                        "Add Expense",
                        systemImage: "plus.circle.fill"
                    )
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color.blue.opacity(0.12)
                    )
                    .foregroundStyle(.blue)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }

                Text("Members")
                    .font(.title3)
                    .fontWeight(.bold)

                membersCard

                NavigationLink {

                    BalancesView(group: $group)

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "arrow.left.arrow.right"
                        )
                        .font(.title3)

                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("Balances & Settlements")
                                .fontWeight(.semibold)

                            Text(
                                "View balances and settle payments"
                            )
                            .font(.caption)
                            .opacity(0.8)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .padding(18)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
                }
                .buttonStyle(.plain)

                Spacer(minLength: 15)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddExpense) {

            AddExpenseView(group: $group)
        }
    }

    private var summaryCard: some View {

        HStack {

            VStack(alignment: .leading, spacing: 5) {

                Text("TOTAL SPENT")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    "₹\(group.totalExpense, specifier: "%.0f")"
                )
                .font(
                    .system(
                        size: 32,
                        weight: .bold
                    )
                )
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {

                Text("EXPENSES")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(group.expenses.count)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding(20)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    private var membersCard: some View {

        VStack(spacing: 0) {

            ForEach(group.members, id: \.self) { member in

                HStack(spacing: 12) {

                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 38, height: 38)
                        .overlay {

                            Text(
                                String(member.prefix(1))
                                    .uppercased()
                            )
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        }

                    Text(member)
                        .fontWeight(.medium)

                    Spacer()
                }
                .padding(.vertical, 10)

                if member != group.members.last {

                    Divider()
                        .padding(.leading, 50)
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

    private var emptyExpenses: some View {

        VStack(spacing: 10) {

            Image(systemName: "receipt")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)

            Text("No expenses yet")
                .fontWeight(.semibold)

            Text(
                "Add the first shared expense for this group."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
    }

    private func deleteExpense(_ expense: Expense) {

        withAnimation {

            group.expenses.removeAll {
                $0.id == expense.id
            }
        }
    }
}


// MARK: - Expense Row

struct ExpenseRow: View {

    let expense: Expense

    private var icon: String {

        let text = expense.title.lowercased()

        if text.contains("hotel") {

            return "bed.double.fill"
        }

        if text.contains("cab") ||
            text.contains("taxi") ||
            text.contains("uber") {

            return "car.fill"
        }

        if text.contains("dinner") ||
            text.contains("food") ||
            text.contains("lunch") ||
            text.contains("restaurant") {

            return "fork.knife"
        }

        if text.contains("flight") {

            return "airplane"
        }

        return "creditcard.fill"
    }

    var body: some View {

        HStack(spacing: 13) {

            ZStack {

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.10))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {

                Text(expense.title)
                    .fontWeight(.medium)

                HStack(spacing: 4) {

                    Text("\(expense.paidBy) paid")

                    if !expense.shares.isEmpty {

                        Text("•")

                        Text(expense.splitMethod.rawValue)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(
                "₹\(expense.amount, specifier: "%.0f")"
            )
            .fontWeight(.semibold)
        }
        .padding(.vertical, 12)
    }
}
