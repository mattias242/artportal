import Foundation

struct Observation: Codable, Identifiable {
    let taxonId: Int
    let taxonVernacular: String
    let taxonScientific: String
    let date: String
    let time: String
    let count: Int
    let recordedBy: String
    let locality: String
    let municipality: String

    var id: String {
        "\(taxonId)-\(date)-\(time)-\(recordedBy)"
    }

    var dateTime: String {
        "\(date) \(time)"
    }
}

struct ObservationsResponse: Codable {
    let observations: [Observation]
    let count: Int
}
