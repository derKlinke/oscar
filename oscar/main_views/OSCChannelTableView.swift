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
    
    var isAllSelected: Bool {
        guard let server = oscServers[selectedPort ?? 0] else { return false }
        if server.openChannels.count > 0 {
            return selectedChannels.count == server.openChannels.count
        } else {
            return false
        }
    }

    var body: some View {
        if let server = oscServers[selectedPort ?? 0] {
            VStack(spacing: 0) {
                HStack {
                    Text("Channels Received on Port \(server.portString)")
                        .font(trs: .headline, alignment: .left)
                    
                    Spacer()
                    
                    // toggle for select all
                    Text(isAllSelected ? "Deselect All" : "Select All")
                        .font(trs: .caption)
                        .onTapGesture {
                            if selectedChannels.count == server.openChannels.count {
                                selectedChannels = []
                            } else {
                                selectedChannels = Set(server.openChannels.map { $0.address })
                            }
                        }
                    
                    Toggle("", isOn: Binding(
                        get: { isAllSelected },
                        set: { isSelected in
                            if isSelected {
                                selectedChannels = Set(server.openChannels.map { $0.address })
                            } else {
                                selectedChannels = []
                            }
                        }
                    ))
                    .toggleStyle(TRSToggleStyle())
                    .padding(.trailing, .tiny)
                }

                TRSList(data: server.openChannels, id: \.address, multipleSelection: $selectedChannels) { channel in
                    HStack {
                        Text(channel.address)
                            .font(trs: .body, padding: true)

                        Spacer()

                        Text(channel.lastValue)
                            .font(trs: .body, padding: true)
                            .help(channel.tokenType)
                        
                        Toggle("", isOn: Binding(
                            get: { selectedChannels.contains(channel.address) },
                            set: { isSelected in
                                if isSelected {
                                    selectedChannels.insert(channel.address)
                                } else {
                                    selectedChannels.remove(channel.address)
                                }
                            }
                        ))
                        .toggleStyle(TRSToggleStyle())
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
