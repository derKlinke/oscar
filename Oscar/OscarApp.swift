//
//  OscarApp.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-25.
//

import Sparkle
import SwiftUI

// MARK: - AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {}
}

// MARK: - OscarApp
@main
struct OscarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let updaterController: SPUStandardUpdaterController

    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater()
        // later
        // This is where you can also pass an updater delegate if you need one
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
    }
}
