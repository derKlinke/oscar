//
//  OSCDetailViews.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import Charts
import MetalKit
import SwiftUI
import trs_system

// MARK: - DynamicChanelDetailGridView
struct DynamicChanelDetailGridView: View {
    @Binding var oscServers: [Int: OSCObserver]
    @Binding var selectedPort: Int?
    @Binding var selectedChannels: Set<String>

    @EnvironmentObject var colorManager: TRSColorManager

    var body: some View {
        if let server = oscServers[selectedPort ?? 0] {
            let channelArray = Array(selectedChannels)

            if channelArray.isEmpty {
                Text("Select a channel")
                    .font(trs: .body)
            } else {
                GeometryReader { geometry in
                    let columns = calculateColumns(for: geometry.size.width)
                    let gridItems = Array(repeating: GridItem(.flexible()), count: columns)

                    ScrollView {
                        LazyVGrid(columns: gridItems, spacing: 0) {
                            ForEach(channelArray, id: \.self) { channel in
                                if let channel = server.openChannels
                                    .first(where: { $0.address == channel }) {
                                    OSCChannelDetailView(channel: channel)
                                }
                            }
                        }
                        .padding(.medium)
                        .font(.callout)
                    }
                }
            }
        } else {
            Text("Select a port")
                .font(trs: .body)
        }
    }

    func calculateColumns(for width: CGFloat) -> Int {
        let itemWidth: CGFloat = 300 // Desired item width
        let spacing: CGFloat = 0 // Spacing between items
        let columns = Int((width + spacing) / (itemWidth + spacing))
        return max(columns, 1) // Ensure at least 1 column
    }
}

// MARK: - OSCChannelDetailView
struct OSCChannelDetailView: View {
    var channel: OSCChannel

    var body: some View {
        VStack(spacing: 0) {
            Text(channel.address)
                .font(trs: .headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(channel.lastTime?.description ?? "???")
                .font(trs: .caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .tiny)

            Text(channel.tokenType)
                .font(trs: .caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                if channel.tokenType == "float32" {
                    TRSLineGraph(dataPoints: channel.timedValueBuffer)
                        .frame(height: 100)
                } else if channel.tokenType == "string" {
                    ZStack {
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                LazyVStack {
                                    ForEach(channel.stringBuffer.indices,
                                            id: \.self) { index in
                                        Text(channel.stringBuffer[index])
                                            .font(trs: .mono, padding: false,
                                                  alignment: .left)
                                            .id(index)
                                    }
                                }
                            }
                            .onChange(of: channel.stringBuffer) { _, _ in
                                withAnimation {
                                    proxy.scrollTo(channel.stringBuffer.count - 1,
                                                   anchor: .bottom)
                                }
                            }
                        }

                        VStack {
                            LinearGradient(gradient: Gradient(colors: [
                                .clear,
                                DynamicTRSColor.secondaryContentBackground.color,
                            ]),
                            startPoint: .bottom, endPoint: .top)
                                .frame(height: .custom(level: 3))

                            Spacer()
                        }
                    }
                }
            }
            .padding(.top, .medium)
            .frame(height: .custom(level: 5))

            Spacer()

            Text(channel.lastValue)
                .font(trs: .numDisplay)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.medium)
        .background(DynamicTRSColor.secondaryContentBackground.color)
        .roundedClip()
        .padding(.small)
    }
}


