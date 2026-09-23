import Foundation

struct PersistenceService {

    private static let storageKey = "savedGroups"

    static func save(_ groups: [ExpenseGroup]) {

        do {

            let data = try JSONEncoder().encode(groups)

            UserDefaults.standard.set(
                data,
                forKey: storageKey
            )

        } catch {

            print(
                "Failed to save groups: \(error.localizedDescription)"
            )
        }
    }

    static func load() -> [ExpenseGroup]? {

        guard let data =
                UserDefaults.standard.data(
                    forKey: storageKey
                )
        else {
            return nil
        }

        do {

            return try JSONDecoder().decode(
                [ExpenseGroup].self,
                from: data
            )

        } catch {

            print(
                "Failed to load groups: \(error.localizedDescription)"
            )

            return nil
        }
    }
}
