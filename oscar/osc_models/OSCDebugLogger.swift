//
//  OSCDebugLogger.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-30.
//

import SwiftUI

enum LogLevel: String {
    case info
    case warning
    case error
}

struct OSCDebugLogMessage: Identifiable {
    let id = UUID()
    let date: Date
    let level: LogLevel
    let message: String
}

// MARK: - OSCDebugLogger
@Observable
class OSCDebugLogger {
    var log = [OSCDebugLogMessage]()

    func log(_ message: String, level: LogLevel = .info) {
        let date = Date()
        
        let message = OSCDebugLogMessage(date: date, level: level, message: message)
        log.append(message)
    }
}
