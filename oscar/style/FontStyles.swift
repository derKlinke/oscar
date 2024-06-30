//
//  FontStyles.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-30.
//

import SwiftUI

extension Font {
    static var title: Font {
        Font.custom("Fira Code", size: 24)
            .bold()
    }
    
    static var title2: Font {
        Font.custom("Fira Code", size: 22)
            .bold()
    }
    
    static var subtitle: Font {
        Font.custom("Fira Code", size: 18)
    }
    
    static var body: Font {
        Font.custom("Fira Code", size: 13)
    }
    
    static var caption: Font {
        Font.custom("Fira Code", size: 11)
    }
}

extension Text {
    func titleStyle() -> some View {
        self.font(.title)
            .foregroundStyle(.primary)
    }
    
    func title2Style() -> some View {
        self.font(.title2)
            .foregroundStyle(.primary)
    }
    
    func subtitleStyle() -> some View {
        self.font(.subtitle)
            .foregroundStyle(.primary)
    }
    
    func bodyStyle() -> some View {
        self.font(.body)
            .foregroundStyle(.text)
    }
    
    func captionStyle() -> some View {
        self.font(.caption)
            .foregroundStyle(.secondary)
    }
}
