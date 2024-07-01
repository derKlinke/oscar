//
//  DebugConsoleView.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-30.
//

import SwiftUI

// MARK: - DebugConsoleView
struct DebugConsoleView: View {
    @Binding var logger: OSCDebugLogger
    
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
                            Color.error.opacity(0.1)
                        } else if log.level == .warning {
                            Color.warning.opacity(0.1)
                        }
                        
                        Text("\(formatter.string(from: log.date)): \(log.message)")
                            .font(.body)
                            .bold(log.level == .error)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 5)
                    }
                }
            }
        }
    }
}
