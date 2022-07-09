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
        authorizationController: .live,
        getCredentialState: { userId in
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
    }
}

#if os(tvOS)
extension AuthorizationControllerClient {
  public static let live = Self(
    performRequest: { operation, scopes in
            .run { subscriber in
                let request = ASAuthorizationAppleIDProvider().createRequest()
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
    },
    performExistingAccountSetup: .run { subscriber in
        let request = ASAuthorizationAppleIDProvider().createRequest()
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
    .eraseToEffect(),
    updatePresentationContext: { window in
            .fireAndForget {
                let provider = PresentationContextProvider(window: window)
                controller?.presentationContextProvider = provider
            }
    },
    performCustomAuthorization: { methods in
            .run { subscriber in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                controller = ASAuthorizationController(authorizationRequests: [request])
                controller?.customAuthorizationMethods = methods
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
    }
  )

    private static var controller: ASAuthorizationController?
}
#elseif os(iOS)
extension AuthorizationControllerClient {
  public static let live = Self(
    performRequest: { operation, scopes in
            .run { subscriber in
                let request = ASAuthorizationAppleIDProvider().createRequest()
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
    },
    performExistingAccountSetup: .run { subscriber in
        let request = ASAuthorizationAppleIDProvider().createRequest()
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
    .eraseToEffect(),
    updatePresentationContext: { window in
            .fireAndForget {
                let provider = PresentationContextProvider(window: window)
                controller?.presentationContextProvider = provider
            }
    }
  )

    private static var controller: ASAuthorizationController?
}
#else
extension AuthorizationControllerClient {
  public static let live = Self(
    performRequest: { operation, scopes in
            .run { subscriber in
                let request = ASAuthorizationAppleIDProvider().createRequest()
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
    },
    performExistingAccountSetup: .run { subscriber in
        let request = ASAuthorizationAppleIDProvider().createRequest()
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
  )

    private static var controller: ASAuthorizationController?
}
#endif
extension AuthorizationControllerClient {
    #if os(iOS) || os(tvOS)
    final class PresentationContextProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
        let window: UIWindowScene

        init(
            window: UIWindowScene
        ) {
            self.window = window
        }

        func presentationAnchor(
            for controller: ASAuthorizationController
        ) -> ASPresentationAnchor {
            return ASPresentationAnchor(windowScene: window)
        }
    }
    #endif
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

        #if os(tvOS)
        func authorizationController(
            _ controller: ASAuthorizationController,
            didCompleteWithCustomMethod method: ASAuthorizationCustomMethod
        ) {
            self.subscriber.send(.didComplete(method))
            self.subscriber.send(completion: .finished)
        }
        #endif
    }
}
