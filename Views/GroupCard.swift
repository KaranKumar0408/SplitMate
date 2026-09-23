import SwiftUI

struct GroupCard: View {

    let group: ExpenseGroup
    
    private var groupIcon: String {
        let name = group.name.lowercased()

        if name.contains("trip") ||
            name.contains("goa") ||
            name.contains("dubai") ||
            name.contains("travel") {
            return "airplane"
        }

        if name.contains("home") ||
            name.contains("flat") ||
            name.contains("rent") {
            return "house.fill"
        }

        if name.contains("office") ||
            name.contains("work") {
            return "briefcase.fill"
        }

        if name.contains("party") ||
            name.contains("birthday") {
            return "party.popper.fill"
        }

        if name.contains("food") ||
            name.contains("dinner") {
            return "fork.knife"
        }

        return "person.3.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: groupIcon)
                        .foregroundStyle(.blue)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)

                    Text(
                        "\(group.members.count) members"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TOTAL SPENT")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(
                        "₹\(group.totalExpense, specifier: "%.0f")"
                    )
                    .font(.headline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("EXPENSES")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("\(group.expenses.count)")
                        .font(.headline)
                }
            }
        }
        .padding(18)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}
