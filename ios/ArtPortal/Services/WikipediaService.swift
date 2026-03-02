import Foundation

actor WikipediaService {
    static let shared = WikipediaService()

    private var cache: [String: BirdInfo] = [:]

    func fetchBirdInfo(scientificName: String) async -> BirdInfo {
        if let cached = cache[scientificName] {
            return cached
        }

        // Try Swedish Wikipedia first, then English
        let languages = ["sv", "en"]

        for lang in languages {
            if let info = await fetchFromWikipedia(scientificName: scientificName, language: lang) {
                cache[scientificName] = info
                return info
            }
        }

        let fallback = BirdInfo(imageURL: nil, description: "", wikiURL: nil)
        cache[scientificName] = fallback
        return fallback
    }

    private func fetchFromWikipedia(scientificName: String, language: String) async -> BirdInfo? {
        let encoded = scientificName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? scientificName
        let urlString = "https://\(language).wikipedia.org/api/rest_v1/page/summary/\(encoded)"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }

            let summary = try JSONDecoder().decode(WikipediaSummary.self, from: data)

            // Skip disambiguation pages
            if summary.type == "disambiguation" {
                return nil
            }

            let imageURL: URL?
            if let source = summary.thumbnail?.source {
                imageURL = URL(string: source)
            } else {
                imageURL = nil
            }

            let wikiURL: URL?
            if let page = summary.contentUrls?.mobile?.page {
                wikiURL = URL(string: page)
            } else {
                wikiURL = nil
            }

            return BirdInfo(
                imageURL: imageURL,
                description: summary.extract ?? "",
                wikiURL: wikiURL
            )
        } catch {
            return nil
        }
    }
}
