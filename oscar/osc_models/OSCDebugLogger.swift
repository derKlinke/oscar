//
//  OSCDebugLogger.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-30.
//

import SwiftUI
import OSLog

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
    
    var qeuue = DispatchQueue(label: "OSCDebugLoggerQueue", qos: .background)
    
    var osLog = Logger(subsystem: "studio.klinke.Oscar", category: "OSCDebugLogger")

    func log(_ message: String, level: LogLevel = .info) {
        let date = Date()
        let message = OSCDebugLogMessage(date: date, level: level, message: message)
        
        qeuue.async {
            self.log.append(message)
            self.osLog.info("\(message.level.rawValue): \(message.message)")
        }
    }
}
