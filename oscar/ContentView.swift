//
//  ContentView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-25.
//

import Charts
import OSCKit
import SwiftUI
import Defaults

extension Defaults.Keys {
    static let sampleFreq = Key<Double>("sample_freq", default: 100)
    static let maxSamples = Key<Int>("max_samples", default: 100)
    static let defaultPort = Key<UInt16>("default_port", default: 8_000)
}

// MARK: - OSCChannel
@Observable
class OSCChannel: Identifiable {
    let address: String

    var values = [any OSCValue]()
    var timedValueBuffer = [any OSCValue]()

    var currentValue: (any OSCValue)?
    var lastTime: Date?

    init(address: String) {
        self.address = address
        let interval = Defaults[.sampleFreq]

        // every interval milliseconds we will add the current value to the buffer
        Timer.scheduledTimer(withTimeInterval: interval / 1_000.0, repeats: true) { _ in
            if let val = self.currentValue {
                self.timedValueBuffer.append(val)
            }

            if self.timedValueBuffer.count > Defaults[.maxSamples] {
                self.timedValueBuffer.removeFirst()
            }
        }
    }

    func addNewValue(value: any OSCValue) {
        currentValue = value
        values.append(value)
        lastTime = Date()
    }

    var lastValue: String {
        // TODO: use correct val
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        if let val = currentValue {
            if let val = val as? Float {
                return "\(formatter.string(from: NSNumber(value: val)) ?? "???" )"
            } else if let val = val as? Int {
                return "\(formatter.string(from: NSNumber(value: val)) ?? "???" )"
            } else {
                return "\(val)"
            }
        } else {
            return ""
        }
    }

    var tokenType: String {
        if let val = currentValue {
            "\(val.oscValueToken)"
        } else {
            ""
        }
    }

    var id: String { address }

    func getFloatBuffer() -> [Float] {
        timedValueBuffer.compactMap { $0 as? Float }
    }
}

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

// MARK: - OSCChannelTableView
struct OSCChannelTableView: View {
    @State var server: OSCObserver
    @Binding var selectedChannels: Set<String>

    var body: some View {
        // FIXME: values not updating anymore
        Table(server.openChannels, selection: $selectedChannels) {
            TableColumn("Address", value: \.address)
            TableColumn("Type", value: \.tokenType)
        }
    }
}

// MARK: - OSCCHannelDetailView
struct OSCCHannelDetailView: View {
    var channel: OSCChannel

    var body: some View {
        VStack {
            Text(channel.address)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(channel.lastTime?.description ?? "???")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(channel.tokenType)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if channel.tokenType == "float32" {
                let vals = channel.getFloatBuffer()

                Chart(0 ..< vals.count, id: \.self) { nr in
                    LineMark(x: .value("X values", nr),
                             y: .value("Y values", vals[nr]))
                }
                .chartXScale(domain: 0 ... 100)
            }
            
            Text(channel.lastValue)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.1)))
        .padding(10)
    }
}

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

// MARK: - DynamicGridView
struct DynamicChanelDetailGridView: View {
    @State var server: OSCObserver
    @Binding var selectedChannels: Set<String>

    var body: some View {
        let channelArray = Array(selectedChannels)

        if channelArray.isEmpty {
            Text("Select a channel")
        } else {
            GeometryReader { geometry in
                let columns = calculateColumns(for: geometry.size.width)
                let gridItems = Array(repeating: GridItem(.flexible()), count: columns)

                ScrollView {
                    LazyVGrid(columns: gridItems, spacing: 16) {
                        ForEach(channelArray, id: \.self) { channel in
                            if let channel = server.openChannels
                                .first(where: { $0.address == channel }) {
                                OSCCHannelDetailView(channel: channel)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    func calculateColumns(for width: CGFloat) -> Int {
        let itemWidth: CGFloat = 300 // Desired item width
        let spacing: CGFloat = 0 // Spacing between items
        let columns = Int((width + spacing) / (itemWidth + spacing))
        return max(columns, 1) // Ensure at least 1 column
    }
}

#Preview {
    ContentView()
}
