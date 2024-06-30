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
    @State private var logger = OSCDebugLogger()
    @State private var oscServers = [UInt16: OSCObserver]()
    @State private var newPort: UInt16 = Defaults[.defaultPort]

    @State private var selectedPort: UInt16?
    @State private var selectedChannels: Set<String> = []

    @Default(.isShowingDebugConsole) private var isShowingDebugConsole
    @State var isPresentingAddServer = false

    fileprivate func addNewServer() {
        if oscServers[newPort] == nil {
            oscServers[newPort] = OSCObserver(port: newPort, logger: logger)
        } else {
            logger.log("Port \(newPort) already exists", level: .warning)
        }
        
        // FIXME: sort the servers by port
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                List(selection: $selectedPort) {
                    ForEach(Array(oscServers.keys), id: \.self) { port in
                        HStack {
                            let formatter = NumberFormatter()
                            Text("\(formatter.string(from: NSNumber(value: port)) ?? "???")")
                                .font(.body)
                                .tag(port)
                            
                            Spacer()
                        }
                            
                    }
                }
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden)

                Spacer()

                HStack(spacing: 0) {
                    TextField("Port", value: $newPort, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            addNewServer()
                        }
                        .textFieldStyle(.squareBorder)

                    Button {
                        addNewServer()
                        selectedPort = newPort
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .padding(5)
            }
            .padding(.top, 40)
            .frame(width: 200)
            .background(.regularMaterial)

            Rectangle()
                .fill(Color.accent)
                .frame(width: 1)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack {
                        OSCChannelTableView(oscServers: $oscServers, selectedPort: $selectedPort,
                                            selectedChannels: $selectedChannels)
                    }
                    .padding(.top, 20)
                    .frame(width: 400)

                    Rectangle()
                        .fill(Color.accent)
                        .frame(width: 1)

                    VStack {
                        DynamicChanelDetailGridView(oscServers: $oscServers, selectedPort: $selectedPort,
                                                    selectedChannels: $selectedChannels)
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity)
                }

                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 1)

                HStack(spacing : 0) {
                    Spacer()

                    Button {
                        isShowingDebugConsole.toggle()
                    } label: {
                        if isShowingDebugConsole {
                            Image(systemName: "chevron.down")
                        } else {
                            Image(systemName: "chevron.up")
                        }
                    }
                    .buttonStyle(DefaultsButtonStyle(color: .ground))
                }
                .padding(5)

                if isShowingDebugConsole {
                    Rectangle()
                        .fill(Color.accent)
                        .frame(height: 1)

                    DebugConsoleView(logger: $logger)
                }
            }
            .background(Color.ground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}



#Preview {
    ContentView()
}
