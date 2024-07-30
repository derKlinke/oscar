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

    @State private var consoleHeight: CGFloat
    
    @StateObject private var toastManager = ToastManager()
    
    private let kDefaultConsoleHeight: CGFloat = 200

    @Default(.isShowingDebugConsole) private var isShowingDebugConsole
    @State var isPresentingAddServer = false
    
    init() {
        consoleHeight = kDefaultConsoleHeight
    }

    fileprivate func addNewServer() {
        if oscServers[newPort] == nil {
            // TRSSoundManager.shared.play(sound: .add)
            oscServers[newPort] = OSCObserver(port: newPort, logger: logger)
        } else {
            // TRSSoundManager.shared.play(sound: .error)
            logger.log("Port \(newPort) already exists", level: .warning)
        }
        
        self.selectedPort = newPort

        // FIXME: sort the servers by port
    }

    var body: some View {
        SidebarStack {
            Text("Servers")
                .font(trs: .headline, alignment: .left)
                .hidden()

            TRSList(data: Array(oscServers.keys).sorted(), id: \.self,
                    singleSelection: $selectedPort) { port in
                HStack {
                    if let server = oscServers[port] {
                        if server.inErrorState {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(TRSColors.red.trsColor.opacity(0.8).color)
                                .help(server.errorMessage)
                        }
                    }
                    Spacer()

                    let formatter = NumberFormatter()
                    Text("\(formatter.string(from: NSNumber(value: port)) ?? "???")")
                        .font(trs: .body, padding: false)
                }
            }

            Spacer()

            HStack {
                TextField("Port", value: $newPort, formatter: NumberFormatter())
                    .textFieldStyle(TRSTextFieldStyle())
                    .onSubmit {
                        addNewServer()
                    }

                Button {
                    addNewServer()
                    selectedPort = newPort
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(TRSButtonStyle())
            }

        } content: {
            // upper main
            HStack(spacing: 0) {
                VStack {
                    OSCChannelTableView(oscServers: $oscServers, selectedPort: $selectedPort,
                                        selectedChannels: $selectedChannels)
                }
                .padding(.top, .huge)
                .containerRelativeFrame(.horizontal) { length, axis in
                    if axis == .horizontal {
                        min(max(length / 3, 400), 600)
                    } else {
                        length
                    }
                }
                .frame(maxHeight: .infinity)
                .background(DynamicTRSColor.contentBackground.color)

                Separator(.vertical)

                VStack {
                    DynamicChanelDetailGridView(oscServers: $oscServers, selectedPort: $selectedPort,
                                                selectedChannels: $selectedChannels)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DynamicTRSColor.contentBackground.color)
            }

            Separator(.horizontal, size: .small)

            // lower status/menu bar
            HStack(spacing: 0) {
                let ipString = getIPAddress() ?? "???"
                TapToCopy(ipString) {
                    Text("IP: \(ipString)")
                        .font(trs: .caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, .tiny)
                        .frame(height: .medium)
                }

                Rectangle()
                    .fill(.clear)
                    .frame(height: 20)
                    .frame(maxWidth: .infinity)
                    .onHover { inside in
                        if inside, isShowingDebugConsole {
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
                .buttonStyle(TRSButtonStyle(color: .clear))
            }
            .background(DynamicTRSColor.secondaryContentBackground.color)
            .gesture(DragGesture()
                .onChanged { gesture in
                    let delta = gesture.translation.height

                    if consoleHeight - delta < 50 {
                        isShowingDebugConsole = false
                    }

                    consoleHeight = max(100, min(500, consoleHeight - delta))
                })
            .onTapGesture(count: 2) {
                isShowingDebugConsole.toggle()
                consoleHeight = kDefaultConsoleHeight
            }
            .zIndex(1)

            // debug console
            if isShowingDebugConsole {
                Separator(.horizontal, size: .small)

                DebugConsoleView(logger: $logger)
                    .background(DynamicTRSColor.secondaryContentBackground.color)
                    .frame(height: consoleHeight)
                    .zIndex(-1)
            }
        }
        .environmentObject(colorManager)
        .environmentObject(toastManager)
    }
}

// MARK: - Int + Identifiable
extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    ContentView()
}
