import SwiftUI

struct BirdDetailView: View {
    let observation: Observation
    @State private var birdInfo: BirdInfo?
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Image section
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 220)

                        if isLoading {
                            ProgressView()
                        } else if let imageURL = birdInfo?.imageURL {
                            AsyncImage(url: imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipped()
                                case .failure:
                                    noImageView
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    noImageView
                                }
                            }
                        } else {
                            noImageView
                        }
                    }
                    .frame(height: 220)

                    // Info section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(observation.taxonVernacular)
                            .font(.title2.weight(.bold))

                        Text(observation.taxonScientific)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.secondary)

                        if let info = birdInfo, !info.description.isEmpty {
                            Text(info.description)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }

                        Divider()

                        // Observation details
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(icon: "calendar", label: "Datum", value: observation.date)
                            DetailRow(icon: "clock", label: "Tid", value: observation.time)
                            DetailRow(icon: "number", label: "Antal", value: "\(observation.count)")
                            if !observation.locality.isEmpty {
                                DetailRow(icon: "mappin.and.ellipse", label: "Plats", value: observation.locality)
                            }
                            if !observation.recordedBy.isEmpty {
                                DetailRow(icon: "person", label: "Observatör", value: observation.recordedBy)
                            }
                        }

                        // Links
                        VStack(spacing: 10) {
                            Link(destination: URL(string: "https://artfakta.se/taxa/\(observation.taxonId)")!) {
                                HStack {
                                    Image(systemName: "leaf")
                                    Text("Visa på Artfakta")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color("Primary"))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            if let wikiURL = birdInfo?.wikiURL {
                                Link(destination: wikiURL) {
                                    HStack {
                                        Image(systemName: "book")
                                        Text("Läs mer på Wikipedia")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Stäng") { dismiss() }
                }
            }
        }
        .task {
            let info = await WikipediaService.shared.fetchBirdInfo(
                scientificName: observation.taxonScientific
            )
            birdInfo = info
            isLoading = false
        }
    }

    private var noImageView: some View {
        VStack(spacing: 8) {
            Image(systemName: "bird")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Ingen bild tillgänglig")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color("Primary"))
                .frame(width: 20)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }
}
