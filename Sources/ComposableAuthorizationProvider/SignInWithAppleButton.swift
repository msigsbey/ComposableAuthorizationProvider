//
//  SignInWithAppleButton.swift
//
//
//  Created by Michael Sigsbey on 7/7/22.
//

import SwiftUI
import AuthenticationServices

#if os(iOS) || os(tvOS)
/// A SwiftUI enabled [ASAuthorizationAppleIDButton](https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidbutton).
public struct SignInWithAppleButton: UIViewRepresentable {
    public let type: ASAuthorizationAppleIDButton.ButtonType
    public var style: ASAuthorizationAppleIDButton.Style

    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .default,
        style: ASAuthorizationAppleIDButton.Style = .white)
    {
        self.type = type
        self.style = style
    }

    public func makeUIView(
        context: Context) -> some UIView
    {
            return ASAuthorizationAppleIDButton(
                type: type,
                style: style
            )
    }

    public func updateUIView(
        _ uiView: UIViewType,
        context: Context)
    {
        // NOOP
    }
}
#endif
