import SwiftUI

@main
struct AtlasSatSimApp: App {
    var body: some Scene {
        WindowGroup {
            SimulatorView()
        }
    }
}

private struct Scenario: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let trace: [String]

    static let all: [Scenario] = [
        Scenario(
            id: "capabilities",
            title: "Capability check",
            subtitle: "Model a local capability query",
            symbol: "checkmark.seal",
            trace: [
                "CommCenter: query satellite capability",
                "Fake modem: report capability=true",
                "Result: capability discovery completed using a scripted fake response"
            ]
        ),
        Scenario(
            id: "demo",
            title: "Demo flow",
            subtitle: "Show simulated satellite guidance",
            symbol: "location.north.circle",
            trace: [
                "CommCenter: query satellite capability",
                "Fake modem: report capability=true",
                "UI model: demo flow requested",
                "UI model: display simulated satellite guidance",
                "Result: demo flow completed; no SOS was sent"
            ]
        ),
        Scenario(
            id: "registration-ok",
            title: "Registration accepted",
            subtitle: "Use a scripted success response",
            symbol: "antenna.radiowaves.left.and.right",
            trace: [
                "CommCenter: begin simulated registration",
                "Fake modem: return registration-accepted response",
                "CommCenter: state=registered (simulated)",
                "Result: scenario completed; no radio transmission occurred"
            ]
        ),
        Scenario(
            id: "registration-fail",
            title: "Registration rejected",
            subtitle: "Exercise the local error path",
            symbol: "exclamationmark.triangle",
            trace: [
                "CommCenter: begin simulated registration",
                "Fake modem: return registration-rejected response",
                "CommCenter: state=registration-failed (simulated)",
                "Result: scenario completed; no radio transmission occurred"
            ]
        )
    ]
}

private struct SimulatorView: View {
    @State private var selected: Scenario?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    safetyNotice

                    Text("Choose a local scenario")
                        .font(.title3.weight(.semibold))

                    ForEach(Scenario.all) { scenario in
                        Button {
                            selected = scenario
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: scenario.symbol)
                                    .font(.title2)
                                    .frame(width: 36)
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scenario.title).font(.headline)
                                    Text(scenario.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }

                    Text("All results are scripted examples. This app does not communicate with an iPhone modem or satellite network.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Atlas Sat Sim")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selected) { scenario in
                TraceSheet(scenario: scenario)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var safetyNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("SIMULATION ONLY", systemImage: "antenna.radiowaves.left.and.right.slash")
                .font(.caption.weight(.bold))
                .foregroundStyle(.orange)
            Text("No SOS is sent. No modem, CommCenter service, or network is contacted.")
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.orange.opacity(0.35), lineWidth: 1))
    }
}

private struct TraceSheet: View {
    @Environment(\.dismiss) private var dismiss
    let scenario: Scenario

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Fake transport · local only", systemImage: "desktopcomputer")
                        .foregroundStyle(.secondary)
                }
                Section("Trace") {
                    ForEach(Array(scenario.trace.enumerated()), id: \.offset) { index, line in
                        HStack(alignment: .top, spacing: 12) {
                            Text(String(format: "%02d", index + 1))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                            Text(line)
                                .font(.system(.subheadline, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
            .navigationTitle(scenario.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
