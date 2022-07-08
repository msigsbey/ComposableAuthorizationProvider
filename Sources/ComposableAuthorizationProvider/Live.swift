//
//  Live.swift
//
//
//  Created by Michael Sigsbey on 7/7/22.
//

import Foundation
import AuthenticationServices
import ComposableArchitecture
import Combine

extension AuthorizationProvider {
    public static var live: Self {
      return Self(
        authorizationController: .live
      )
    }
}

extension AuthorizationControllerClient {
  public static let live = Self(
    present: { operation, scopes in
            .run { subscriber in
                let provider = ASAuthorizationAppleIDProvider()
                let request = provider.createRequest()
                request.requestedOperation = operation
                request.requestedScopes = scopes
                controller = ASAuthorizationController(authorizationRequests: [request])
                var delegate: Optional = Delegate(subscriber: subscriber)
                controller?.delegate = delegate
                controller?.performRequests()

                return AnyCancellable {
                    delegate = nil
                    controller = nil
                }
            }
            .share()
            .eraseToEffect()
    }, getCredentialState: { userId in
        .future { callback in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { credentialState, error in
                if let error = error {
                    callback(.failure(error))
                }

                callback(.success(State(credentialState: credentialState)))
            }
        }
    }
  )

    private static var controller: ASAuthorizationController?
}

extension AuthorizationControllerClient {
    final class Delegate: NSObject, ASAuthorizationControllerDelegate {
        let subscriber: Effect<DelegateEvent, Never>.Subscriber

        init(subscriber: Effect<DelegateEvent, Never>.Subscriber) {
            self.subscriber = subscriber
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithAuthorization authorization: ASAuthorization
        ){
            switch authorization.credential {
            case let appleIdCredential as ASAuthorizationAppleIDCredential:
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    subscriber.send(.register(appleIdCredential))
                } else {
                    subscriber.send(.signIn(appleIdCredential))
                }
                break
            case let passwordCredential as ASPasswordCredential:
                subscriber.send(.signInPassword(passwordCredential))
                break
            default:
                break

            }
            self.subscriber.send(completion: .finished)
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithError error: Error
        ) {
            self.subscriber.send(.didFailWithError(error as NSError))
            self.subscriber.send(completion: .finished)
        }
    }
}
