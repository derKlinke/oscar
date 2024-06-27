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

    var openChannels = [OSCChannel]()

    init(port: UInt16) {
        self.port = port

        oscServer = OSCServer(port: port)

        do { try self.start() } catch { print("Error starting OSCServer: \(error)") }
        
        print("OSCObserver initialized on port \(port)")
    }

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
        }
    }

    func start() throws {
        oscServer.setHandler(handleMessage)
        try oscServer.start()
    }

    var isRunning: Bool {
        oscServer.isStarted
    }

    var id: UInt16 { port }
}
