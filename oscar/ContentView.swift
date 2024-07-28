//
//  ContentView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-25.
//

import Defaults
import SwiftUI
import trs_system

// MARK: - ContentView
struct ContentView: View {
    @State private var logger = OSCDebugLogger()
    @State private var oscServers = [Int: OSCObserver]()
    @State private var newPort: Int = Defaults[.defaultPort]
    @StateObject private var colorManager = TRSColorManager.shared

    @State private var selectedPort: Int?
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
            VStack(spacing: 0) {
                Text("Servers")
                    .font(trs: .headline, alignment: .left)
                    .hidden()

                TRSList(data: Array(oscServers.keys), id: \.self, singleSelection: $selectedPort) { port in
                    HStack {
                        Spacer()

                        let formatter = NumberFormatter()
                        Text("\(formatter.string(from: NSNumber(value: port)) ?? "???")")
                            .font(trs: .body, padding: false)
                    }
                }

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
                    .buttonStyle(DefaultsButtonStyle(color: DynamicTRSColor.contentBackground.color))
                }
            }
            .padding(trs: .medium, edges: .horizontal)
            .padding(trs: .extraLarge, edges: .top)
            .padding(trs: .medium, edges: .bottom)
            .containerRelativeFrame(.horizontal) { length, axis in
                if axis == .horizontal {
                    max(length / 10, 200)
                } else {
                    length
                }
            }
            .background(DynamicTRSColor.secondaryContentBackground.color)

            VerticalSeperator()

            // main content
            VStack(spacing: 0) {
                // upper main
                HStack(spacing: 0) {
                    VStack {
                        OSCChannelTableView(oscServers: $oscServers, selectedPort: $selectedPort,
                                            selectedChannels: $selectedChannels)
                    }
                    .padding(trs: .extraLarge, edges: .top)
                    .containerRelativeFrame(.horizontal) { length, axis in
                        if axis == .horizontal {
                            min(max(length / 3, 400), 600)
                        } else {
                            length
                        }
                    }

                    VerticalSeperator()

                    VStack {
                        DynamicChanelDetailGridView(oscServers: $oscServers, selectedPort: $selectedPort,
                                                    selectedChannels: $selectedChannels)
                    }
                    .frame(maxWidth: .infinity)
                }
                .background(DynamicTRSColor.contentBackground.color)

                HorizontalSeperator()

                // lower status/menu bar
                HStack(spacing: 0) {
                    Text("ip: \(getIPAddress() ?? "???")")
                        .font(trs: .caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 5)
                        .frame(height: 20)
                        .contextMenu {
                            // copy ip to clipboard
                            Button {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(getIPAddress() ?? "", forType: .string)
                            } label: {
                                Text("Copy IP")
                            }
                        }

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
                .background(DynamicTRSColor.secondaryContentBackground.color)
                .gesture(DragGesture()
                    .onChanged { gesture in
                        let delta = gesture.translation.height

                        consoleHeight = max(100, min(500, consoleHeight - delta))
                    })

                // debug console
                if isShowingDebugConsole {
                    HorizontalSeperator()

                    DebugConsoleView(logger: $logger)
                        .background(DynamicTRSColor.secondaryContentBackground.color)
                        .frame(height: consoleHeight)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .environmentObject(colorManager)
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

#Preview {
    ContentView()
}
