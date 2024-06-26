//
//  OSCChannelTableView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import SwiftUI

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
