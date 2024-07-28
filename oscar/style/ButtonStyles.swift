//
//  ButtonStyles.swift
//  Oscar
//
//  Created by Fabian S. Klinke on 2024-06-30.
//

import SwiftUI
import trs_system

extension View {
    func ksShadow(scheme: ColorScheme = .light) -> some View {
        self.modifier(KSShadow())
    }
}

let kMinButtonHeight: CGFloat = 20
let kCornerRadius: CGFloat = 4

// MARK: - KSShadow
struct KSShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    var opacity: CGFloat {
        colorScheme == .light ? 0.15 : 0.95
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(opacity), radius: 1, x: 1, y: 1)
            .shadow(color: .white.opacity(1 - opacity), radius: 1, x: -1, y: -1)
    }
}

// MARK: - DefaultsButtonStyle
struct DefaultsButtonStyle: ButtonStyle {
    var color: Color = .accent
    
    @EnvironmentObject var colorManager: TRSColorManager

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .frame(minHeight: kMinButtonHeight)
            .background(DynamicTRSColor.secondaryContentBackground.color)
            .foregroundColor(DynamicTRSColor.text.color)
            .cornerRadius(kCornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - KSTextFieldStyle
struct KSTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            .padding(.horizontal, 8)
            .frame(minHeight: kMinButtonHeight)
            .background(DynamicTRSColor.secondaryContentBackground.color)
            .foregroundColor(DynamicTRSColor.text.color)
            .cornerRadius(kCornerRadius)
    }
}
