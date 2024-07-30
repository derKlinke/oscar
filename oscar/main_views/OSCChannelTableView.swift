//
//  OSCChannelTableView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import SwiftUI
import trs_system

// MARK: - OSCChannelTableView
struct OSCChannelTableView: View {
    @Binding var oscServers: [Int: OSCObserver]
    @Binding var selectedPort: Int?
    @Binding var selectedChannels: Set<String>

    @EnvironmentObject var colorManager: TRSColorManager
    @State private var lastSelectedChannel: String?

    var body: some View {
        if let server = oscServers[selectedPort ?? 0] {
            VStack(spacing: 0) {
                Text("Channels Received on Port \(server.portString)")
                    .font(trs: .headline, alignment: .left)

                TRSList(data: server.openChannels, id: \.address, multipleSelection: $selectedChannels) { channel in
                    HStack {
                        Text(channel.address)
                            .font(trs: .body, padding: true)

                        Spacer()

                        Text(channel.lastValue)
                            .font(trs: .body, padding: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, .medium)
        } else {
            Text("No server selected")
                .font(trs: .body)
        }
    }
}
