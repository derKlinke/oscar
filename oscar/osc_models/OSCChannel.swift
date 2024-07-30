//
//  OSCChannel.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import Defaults
import OSCKit
import SwiftUI
import Combine

// MARK: - OSCChannel

// TODO: abstract OSCChannel to protocol and create one class for each type of OSC Data such as Float, int32 and string

@Observable
class OSCChannel: Identifiable {
    let address: String

    var currentValue: (any OSCValue)?
    var lastTime: Date?
    var numMessages = 0

    var timedValueBuffer: [Float] = []
    var currentFloatValue: Float?
    
    var stringBuffer: [String] = []

    var logger: OSCDebugLogger?

    private var timer: Timer?
    private let qeueu = DispatchQueue(label: "OSCChannelQueue", qos: .userInteractive)
    private var startTime: Date?
    private var interval: TimeInterval
    private var observers = [AnyCancellable]()
    private var isSamplingFloat = false

    init(address: String) {
        self.address = address
        self.interval = 1 / Defaults[.sampleFreq]
        
        // TODO: setup ro use nils and not zeros and handle in drawing code to skip them
        // fill timed value buffer with zeros
        for _ in 0..<Defaults[.maxSamples] {
            self.timedValueBuffer.append(0.0)
        }
        
        // subscribe to changes in sample frequency
        Defaults.publisher(.sampleFreq)
            .sink { change in
                self.handleSamplingChange(newRate: change.newValue)
            }
            .store(in: &observers)
    }
    
    func handleSamplingChange(newRate: Double) {
        self.interval = 1 / newRate
        
        self.timer?.invalidate()
        self.timer = Timer
            .scheduledTimer(withTimeInterval: self.interval, repeats: true) { timer in
                self.startTime = Date()
                self.qeueu.async {
                    self.sampleValue()
                }
            }
        self.timer?.tolerance = 0
        RunLoop.current.add(self.timer!, forMode: .common)
        isSamplingFloat = true
    }
    
    // TODO: also record time again and use it in metal view for rendering
    // TODO: keep recoridn geven when app goes into background for prolonged time
    func sampleValue() {
        self.timedValueBuffer.append(currentFloatValue ?? 0.0)

        if self.timedValueBuffer.count > Defaults[.maxSamples] {
            self.timedValueBuffer.removeFirst()
        }
        
        if let startTime = self.startTime {
            let timeDiff = Date().timeIntervalSince(startTime)
            if timeDiff > 1 / Defaults[.sampleFreq] {
                self.logger?.log("\(self.address): Processing Deadline not met, took: \(timeDiff)s, but only had \(interval)s",
                                 level: .error)
            }
        }
    }

    func addNewValue(value: any OSCValue) {
        self.currentValue = value
        self.lastTime = Date()

        if let val = value as? Float {
            self.currentFloatValue = val
            if !isSamplingFloat {
                handleSamplingChange(newRate: Defaults[.sampleFreq])
            }
        } else if let val = value as? String {
            self.stringBuffer.append(val)
            
            if self.stringBuffer.count > Defaults[.maxSamples] {
                self.stringBuffer.removeFirst()
            }
        }
        
        self.numMessages += 1
    }

    var lastValue: String {
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
}
