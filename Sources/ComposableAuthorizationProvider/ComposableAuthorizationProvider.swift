//
//  ComposableAuthorizationProvider.swift
//
//
//  Created by Michael Sigsbey on 7/3/22.
//

import AuthenticationServices
import ComposableArchitecture

public struct AuthorizationControllerClient {
    public var performRequest: (RequestOptions) -> Effect<DelegateEvent, Never>
    public var performExistingAccountSetup: Effect<DelegateEvent, Never>

    #if os(iOS) || os(tvOS)
    public var updatePresentationContext: (UIWindowScene) -> Effect<Never, Never>
    #endif

    #if os(tvOS)
    public var performCustomAuthorization: ([ASAuthorizationCustomMethod]) -> Effect<DelegateEvent, Never>
    #endif

    public enum DelegateEvent: Equatable {
        case register(ASAuthorizationAppleIDCredential)
        case signIn(ASAuthorizationAppleIDCredential)
        case signInPassword(ASPasswordCredential)
        case didFailWithError(NSError)
        #if os(tvOS)
        case didComplete(ASAuthorizationCustomMethod)
        #endif
    }

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

        public static let `default` = Self(
            operation: .operationImplicit,
            scopes: [.fullName, .email]
        )
    }
}

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
