//
//  OscarApp.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-25.
//

import Defaults
import Sparkle
import SwiftUI

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
        .windowToolbarStyle(.unifiedCompact)

        // settings
        Settings {
            SettingsView(updater: updaterController.updater)
        }
    }
}
