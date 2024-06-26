//
//  OscarApp.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-25.
//

import Sparkle
import SwiftUI
import Defaults

// MARK: - AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {}

    // close app when last window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

// MARK: - OscarApp
@main
struct OscarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private var updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil,
                                                         userDriverDelegate: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }

        // settings
        Settings {
            SettingsView(updater: updaterController.updater)
        }
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    let updater: SPUUpdater

    @State private var autoUpdate = false
    @Default(.sampleFreq) private var sampleFreq
    @Default(.maxSamples) private var maxSamples
    @Default(.defaultPort) private var defaultPort
    
    init(updater: SPUUpdater) {
        self.updater = updater
        _autoUpdate = State(initialValue: updater.automaticallyChecksForUpdates)
    }

    var body: some View {
        // saprkle auto-updater settings
        TabView {
            VStack {
                HStack {
                    Text("Default Port: ")
                    TextField("Default Port", value: $defaultPort, formatter: NumberFormatter())
                }
                Spacer()
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            VStack {
                HStack {
                    Text("Samlping Frequency: ")
                    TextField("Sample Frequency", value: $sampleFreq, formatter: NumberFormatter())
                }
                HStack {
                    Text("Max Samples: ")
                    TextField("Max Samples", value: $maxSamples, formatter: NumberFormatter())
                }
                Spacer()
            }
            .padding()
            .tabItem {
                Label("Plots", systemImage: "waveform.path.ecg")
            }
            
            VStack {
                Toggle("Automatically check for updates", isOn: $autoUpdate)
                    .onChange(of: autoUpdate) { _ in
                        updater.automaticallyChecksForUpdates = autoUpdate
                    }
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("Updates", systemImage: "arrow.triangle.2.circlepath")
            }
        }.frame(minWidth: 600, minHeight: 300)
    }
}

// MARK: - CheckForUpdatesViewModel
final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

// MARK: - CheckForUpdatesView
struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater

        // Create our view model for our CheckForUpdatesView
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }

    var body: some View {
        Button("Check for Updates…", action: updater.checkForUpdates)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}
