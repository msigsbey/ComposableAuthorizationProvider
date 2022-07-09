//
//  ComposableAuthorizationProvider.swift
//
//
//  Created by Michael Sigsbey on 7/3/22.
//

import AuthenticationServices
import ComposableArchitecture

public struct AuthorizationControllerClient {
    public var performRequest: (ASAuthorization.OpenIDOperation, [ASAuthorization.Scope]) -> Effect<DelegateEvent, Never>
    public var performExistingAccountSetup: Effect<DelegateEvent, Never>
    public var performCustomAuthorization: ([ASAuthorizationCustomMethod]) -> Effect<DelegateEvent, Never>
    public var updatePresentationContext: (UIWindowScene) -> Effect<Never, Never>

    public enum DelegateEvent: Equatable {
        case register(ASAuthorizationAppleIDCredential)
        case signIn(ASAuthorizationAppleIDCredential)
        case signInPassword(ASPasswordCredential)
        case didComplete(ASAuthorizationCustomMethod)
        case didFailWithError(NSError)
    }

    public enum Default {
        static let operation: ASAuthorization.OpenIDOperation = .operationImplicit
        static let scopes: [ASAuthorization.Scope] = [.fullName, .email]
    }
}

public struct AuthorizationProvider {
    public var authorizationController: AuthorizationControllerClient
    public var getCredentialState: (String) -> Effect<State, Error>

    public struct State {
        public var credentialState: ASAuthorizationAppleIDProvider.CredentialState

        init(
            credentialState: ASAuthorizationAppleIDProvider.CredentialState
        ) {
            self.credentialState = credentialState
        }
    }
}
