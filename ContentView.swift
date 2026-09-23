import SwiftUI

struct ContentView: View {

    @State private var groups: [ExpenseGroup] = []
    @State private var showingAddGroup = false
    @State private var hasLoadedData = false

    private var totalShared: Double {
        groups.reduce(0) { $0 + $1.totalExpense }
    }

    private var totalExpenses: Int {
        groups.reduce(0) { $0 + $1.expenses.count }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    header
                    summaryCard

                    HStack {
                        Text("Your Groups")
                            .font(.title3)
                            .fontWeight(.bold)

                        Spacer()

                        Text("\(groups.count)")
                            .foregroundStyle(.secondary)
                    }

                    if groups.isEmpty {
                        emptyState
                    } else {
                        ForEach($groups) { $group in
                            NavigationLink {
                                GroupDetailView(group: $group)
                            } label: {
                                GroupCard(group: group)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        showingAddGroup = true
                    } label: {
                        Label(
                            "Create New Group",
                            systemImage: "plus"
                        )
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGroup) {
                AddGroupView(groups: $groups)
            }
            .onAppear {
                if !hasLoadedData {
                    loadData()
                    hasLoadedData = true
                }
            }
            .onChange(of: groups) {
                if hasLoadedData {
                    PersistenceService.save(groups)
                }
            }
        }
    }

    private func loadData() {
        if let savedGroups = PersistenceService.load() {
            groups = savedGroups
        } else {
            groups = sampleGroups
        }
    }

    private var sampleGroups: [ExpenseGroup] {
        [
            ExpenseGroup(
                name: "Goa Trip",
                members: [
                    "Karan",
                    "Arjun",
                    "Rohan",
                    "Ved"
                ],
                expenses: [
                    Expense(
                        title: "Hotel",
                        amount: 8000,
                        paidBy: "Karan"
                    ),
                    Expense(
                        title: "Dinner",
                        amount: 2400,
                        paidBy: "Arjun"
                    ),
                    Expense(
                        title: "Cab",
                        amount: 1200,
                        paidBy: "Rohan"
                    )
                ]
            )
        ]
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {

            HStack {
                Image(
                    systemName:
                        "arrow.left.arrow.right.circle.fill"
                )
                .font(.largeTitle)
                .foregroundStyle(.blue)

                Text("SplitMate")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()
            }

            Text("Split expenses. Stay even.")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 10)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("TOTAL SHARED")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(
                        "₹\(totalShared, specifier: "%.0f")"
                    )
                    .font(
                        .system(
                            size: 34,
                            weight: .bold
                        )
                    )
                }

                Spacer()

                Image(
                    systemName:
                        "indianrupeesign.circle.fill"
                )
                .font(.system(size: 42))
                .foregroundStyle(.blue)
            }

            Divider()

            HStack {
                Label(
                    "\(groups.count) active \(groups.count == 1 ? "group" : "groups")",
                    systemImage: "person.3.fill"
                )

                Spacer()

                Text(
                    "\(totalExpenses) \(totalExpenses == 1 ? "expense" : "expenses")"
                )
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text("No groups yet")
                .font(.headline)

            Text(
                "Create a group to start splitting expenses."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

#Preview {
    ContentView()
}
