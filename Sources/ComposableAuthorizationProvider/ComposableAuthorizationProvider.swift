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
        public static func == (lhs: AuthorizationControllerClient.DelegateEvent, rhs: AuthorizationControllerClient.DelegateEvent) -> Bool {
          switch (lhs, rhs) {
              case (let .register(lhsCredential), let .register(rhsCredential)):
                    return lhsCredential.user == rhsCredential.user
              case (let .signIn(lhsCredential), let .signIn(rhsCredential)):
                    return lhsCredential.user == rhsCredential.user
              default:
                  return lhs == rhs
              }
        }
        case register(any AppleIDCredential)
        case signIn(any AppleIDCredential)
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

public protocol AppleIDCredential: Equatable {
  var identityToken: Data? { get }
  var authorizationCode: Data? { get }
  var state: String? { get }
  var user: String { get }
  var email: String? { get }
  var fullName: PersonNameComponents? { get }
  var realUserStatus: ASUserDetectionStatus { get }
}

extension ASAuthorizationAppleIDCredential: AppleIDCredential {}

protocol Authorization {
  var credential: ASAuthorizationCredential { get }
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
