//
//  ButtonStyles.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-30.
//

import SwiftUI

struct DefaultsButtonStyle: ButtonStyle {
    var color: Color = .accent
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(color)
            .foregroundColor(.primary)
            .cornerRadius(4)
    }
}
