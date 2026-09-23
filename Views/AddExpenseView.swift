import SwiftUI

struct AddExpenseView: View {

    @Environment(\.dismiss) private var dismiss
    @Binding var group: ExpenseGroup

    @State private var title = ""
    @State private var amount = ""
    @State private var paidBy = ""

    @State private var splitMethod: SplitMethod = .equal
    @State private var selectedMembers: Set<String> = []

    @State private var customValues: [String: String] = [:]
    @State private var percentageValues: [String: String] = [:]

    @State private var showingValidationError = false
    @State private var validationMessage = ""

    private var expenseAmount: Double {
        Double(amount) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Expense

                Section("Expense Details") {

                    TextField(
                        "What was this expense?",
                        text: $title
                    )

                    TextField(
                        "Amount",
                        text: $amount
                    )
                    .keyboardType(.decimalPad)

                    Picker(
                        "Paid by",
                        selection: $paidBy
                    ) {
                        Text("Select member")
                            .tag("")

                        ForEach(group.members, id: \.self) {
                            member in

                            Text(member)
                                .tag(member)
                        }
                    }
                }

                // MARK: Participants

                Section {
                    ForEach(group.members, id: \.self) {
                        member in

                        Button {
                            toggleMember(member)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(
                                        Color.blue.opacity(0.12)
                                    )
                                    .frame(
                                        width: 34,
                                        height: 34
                                    )
                                    .overlay {
                                        Text(
                                            String(
                                                member.prefix(1)
                                            )
                                            .uppercased()
                                        )
                                        .fontWeight(.bold)
                                        .foregroundStyle(.blue)
                                    }

                                Text(member)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(
                                    systemName:
                                        selectedMembers.contains(member)
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                )
                                .foregroundStyle(
                                    selectedMembers.contains(member)
                                    ? .blue
                                    : .secondary
                                )
                                .font(.title3)
                            }
                        }
                    }

                    HStack {
                        Button("Select All") {
                            selectedMembers =
                                Set(group.members)
                        }

                        Spacer()

                        Text(
                            "\(selectedMembers.count) selected"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                } header: {
                    Text("Split Between")
                } footer: {
                    Text(
                        "Only selected members will owe a share of this expense."
                    )
                }

                // MARK: Method

                Section("Split Method") {

                    Picker(
                        "Split Method",
                        selection: $splitMethod
                    ) {
                        ForEach(SplitMethod.allCases) {
                            method in

                            Text(method.rawValue)
                                .tag(method)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch splitMethod {

                    case .equal:
                        equalSplitPreview

                    case .custom:
                        customSplitFields

                    case .percentage:
                        percentageSplitFields
                    }
                }

                // MARK: Summary

                if expenseAmount > 0 &&
                    !selectedMembers.isEmpty {

                    Section("Summary") {

                        HStack {
                            Text("Expense")
                            Spacer()
                            Text(
                                "₹\(expenseAmount, specifier: "%.2f")"
                            )
                        }

                        HStack {
                            Text("Participants")
                            Spacer()
                            Text(
                                "\(selectedMembers.count)"
                            )
                        }

                        HStack {
                            Text("Split")
                            Spacer()
                            Text(splitMethod.rawValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!basicInputValid)
                }
            }
            .alert(
                "Check Split",
                isPresented: $showingValidationError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                if selectedMembers.isEmpty {
                    selectedMembers =
                        Set(group.members)
                }

                if paidBy.isEmpty {
                    paidBy = group.members.first ?? ""
                }
            }
        }
    }

    // MARK: Equal

    private var equalSplitPreview: some View {

        Group {
            if selectedMembers.isEmpty {

                Text("Select at least one participant.")
                    .foregroundStyle(.secondary)

            } else {

                let share =
                    expenseAmount /
                    Double(selectedMembers.count)

                ForEach(
                    selectedMembers.sorted(),
                    id: \.self
                ) { member in

                    HStack {
                        Text(member)

                        Spacer()

                        Text(
                            "₹\(share, specifier: "%.2f")"
                        )
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: Custom

    private var customSplitFields: some View {

        Group {
            ForEach(
                selectedMembers.sorted(),
                id: \.self
            ) { member in

                HStack {
                    Text(member)

                    Spacer()

                    Text("₹")
                        .foregroundStyle(.secondary)

                    TextField(
                        "0",
                        text: customBinding(
                            for: member
                        )
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
                }
            }

            HStack {
                Text("Allocated")

                Spacer()

                Text(
                    "₹\(customTotal, specifier: "%.2f") / ₹\(expenseAmount, specifier: "%.2f")"
                )
                .foregroundStyle(
                    abs(customTotal - expenseAmount) < 0.01
                    ? .green
                    : .secondary
                )
            }
            .font(.footnote)
        }
    }

    // MARK: Percentage

    private var percentageSplitFields: some View {

        Group {
            ForEach(
                selectedMembers.sorted(),
                id: \.self
            ) { member in

                HStack {
                    Text(member)

                    Spacer()

                    TextField(
                        "0",
                        text: percentageBinding(
                            for: member
                        )
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)

                    Text("%")
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text("Total")

                Spacer()

                Text(
                    "\(percentageTotal, specifier: "%.1f")%"
                )
                .foregroundStyle(
                    abs(percentageTotal - 100) < 0.01
                    ? .green
                    : .secondary
                )
            }
            .font(.footnote)
        }
    }

    // MARK: Calculations

    private var basicInputValid: Bool {
        !title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty &&
        expenseAmount > 0 &&
        !paidBy.isEmpty &&
        !selectedMembers.isEmpty
    }

    private var customTotal: Double {
        selectedMembers.reduce(0) {
            total,
            member in

            total +
                (Double(
                    customValues[member] ?? ""
                ) ?? 0)
        }
    }

    private var percentageTotal: Double {
        selectedMembers.reduce(0) {
            total,
            member in

            total +
                (Double(
                    percentageValues[member] ?? ""
                ) ?? 0)
        }
    }

    private func toggleMember(
        _ member: String
    ) {
        if selectedMembers.contains(member) {
            selectedMembers.remove(member)
        } else {
            selectedMembers.insert(member)
        }
    }

    private func customBinding(
        for member: String
    ) -> Binding<String> {

        Binding(
            get: {
                customValues[member] ?? ""
            },
            set: {
                customValues[member] = $0
            }
        )
    }

    private func percentageBinding(
        for member: String
    ) -> Binding<String> {

        Binding(
            get: {
                percentageValues[member] ?? ""
            },
            set: {
                percentageValues[member] = $0
            }
        )
    }

    // MARK: Save

    private func saveExpense() {

        guard basicInputValid else {
            return
        }

        let shares: [ExpenseShare]

        switch splitMethod {

        case .equal:

            let share =
                expenseAmount /
                Double(selectedMembers.count)

            shares =
                selectedMembers.map {
                    ExpenseShare(
                        member: $0,
                        amount: share
                    )
                }

        case .custom:

            guard
                abs(
                    customTotal -
                    expenseAmount
                ) < 0.01
            else {
                validationMessage =
                    "Custom amounts must add up to ₹\(expenseAmount.formatted(.number.precision(.fractionLength(2))))."

                showingValidationError = true
                return
            }

            shares =
                selectedMembers.map {
                    member in

                    ExpenseShare(
                        member: member,
                        amount:
                            Double(
                                customValues[
                                    member
                                ] ?? ""
                            ) ?? 0
                    )
                }

        case .percentage:

            guard
                abs(
                    percentageTotal -
                    100
                ) < 0.01
            else {
                validationMessage =
                    "Percentages must add up to 100%."

                showingValidationError = true
                return
            }

            shares =
                selectedMembers.map {
                    member in

                    let percentage =
                        Double(
                            percentageValues[
                                member
                            ] ?? ""
                        ) ?? 0

                    return ExpenseShare(
                        member: member,
                        amount:
                            expenseAmount *
                            percentage /
                            100
                    )
                }
        }

        group.expenses.append(
            Expense(
                title:
                    title.trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    ),
                amount: expenseAmount,
                paidBy: paidBy,
                splitMethod: splitMethod,
                shares: shares
            )
        )

        dismiss()
    }
}//
//  AddExpenseView.swift
//  SplitMate
//
//  Created by Karan Kumar on 23/09/26.
//

