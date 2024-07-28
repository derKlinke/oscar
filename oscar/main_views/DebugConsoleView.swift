//
//  DebugConsoleView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-30.
//

import SwiftUI
import trs_system

// MARK: - DebugConsoleView
struct DebugConsoleView: View {
    @Binding var logger: OSCDebugLogger
    
    @EnvironmentObject var colorManager: TRSColorManager
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss ZZZZ"
        return formatter
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(logger.log, id: \.id) { log in
                    ZStack {
                        if log.level == .error {
                            DynamicTRSColor.error.color
                        } else if log.level == .warning {
                            DynamicTRSColor.warning.color
                        }
                        
                        Text("\(formatter.string(from: log.date)): \(log.message)")
                            .font(trs: .mono)
                            .bold(log.level == .error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 5)
                    }
                }
            }
        }
    }
}
