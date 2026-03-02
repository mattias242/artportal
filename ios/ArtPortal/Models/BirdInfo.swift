import Foundation

struct BirdInfo {
    let imageURL: URL?
    let description: String
    let wikiURL: URL?
}

struct WikipediaSummary: Codable {
    let type: String?
    let title: String?
    let extract: String?
    let thumbnail: WikipediaThumbnail?
    let contentUrls: WikipediaContentURLs?

    enum CodingKeys: String, CodingKey {
        case type, title, extract, thumbnail
        case contentUrls = "content_urls"
    }
}

struct WikipediaThumbnail: Codable {
    let source: String?
}

struct WikipediaContentURLs: Codable {
    let mobile: WikipediaURL?
}

struct WikipediaURL: Codable {
    let page: String?
}
