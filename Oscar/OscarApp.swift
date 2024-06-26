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
    
    // close app when last window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

// MARK: - OscarApp
@main
struct OscarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
