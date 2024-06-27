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
    @State private var oscServers = [UInt16: OSCObserver]()
    @State private var newPort: UInt16 = Defaults[.defaultPort]

    @State private var selectedPort: UInt16?
    @State private var selectedChannels: Set<String> = []

    @State var isPresentingAddServer = false

    fileprivate func addNewServer() {
        if oscServers[newPort] == nil {
            oscServers[newPort] = OSCObserver(port: newPort)
        }
    }

    var body: some View {
        // side bar with all servers, main view with selected server and detail view with selected channel
        NavigationSplitView {
            List(selection: $selectedPort) {
                Section("open ports") {
                    ForEach(Array(oscServers.keys), id: \.self) { port in
                        let formatter = NumberFormatter()
                        Text("\(formatter.string(from: NSNumber(value: port)) ?? "???")")
                            .tag(port)
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
            OSCChannelTableView(oscServers: $oscServers, selectedPort: $selectedPort,
                                selectedChannels: $selectedChannels)
        } detail: {
            DynamicChanelDetailGridView(oscServers: $oscServers, selectedPort: $selectedPort, selectedChannels: $selectedChannels)
        }
        .background(Color.ground)
    }
}

#Preview {
    ContentView()
}
