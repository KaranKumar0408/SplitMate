import SwiftUI

// MARK: - Models

struct Expense: Identifiable {
    let id = UUID()
    var title: String
    var amount: Double
    var paidBy: String
}

struct ExpenseGroup: Identifiable {
    let id = UUID()
    var name: String
    var members: [String]
    var expenses: [Expense]

    var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}

struct Settlement: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let amount: Double
}

// MARK: - Main View

struct ContentView: View {
    @State private var groups: [ExpenseGroup] = [
        ExpenseGroup(
            name: "Goa Trip",
            members: ["Karan", "Arjun", "Rohan", "Ved"],
            expenses: [
                Expense(title: "Hotel", amount: 8000, paidBy: "Karan"),
                Expense(title: "Dinner", amount: 2400, paidBy: "Arjun"),
                Expense(title: "Cab", amount: 1200, paidBy: "Rohan")
            ]
        )
    ]

    @State private var showingAddGroup = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($groups) { $group in
                    NavigationLink {
                        GroupDetailView(group: $group)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(group.name)
                                .font(.headline)

                            HStack {
                                Label(
                                    "\(group.members.count) members",
                                    systemImage: "person.2"
                                )

                                Spacer()

                                Text("₹\(group.totalExpense, specifier: "%.0f")")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("SplitMate")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGroup) {
                AddGroupView(groups: $groups)
            }
        }
    }
}

// MARK: - Group Detail

struct GroupDetailView: View {
    @Binding var group: ExpenseGroup
    @State private var showingAddExpense = false

    var body: some View {
        List {
            Section("Overview") {
                HStack {
                    Text("Total spent")
                    Spacer()
                    Text("₹\(group.totalExpense, specifier: "%.0f")")
                        .fontWeight(.bold)
                }

                HStack {
                    Text("Members")
                    Spacer()
                    Text("\(group.members.count)")
                }
            }

            Section("Expenses") {
                if group.expenses.isEmpty {
                    Text("No expenses yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(group.expenses) { expense in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(expense.title)
                                    .fontWeight(.medium)

                                Text("Paid by \(expense.paidBy)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("₹\(expense.amount, specifier: "%.0f")")
                                .fontWeight(.semibold)
                        }
                    }
                }

                Button {
                    showingAddExpense = true
                } label: {
                    Label("Add Expense", systemImage: "plus.circle")
                }
            }

            Section("Members") {
                ForEach(group.members, id: \.self) { member in
                    Label(member, systemImage: "person.circle")
                }
            }

            Section {
                NavigationLink {
                    BalancesView(group: group)
                } label: {
                    Label(
                        "Balances & Settlements",
                        systemImage: "arrow.left.arrow.right"
                    )
                }
            }
        }
        .navigationTitle(group.name)
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(group: $group)
        }
    }
}

// MARK: - Add Expense

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var group: ExpenseGroup

    @State private var title = ""
    @State private var amount = ""
    @State private var paidBy = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense") {
                    TextField("Description", text: $title)

                    TextField("Amount", text: $amount)

                    Picker("Paid by", selection: $paidBy) {
                        Text("Select member").tag("")

                        ForEach(group.members, id: \.self) { member in
                            Text(member).tag(member)
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addExpense()
                    }
                    .disabled(
                        title.trimmingCharacters(in: .whitespaces).isEmpty ||
                        Double(amount) == nil ||
                        paidBy.isEmpty
                    )
                }
            }
        }
    }

    private func addExpense() {
        guard let value = Double(amount), value > 0 else { return }

        group.expenses.append(
            Expense(
                title: title,
                amount: value,
                paidBy: paidBy
            )
        )

        dismiss()
    }
}

// MARK: - Balances & Settlement Algorithm

struct BalancesView: View {
    let group: ExpenseGroup

    private var balances: [(name: String, balance: Double)] {
        guard !group.members.isEmpty else { return [] }

        let share = group.totalExpense / Double(group.members.count)

        return group.members.map { member in
            let paid = group.expenses
                .filter { $0.paidBy == member }
                .reduce(0) { $0 + $1.amount }

            return (member, paid - share)
        }
    }

    private var settlements: [Settlement] {
        var creditors = balances
            .filter { $0.balance > 0.01 }
            .sorted { $0.balance > $1.balance }

        var debtors = balances
            .filter { $0.balance < -0.01 }
            .map { (name: $0.name, balance: -$0.balance) }
            .sorted { $0.balance > $1.balance }

        var result: [Settlement] = []

        var creditorIndex = 0
        var debtorIndex = 0

        while creditorIndex < creditors.count &&
              debtorIndex < debtors.count {

            let amount = min(
                creditors[creditorIndex].balance,
                debtors[debtorIndex].balance
            )

            result.append(
                Settlement(
                    from: debtors[debtorIndex].name,
                    to: creditors[creditorIndex].name,
                    amount: amount
                )
            )

            creditors[creditorIndex].balance -= amount
            debtors[debtorIndex].balance -= amount

            if creditors[creditorIndex].balance < 0.01 {
                creditorIndex += 1
            }

            if debtors[debtorIndex].balance < 0.01 {
                debtorIndex += 1
            }
        }

        return result
    }

    var body: some View {
        List {
            Section("Balances") {
                ForEach(balances, id: \.name) { item in
                    HStack {
                        Text(item.name)

                        Spacer()

                        if item.balance > 0.01 {
                            Text("+₹\(item.balance, specifier: "%.0f")")
                                .foregroundStyle(.green)
                        } else if item.balance < -0.01 {
                            Text("-₹\(abs(item.balance), specifier: "%.0f")")
                                .foregroundStyle(.red)
                        } else {
                            Text("Settled")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Suggested Settlements") {
                if settlements.isEmpty {
                    Label(
                        "Everyone is settled up!",
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                } else {
                    ForEach(settlements) { settlement in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(settlement.from) → \(settlement.to)")
                                .fontWeight(.semibold)

                            Text(
                                "Pay ₹\(settlement.amount, specifier: "%.0f")"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 3)
                    }
                }
            }

            Section {
                Text(
                    "SplitMate calculates each member's fair share and minimizes the number of payments needed to settle the group."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settle Up")
    }
}

// MARK: - Add Group

struct AddGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var groups: [ExpenseGroup]

    @State private var groupName = ""
    @State private var members = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Group Details") {
                    TextField("Group name", text: $groupName)

                    TextField(
                        "Members (comma separated)",
                        text: $members
                    )
                }
            }
            .navigationTitle("New Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGroup()
                    }
                    .disabled(
                        groupName.trimmingCharacters(in: .whitespaces).isEmpty ||
                        parsedMembers.isEmpty
                    )
                }
            }
        }
    }

    private var parsedMembers: [String] {
        members
            .split(separator: ",")
            .map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
    }

    private func createGroup() {
        groups.append(
            ExpenseGroup(
                name: groupName,
                members: parsedMembers,
                expenses: []
            )
        )

        dismiss()
    }
}

#Preview {
    ContentView()
}
