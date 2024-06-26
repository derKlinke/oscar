//
//  ContentView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-25.
//

import Defaults
import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @State private var oscServers = [OSCObserver(port: Defaults[.defaultPort])]
    @State private var newPort: UInt16 = Defaults[.defaultPort]

    @State private var selectedPort: UInt16?
    @State private var selectedChannels: Set<String> = []

    @State var isPresentingAddServer = false

    var portFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        return formatter
    }

    fileprivate func addNewServer() {
        if oscServers.contains(where: { $0.port == newPort }) {
            print("port already observed!")
            return
        }

        oscServers.append(OSCObserver(port: newPort))
    }

    var body: some View {
        // side bar with all servers, main view with selected server and detail view with selected channel
        NavigationSplitView {
            List(selection: $selectedPort) {
                Section("open ports") {
                    ForEach(oscServers) { server in
                        Text(portFormatter.string(from: NSNumber(value: server.port)) ?? "???")
                    }
                }
            }

            Spacer()

            VStack {
                HStack(spacing: 0) {
                    TextField("Port", value: $newPort, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addNewServer()
                        }

                    Button("+") {
                        addNewServer()
                    }
                }
            }
            .padding()
        } content: {
            if let server = oscServers.first(where: { $0.port == selectedPort }) {
                OSCChannelTableView(server: server, selectedChannels: $selectedChannels)
            } else {
                Text("Select a server")
            }
        } detail: {
            if let server = oscServers.first(where: { $0.port == selectedPort }) {
                DynamicChanelDetailGridView(server: server, selectedChannels: $selectedChannels)
            } else {
                Text("Select a server")
            }
        }
        .navigationTitle(selectedPort != nil ?
            "Oscar - port \(portFormatter.string(from: NSNumber(value: selectedPort!)) ?? "???")" : "Oscar")
    }
}

#Preview {
    ContentView()
}
