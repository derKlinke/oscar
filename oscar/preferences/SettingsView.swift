//
//  SettingsView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import Defaults
import Sparkle
import SwiftUI

// MARK: - SettingsView
struct SettingsView: View {
    let updater: SPUUpdater

    @State private var autoUpdate = false
    @Default(.sampleFreq) private var sampleFreq
    @Default(.maxSamples) private var maxSamples
    @Default(.defaultPort) private var defaultPort

    init(updater: SPUUpdater) {
        self.updater = updater
        _autoUpdate = State(initialValue: updater.automaticallyChecksForUpdates)
    }

    var body: some View {
        // saprkle auto-updater settings
        TabView {
            VStack {
                HStack {
                    Text("Default Port: ")
                    TextField("Default Port", value: $defaultPort, formatter: NumberFormatter())
                }
                Spacer()
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gear")
            }

            VStack {
                HStack {
                    Text("Sampling Frequency: ")
                        .frame(width: 150, alignment: .trailing)
                    TextField("Sample Frequency", value: $sampleFreq, formatter: NumberFormatter())
                }
                HStack {
                    Text("Max Samples: ")
                        .frame(width: 150, alignment: .trailing)
                    TextField("Max Samples", value: $maxSamples, formatter: NumberFormatter())
                }
                Spacer()
            }
            .padding()
            .tabItem {
                Label("Plots", systemImage: "waveform.path.ecg")
            }

            VStack {
                Toggle("Automatically check for updates", isOn: $autoUpdate)
                    .onChange(of: autoUpdate) { _, _ in
                        updater.automaticallyChecksForUpdates = autoUpdate
                    }

                Spacer()
            }
            .padding()
            .tabItem {
                Label("Updates", systemImage: "arrow.triangle.2.circlepath")
            }
        }.frame(minWidth: 600, minHeight: 300)
    }
}
