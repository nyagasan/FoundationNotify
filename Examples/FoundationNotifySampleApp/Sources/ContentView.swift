import SmartNotifications
import SwiftUI

struct ContentView: View {
    @State private var viewModel = SmartNotificationViewModel()

    var body: some View {
        NavigationStack {
            Form {
                statusSection
                inputSection
                actionSection
                resultSection
                pendingRequestsSection
            }
            .navigationTitle("FoundationNotify Sample")
            .task {
                await viewModel.refresh()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private var statusSection: some View {
        Section("Status") {
            LabeledContent("Authorization", value: viewModel.authorizationStatusText)
            LabeledContent("Foundation Models", value: viewModel.foundationModelsStatusText)
            if let availability = viewModel.systemLanguageModelAvailabilityText {
                LabeledContent("SystemLanguageModel", value: availability)
            }
        }
    }

    private var inputSection: some View {
        Section("Input") {
            TextField("Context", text: $viewModel.context, axis: .vertical)
                .lineLimit(3...6)

            Picker("Tone", selection: $viewModel.tone) {
                ForEach(NotificationTone.allCases, id: \.self) { tone in
                    Text(tone.rawValue.capitalized).tag(tone)
                }
            }

            Picker("Intent", selection: $viewModel.intent) {
                ForEach(NotificationIntent.allCases, id: \.self) { intent in
                    Text(intent.rawValue.capitalized).tag(intent)
                }
            }

            Picker("Delay", selection: $viewModel.delayMinutes) {
                ForEach(DelayOption.allCases) { option in
                    Text(option.label).tag(option.minutes)
                }
            }
        }
    }

    private var actionSection: some View {
        Section {
            Button("Request Permission") {
                Task { await viewModel.requestPermission() }
            }
            .disabled(viewModel.isRunning)

            Button("Generate Draft") {
                Task { await viewModel.generateDraft() }
            }
            .disabled(viewModel.isRunning)

            Button("Generate + Schedule") {
                Task { await viewModel.generateAndSchedule() }
            }
            .disabled(viewModel.isRunning)

            if viewModel.isRunning {
                HStack {
                    ProgressView()
                    Text("Running...")
                }
            }
        }
    }

    private var resultSection: some View {
        Section("Latest Result") {
            if let draft = viewModel.latestDraft {
                LabeledContent("Title", value: draft.title)
                LabeledContent("Body", value: draft.body)
                LabeledContent("Category", value: draft.categoryIdentifier ?? "-")
            } else {
                Text("No draft yet.")
                    .foregroundStyle(.secondary)
            }

            if let identifier = viewModel.lastScheduledIdentifier {
                LabeledContent("Scheduled ID", value: identifier)
            }

            if let errorMessage = viewModel.lastErrorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
    }

    private var pendingRequestsSection: some View {
        Section("Pending Notifications") {
            if viewModel.pendingRequests.isEmpty {
                Text("No pending requests.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.pendingRequests) { request in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(request.title)
                            .font(.headline)
                        Text(request.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(request.identifier)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
