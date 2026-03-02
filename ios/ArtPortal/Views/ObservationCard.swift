import SwiftUI

struct ObservationCard: View {
    let observation: Observation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(observation.taxonVernacular)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color("Primary"))

            Text(observation.taxonScientific)
                .font(.caption)
                .italic()
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(observation.date, systemImage: "calendar")
                Label(observation.time, systemImage: "clock")
                Label("\(observation.count)", systemImage: "number")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !observation.locality.isEmpty {
                Label(observation.locality, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !observation.recordedBy.isEmpty {
                Label(observation.recordedBy, systemImage: "person")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
    }
}
