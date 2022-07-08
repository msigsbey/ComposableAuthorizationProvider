//
//  ComposableAuthorizationProvider.swift
//
//
//  Created by Michael Sigsbey on 7/3/22.
//

import AuthenticationServices
import ComposableArchitecture

public struct AuthorizationControllerClient {
    public var present: (ASAuthorization.OpenIDOperation, [ASAuthorization.Scope]) -> Effect<DelegateEvent, Never>
    public var getCredentialState: (String) -> Effect<State, Error>

    public enum DelegateEvent: Equatable {
        case register(ASAuthorizationAppleIDCredential)
        case signIn(ASAuthorizationAppleIDCredential)
        case signInPassword(ASPasswordCredential)
        case didFailWithError(NSError)
    }

    public enum Default {
        static let operation: ASAuthorization.OpenIDOperation = .operationImplicit
        static let scopes: [ASAuthorization.Scope] = [.fullName, .email]
    }

    public struct State {
        public var credentialState: ASAuthorizationAppleIDProvider.CredentialState

        init(
            credentialState: ASAuthorizationAppleIDProvider.CredentialState
        ) {
            self.credentialState = credentialState
        }
    }
}

public struct AuthorizationProvider {
    public var authorizationController: AuthorizationControllerClient
}
