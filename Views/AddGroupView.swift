import SwiftUI

struct AddGroupView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Binding var groups: [ExpenseGroup]

    @State private var groupName = ""
    @State private var members = ""

    private var parsedMembers: [String] {
        members
            .split(separator: ",")
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Group") {
                    TextField(
                        "e.g. Goa Trip",
                        text: $groupName
                    )
                }

                Section {
                    TextField(
                        "Karan, Arjun, Rohan...",
                        text: $members
                    )
                } header: {
                    Text("Members")
                } footer: {
                    Text(
                        "Separate member names using commas."
                    )
                }
            }
            .navigationTitle("Create Group")
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
                    Button("Create") {
                        createGroup()
                    }
                    .disabled(
                        groupName
                            .trimmingCharacters(
                                in: .whitespaces
                            )
                            .isEmpty ||
                        parsedMembers.isEmpty
                    )
                }
            }
        }
    }

    private func createGroup() {
        groups.append(
            ExpenseGroup(
                name: groupName.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                members: parsedMembers
            )
        )

        dismiss()
    }
}
