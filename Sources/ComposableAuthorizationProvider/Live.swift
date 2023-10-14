//
//  Live.swift
//
//
//  Created by Michael Sigsbey on 7/7/22.
//

import Foundation
import AuthenticationServices
import ComposableArchitecture

extension AuthorizationProvider {
    public static var live: Self {
        return Self(
            authorizationController: .live,
            getCredentialState: { userId in
                try await withCheckedThrowingContinuation { continuation in
                    ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { credentialState, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: State(credentialState: credentialState))
                    }
                }
            }
        )
    }
}

#if os(tvOS)
extension AuthorizationControllerClient {
    public static let live = Self(
        performRequest: { options in
            let stream = AsyncThrowingStream<AuthorizationEvent, Error> { continuation in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedOperation = options.operation
                request.requestedScopes = options.scopes
                let delegate = Observer(continuation: continuation)
                controller?.delegate = delegate
                controller?.performRequests()
                continuation.onTermination = { [request = UncheckedSendable(request)] _ in
                    controller = nil
                    _ = delegate
                }
            }
            guard let response = try await stream.first(where: { _ in true })
            else { throw CancellationError() }
            return response
        },
        performExistingAccountSetup: {
            let stream = AsyncThrowingStream<AuthorizationEvent, Error> { continuation in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = Observer(continuation: continuation)
                controller?.delegate = delegate
                controller?.performRequests()
                continuation.onTermination = { [request = UncheckedSendable(request)] _ in
                    controller = nil
                    _ = delegate
                }
            }
            guard let response = try await stream.first(where: { _ in true })
            else { throw CancellationError() }
            return response
        },
        updatePresentationContext: { window in
            let provider = PresentationContextProvider(window: window)
            controller?.presentationContextProvider = provider
        },
        performCustomAuthorization: { methods in
            let stream = AsyncThrowingStream<AuthorizationEvent, Error> { continuation in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                controller = ASAuthorizationController(authorizationRequests: [request])
                controller?.customAuthorizationMethods = methods
                let delegate = Observer(continuation: continuation)
                controller?.delegate = delegate
                controller?.performRequests()
                continuation.onTermination = { [request = UncheckedSendable(request)] _ in
                    controller = nil
                    _ = delegate
                }
            }
            guard let response = try await stream.first(where: { _ in true })
            else { throw CancellationError() }
            return response
        }
    )

    private static var controller: ASAuthorizationController?
}
#elseif os(iOS)
extension AuthorizationControllerClient {
    public static let live = Self(
        performRequest: { options in
            let stream = AsyncThrowingStream<AuthorizationEvent, Error> { continuation in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedOperation = options.operation
                request.requestedScopes = options.scopes
                controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = Observer(continuation: continuation)
                controller?.delegate = delegate
                controller?.performRequests()
                continuation.onTermination = { [request = UncheckedSendable(request)] _ in
                    controller = nil
                    _ = delegate
                }
            }
            guard let response = try await stream.first(where: { _ in true })
            else { throw CancellationError() }
            return response
        },
        performExistingAccountSetup: {
            let stream = AsyncThrowingStream<AuthorizationEvent, Error> { continuation in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = Observer(continuation: continuation)
                controller?.delegate = delegate
                controller?.performRequests()

                continuation.onTermination = { [request = UncheckedSendable(request)] _ in
                    controller = nil
                    _ = delegate
                }
            }
            guard let response = try await stream.first(where: { _ in true })
            else { throw CancellationError() }
            return response
        },
        updatePresentationContext: { window in
            let provider = PresentationContextProvider(window: window)
            controller?.presentationContextProvider = provider
        }
    )

    private static var controller: ASAuthorizationController?
}
#else
extension AuthorizationControllerClient {
    public static let live = Self(
        performRequest: { options in
            let stream = AsyncThrowingStream<AuthorizationEvent, Error> { continuation in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedOperation = options.operation
                request.requestedScopes = options.scopes
                controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = Observer(continuation: continuation)
                controller?.delegate = delegate
                controller?.performRequests()
                continuation.onTermination = { [request = UncheckedSendable(request)] _ in
                    controller = nil
                    _ = delegate
                }
            }
            guard let response = try await stream.first(where: { _ in true })
            else { throw CancellationError() }
            return response
        },
        performExistingAccountSetup: {
            let stream = AsyncThrowingStream<AuthorizationEvent, Error> { continuation in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                controller = ASAuthorizationController(authorizationRequests: [request])
                let delegate = Observer(continuation: continuation)
                controller?.delegate = delegate
                controller?.performRequests()
                continuation.onTermination = { [request = UncheckedSendable(request)] _ in
                    controller = nil
                    _ = delegate
                }
            }
            guard let response = try await stream.first(where: { _ in true })
            else { throw CancellationError() }
            return response
        }
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
    private class Observer: NSObject, ASAuthorizationControllerDelegate {
        let continuation: AsyncThrowingStream<AuthorizationEvent, Error>.Continuation

        init(continuation: AsyncThrowingStream<AuthorizationEvent, Error>.Continuation) {
            self.continuation = continuation
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithAuthorization authorization: ASAuthorization)
        {
            switch authorization.credential {
            case let appleIdCredential as ASAuthorizationAppleIDCredential:
                if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                    self.continuation.yield(.register(appleIdCredential))
                } else {
                    self.continuation.yield(.signIn(appleIdCredential))
                }
                break
            case let passwordCredential as ASPasswordCredential:
                self.continuation.yield(.signInPassword(passwordCredential))
                break
            default:
                break

            }
            self.continuation.finish()
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithError error: Error
        ) {
            self.continuation.yield(.didFailWithError(error as NSError))
            self.continuation.finish()
        }

#if os(tvOS)
        func authorizationController(
            _ controller: ASAuthorizationController,
            didCompleteWithCustomMethod method: ASAuthorizationCustomMethod
        ) {
            self.continuation.yield(.didComplete(method))
            self.continuation.finish()
        }
#endif
    }
}
