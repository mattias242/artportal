import Foundation

enum SortOption: String, CaseIterable {
    case dateDesc = "Nyast först"
    case dateAsc = "Äldst först"
    case speciesAsc = "Art A–Ö"
    case countDesc = "Flest individer"
}

@MainActor
final class ObservationsViewModel: ObservableObject {
    @Published var observations: [Observation] = []
    @Published var searchText = ""
    @Published var sortOption: SortOption = .dateDesc
    @Published var isLoading = false
    @Published var errorMessage: String?

    var filteredObservations: [Observation] {
        let filtered: [Observation]
        if searchText.isEmpty {
            filtered = observations
        } else {
            let query = searchText.lowercased()
            filtered = observations.filter { obs in
                obs.taxonVernacular.lowercased().contains(query) ||
                obs.taxonScientific.lowercased().contains(query)
            }
        }

        return sorted(filtered)
    }

    var summaryText: String {
        let total = observations.count
        let shown = filteredObservations.count
        if searchText.isEmpty {
            return "\(total) observationer"
        }
        return "\(shown) av \(total) observationer"
    }

    func loadObservations() async {
        isLoading = true
        errorMessage = nil

        do {
            observations = try await APIService.shared.fetchObservations()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func sorted(_ observations: [Observation]) -> [Observation] {
        switch sortOption {
        case .dateDesc:
            return observations.sorted { $0.dateTime > $1.dateTime }
        case .dateAsc:
            return observations.sorted { $0.dateTime < $1.dateTime }
        case .speciesAsc:
            return observations.sorted {
                $0.taxonVernacular.localizedCompare($1.taxonVernacular) == .orderedAscending
            }
        case .countDesc:
            return observations.sorted { $0.count > $1.count }
        }
    }
}
