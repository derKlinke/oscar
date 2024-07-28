//
//  OSCObserver.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import OSCKit
import SwiftUI

// MARK: - OSCObserver
@Observable
class OSCObserver: Identifiable {
    let port: UInt16
    private let oscServer: OSCServer
    private let logger: OSCDebugLogger

    var openChannels = [OSCChannel]()

    init(port: Int, logger: OSCDebugLogger) {
        self.port = UInt16(port)
        self.logger = logger

        oscServer = OSCServer(port: self.port)

        do { try self.start() }
        catch {
            print("Error starting OSCServer: \(error)")
            logger.log("Error starting OSCServer: \(error)", level: .error)
        }

        logger.log("Started OSCServer on port \(port)")
    }
    
    @MainActor
    func handleMessage(message: OSCMessage, timeTag: OSCTimeTag) {
        let channel = message.addressPattern.description
        let values = message.values

        // is the channel already open?
        if let index = openChannels.firstIndex(where: { $0.address == channel }) {
            openChannels[index].addNewValue(value: values[0])
        } else {
            let newChannel = OSCChannel(address: channel)
            newChannel.addNewValue(value: values[0])
            openChannels.append(newChannel)
            logger.log("received first value for channel \(channel): \(values[0])")
        }
    }

    func start() throws {
        oscServer.setHandler { [weak self] message, timeTag in
            guard let self else {
                return
            }
            Task {
                await self.handleMessage(message: message, timeTag: timeTag)
            }
        }
        try oscServer.start()
    }

    func stop() {
        oscServer.stop()
    }

    var isRunning: Bool {
        oscServer.isStarted
    }

    var id: UInt16 { port }

    var portString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter.string(from: NSNumber(value: port)) ?? "???"
    }
}
