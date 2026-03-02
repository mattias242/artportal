import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ObservationsViewModel()
    @State private var selectedObservation: Observation?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and sort controls
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Sök art...", text: $viewModel.searchText)
                                .autocorrectionDisabled()
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        Menu {
                            Picker("Sortering", selection: $viewModel.sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Text(viewModel.summaryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.bar)

                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Hämtar observationer...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text(error)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Försök igen") {
                            Task { await viewModel.loadObservations() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    Spacer()
                } else if viewModel.filteredObservations.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "binoculars")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Inga observationer hittades")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.filteredObservations) { observation in
                                ObservationCard(observation: observation)
                                    .onTapGesture {
                                        selectedObservation = observation
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Fågelobservationer")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("Primary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedObservation) { observation in
                BirdDetailView(observation: observation)
            }
        }
        .task {
            await viewModel.loadObservations()
        }
    }
}

#Preview {
    ContentView()
}
