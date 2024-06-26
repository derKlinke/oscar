//
//  OSCChannel.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import Defaults
import OSCKit
import SwiftUI

// MARK: - OSCChannel
@Observable
class OSCChannel: Identifiable {
    let address: String

    var values = [any OSCValue]()
    var timedValueBuffer = [any OSCValue]()

    var currentValue: (any OSCValue)?
    var lastTime: Date?

    init(address: String) {
        self.address = address
        let interval = Defaults[.sampleFreq]

        // every interval milliseconds we will add the current value to the buffer
        Timer.scheduledTimer(withTimeInterval: interval / 1_000.0, repeats: true) { _ in
            if let val = self.currentValue {
                self.timedValueBuffer.append(val)
            }

            if self.timedValueBuffer.count > Defaults[.maxSamples] {
                self.timedValueBuffer.removeFirst()
            }
        }
    }

    func addNewValue(value: any OSCValue) {
        currentValue = value
        values.append(value)
        lastTime = Date()
    }

    var lastValue: String {
        // TODO: use correct val
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        if let val = currentValue {
            if let val = val as? Float {
                return "\(formatter.string(from: NSNumber(value: val)) ?? "???")"
            } else if let val = val as? Int {
                return "\(formatter.string(from: NSNumber(value: val)) ?? "???")"
            } else {
                return "\(val)"
            }
        } else {
            return ""
        }
    }

    var tokenType: String {
        if let val = currentValue {
            "\(val.oscValueToken)"
        } else {
            ""
        }
    }

    var id: String { address }

    func getFloatBuffer() -> [Float] {
        timedValueBuffer.compactMap { $0 as? Float }
    }
}
