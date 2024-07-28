//  Defaults.swift
//
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-26.
//

import Defaults

extension Defaults.Keys {
    static let sampleFreq = Key<Double>("sample_freq", default: 100)
    static let maxSamples = Key<Int>("max_samples", default: 100)
    static let defaultPort = Key<Int>("default_port", default: 8_000)
    static let isShowingDebugConsole = Key<Bool>("is_showing_debug_console", default: false)
}
