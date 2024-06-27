//
//  OSCChannelTableView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import SwiftUI

// MARK: - OSCChannelTableView
struct OSCChannelTableView: View {
    let server: OSCObserver
    @Binding var selectedChannels: Set<String>

    var body: some View {
        Text("Listening to \(server.portString)")
            .font(.title)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

        List(server.openChannels, selection: $selectedChannels) { channel in
            HStack {
                Text(channel.address)
                Spacer()
                Text(channel.tokenType)
            }
            .frame(maxWidth: .infinity)
        }
        .monospaced()
        .scrollContentBackground(.hidden)
        .onAppear {
            print(server.port)
        }
    }
}
