//
//  OSCDetailViews.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import SwiftUI
import Charts

// MARK: - DynamicChanelDetailGridView
struct DynamicChanelDetailGridView: View {
    @Binding var oscServers: [UInt16: OSCObserver]
    @Binding var selectedPort: UInt16?
    @Binding var selectedChannels: Set<String>

    var body: some View {
        if let server = oscServers[selectedPort ?? 0] {
            let channelArray = Array(selectedChannels)
            
            if channelArray.isEmpty {
                Text("Select a channel")
                    .bodyStyle()
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
                        .font(.callout)
                    }
                }
            }
        } else {
            Text("Select a port")
                .bodyStyle()
        }
    }

    func calculateColumns(for width: CGFloat) -> Int {
        let itemWidth: CGFloat = 300 // Desired item width
        let spacing: CGFloat = 0 // Spacing between items
        let columns = Int((width + spacing) / (itemWidth + spacing))
        return max(columns, 1) // Ensure at least 1 column
    }
}

// MARK: - OSCCHannelDetailView
struct OSCCHannelDetailView: View {
    var channel: OSCChannel

    var body: some View {
        VStack {
            Text(channel.address)
                .titleStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(channel.lastTime?.description ?? "???")
                .captionStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(channel.tokenType)
                .captionStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

            if channel.tokenType == "float32" {
                let vals = channel.getFloatBuffer()

                Chart(0 ..< vals.count, id: \.self) { nr in
                    LineMark(x: .value("X values", nr),
                             y: .value("Y values", vals[nr]))
                    .foregroundStyle(.text)
                }
                .chartXScale(domain: 0 ... 100)
            }

            Text(channel.lastValue)
                .subtitleStyle()
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.accent.opacity(0.4)))
        .padding(10)
    }
}
