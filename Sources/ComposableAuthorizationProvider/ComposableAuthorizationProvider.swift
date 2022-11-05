//
//  ComposableAuthorizationProvider.swift
//
//
//  Created by Michael Sigsbey on 7/3/22.
//

import AuthenticationServices
import ComposableArchitecture

/// Client for interfacing with [AuthenticationServices](https://developer.apple.com/documentation/authenticationservices).
public struct AuthorizationControllerClient {
    /// Performs an [ASAuthorizationAppleIDRequest](https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidrequest) with the given ``RequestOptions``
    public var performRequest: (RequestOptions) -> Effect<DelegateEvent, Never>
    /// Performs an [ASAuthorizationAppleIDRequest](https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidrequest) for an existing account
    public var performExistingAccountSetup: Effect<DelegateEvent, Never>

    #if os(iOS) || os(tvOS)
    /// Updates the presentation context on iOS and tvOS devices
    public var updatePresentationContext: (UIWindowScene) -> Effect<Never, Never>
    #endif

    #if os(tvOS)
    /// Allows for custom authorization flow on tvOS devices
    public var performCustomAuthorization: ([ASAuthorizationCustomMethod]) -> Effect<DelegateEvent, Never>
    #endif

    /// Events for wrapping the [ASAuthorizationControllerDelegate](https://developer.apple.com/documentation/authenticationservices/asauthorizationcontrollerdelegate)
    public enum DelegateEvent: Equatable {
        case register(ASAuthorizationAppleIDCredential)
        case signIn(ASAuthorizationAppleIDCredential)
        case signInPassword(ASPasswordCredential)
        case didFailWithError(NSError)
        #if os(tvOS)
        case didComplete(ASAuthorizationCustomMethod)
        #endif
    }

    /// The configurable options for the [ASAuthorizationAppleIDRequest](https://developer.apple.com/documentation/authenticationservices/asauthorizationappleidrequest)
    public struct RequestOptions: Equatable {
        public var operation: ASAuthorization.OpenIDOperation
        public var scopes: [ASAuthorization.Scope]

        public init(
            operation: ASAuthorization.OpenIDOperation,
            scopes: [ASAuthorization.Scope]
        ) {
            self.operation = operation
            self.scopes = scopes
        }

        /// The standard options
        public static let standard = Self(
            operation: .operationImplicit,
            scopes: [.fullName, .email]
        )
    }
}

/// This object provides the basic functionality for the [Sign in with Apple](https://developer.apple.com/documentation/authenticationservices/implementing_user_authentication_with_sign_in_with_apple) authorization flow.
public struct AuthorizationProvider {
    public var authorizationController: AuthorizationControllerClient
    public var getCredentialState: (String) -> Effect<State, Error>

    public struct State: Equatable {
        public var credentialState: ASAuthorizationAppleIDProvider.CredentialState

        init(
            credentialState: ASAuthorizationAppleIDProvider.CredentialState
        ) {
            self.credentialState = credentialState
        }
    }
}
