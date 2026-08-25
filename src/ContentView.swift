import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading) {
            Text("Resolution").font(.title2).padding(.bottom, 3)
            HStack() {
                VStack(alignment: .leading) {
                    Text("Width").padding(.bottom, -4)
                    TextField("Width", text: $appState.width)
                }
                VStack(alignment: .leading) {
                    Text("Height").padding(.bottom, -4)
                    TextField("Height", text: $appState.height)
                }
            }.padding(.bottom)
            Text("Activate").font(.title2).padding(.bottom, 3)
            VStack(alignment: .leading) {
                Text("Activate only when one of these apps are in focus or always.").fixedSize(horizontal: false, vertical: true)
                ForEach(self.appState.games.sorted(by: {$0.value < $1.value}), id: \.key) { key, value in
                    HStack {
                        Toggle(value, isOn: Binding(
                            get: {self.appState.activegames[key] ?? false},
                            set: {v in self.appState.activegames[key] = v}
                        )).disabled(self.appState.active)
                        Spacer()
                        Button(action: { removeApp(key) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.secondary)
                        }.buttonStyle(.plain)
                    }
                }
                Toggle("Always", isOn: $appState.active)
                Button("Add Application...") {
                    addApp()
                }.padding(.top, 4)
            }
        }.padding(30).padding(.top, -5).frame(width: 340)
    }

    func addApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        let result = panel.runModal()
        guard result == .OK, let url = panel.url else {
            return // cancelled, nothing to report
        }

        guard let bundle = Bundle(url: url) else {
            showAlert("Failed to load bundle at \(url.path)")
            return
        }

        guard let bundleId = bundle.bundleIdentifier else {
            showAlert("No bundle identifier found for \(url.lastPathComponent).\nInfo: \(bundle.infoDictionary?.keys.joined(separator: ", ") ?? "none")")
            return
        }

        let name = (bundle.infoDictionary?["CFBundleDisplayName"] as? String)
            ?? (bundle.infoDictionary?["CFBundleName"] as? String)
            ?? url.deletingPathExtension().lastPathComponent

        appState.games[bundleId] = name
    }

    func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Add Application"
        alert.informativeText = message
        alert.runModal()
    }

    func removeApp(_ key: String) {
        appState.games.removeValue(forKey: key)
        appState.activegames.removeValue(forKey: key)
        showAlert("\"\(appState.games[key] ?? "Unknown")\" Application removed.")
    }
}