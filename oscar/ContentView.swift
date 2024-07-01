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

    @State private var consoleHeight: CGFloat = 200

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
            // sidebar
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

                HStack {
                    TextField("Port", value: $newPort, formatter: NumberFormatter())
                        .textFieldStyle(KSTextFieldStyle())
                        .onSubmit {
                            addNewServer()
                        }

                    Button {
                        addNewServer()
                        selectedPort = newPort
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(DefaultsButtonStyle(color: .ground))
                }
                .padding()
            }
            .padding(.top, 40)
            .containerRelativeFrame(.horizontal) { length, axis in
                if axis == .horizontal {
                    max(length / 10, 200)
                } else {
                    length
                }
            }
            .background(.ground.opacity(0.8))

            Rectangle()
                .fill(Color.accent)
                .frame(width: 1)

            // main content
            VStack(spacing: 0) {
                // upper main
                HStack(spacing: 0) {
                    VStack {
                        OSCChannelTableView(oscServers: $oscServers, selectedPort: $selectedPort,
                                            selectedChannels: $selectedChannels)
                    }
                    .padding(.top, 20)
                    .containerRelativeFrame(.horizontal) { length, axis in
                        if axis == .horizontal {
                            min(max(length / 3, 400), 600)
                        } else {
                            length
                        }
                    }

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
                .background(Color.ground)

                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: 1)

                // lower status/menu bar
                HStack(spacing: 0) {
                    Text("ip: \(getIPAddress() ?? "???")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 5)

                    Rectangle()
                        .fill(.clear)
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .onHover { inside in
                            if inside {
                                NSCursor.resizeUpDown.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }

                    Button {
                        isShowingDebugConsole.toggle()
                    } label: {
                        if isShowingDebugConsole {
                            Image(systemName: "chevron.down")
                        } else {
                            Image(systemName: "chevron.up")
                        }
                    }
                    .buttonStyle(DefaultsButtonStyle(color: .clear))
                }
                .background(Color.ground.opacity(0.8))
                .gesture(DragGesture()
                    .onChanged { gesture in
                        let delta = gesture.translation.height

                        consoleHeight = max(100, min(500, consoleHeight - delta))
                    })

                // debug console
                if isShowingDebugConsole {
                    Rectangle()
                        .fill(Color.accent)
                        .frame(height: 1)

                    DebugConsoleView(logger: $logger)
                        .background(Color.ground.opacity(0.8))
                        .frame(height: consoleHeight)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
