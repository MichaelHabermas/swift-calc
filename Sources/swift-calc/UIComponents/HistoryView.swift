import SwiftUI
import ViewModels
import Utilities

struct HistoryView: View {
    let entries: [HistoryEntry]
    let onTap: (HistoryEntry) -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("History")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 12)
                Spacer()
                if !entries.isEmpty {
                    Button("Clear") { onClear() }
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                        .padding(.trailing, 12)
                        .accessibilityLabel("Clear history")
                        .accessibilityHint("Removes all history entries")
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 4)

            if entries.isEmpty {
                Text("No history yet")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(entries) { entry in
                            Button {
                                onTap(entry)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.expression)
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                        Text(entry.result)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.primary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(entry.expression) equals \(entry.result)")
                            .accessibilityHint("Tap to restore result")

                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
