import SwiftUI

struct InsightsView: View {

    let group: ExpenseGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Label("Insights", systemImage: "chart.bar.fill")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()
            }

            HStack(spacing: 12) {
                InsightCard(
                    title: "AVERAGE",
                    value: "₹\(Int(group.averageExpense).formatted())",
                    icon: "chart.line.uptrend.xyaxis"
                )

                InsightCard(
                    title: "LARGEST",
                    value: largestExpenseValue,
                    icon: "arrow.up.right"
                )
            }

            if let topPayer = group.topPayer {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 44, height: 44)

                        Image(systemName: "crown.fill")
                            .foregroundStyle(.blue)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Top Payer")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(topPayer.name)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    Text("₹\(topPayer.amount, specifier: "%.0f")")
                        .fontWeight(.bold)
                }
                .padding(16)
                .background(
                    Color(.secondarySystemGroupedBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }
        }
    }

    private var largestExpenseValue: String {
        guard let expense = group.largestExpense else {
            return "₹0"
        }

        return "₹\(Int(expense.amount).formatted())"
    }
}

struct InsightCard: View {

    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}//
//  InsightsView.swift
//  SplitMate
//
//  Created by Karan Kumar on 23/09/26.
//

