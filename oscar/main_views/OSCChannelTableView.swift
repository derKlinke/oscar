//
//  OSCChannelTableView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import SwiftUI

// MARK: - OSCChannelTableView
struct OSCChannelTableView: View {
    @Binding var oscServers: [UInt16: OSCObserver]
    @Binding var selectedPort: UInt16?
    @Binding var selectedChannels: Set<String>

    var body: some View {
        if let server = oscServers[selectedPort ?? 0] {
            Text("Listening to \(server.portString)")
                .titleStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            List(server.openChannels, selection: $selectedChannels) { channel in
                HStack {
                    Text(channel.address)
                    
                    Spacer()
                    
                    Text(channel.tokenType)
                }
                .font(.body)
                .frame(maxWidth: .infinity)
            }
            .scrollContentBackground(.hidden)
        } else {
            Text("No server selected")
                .bodyStyle()
        }
            
    }
}
