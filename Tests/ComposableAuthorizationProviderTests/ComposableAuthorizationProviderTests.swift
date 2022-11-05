import XCTest
import AuthenticationServices
import Combine
import ComposableArchitecture
import Overture
@testable import ComposableAuthorizationProvider

final class ComposableAuthorizationProviderTests: XCTestCase {

    func testGetCredentialState() {
        let mockSystemCredentialPublisher = PassthroughSubject<AuthorizationProvider.State, Error>()
        let provider: AuthorizationProvider = update(.live) {
            $0.getCredentialState = { string in
                return mockSystemCredentialPublisher.eraseToEffect()
            }
        }
        let expectedResult = AuthorizationProvider.State(
            credentialState: .notFound
        )
        var result: AuthorizationProvider.State?
        let expectation = self.expectation(description: "Finished publishing")
        let cancellable = provider.getCredentialState("")
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                result = value
            })

        mockSystemCredentialPublisher.send(expectedResult)
        mockSystemCredentialPublisher.send(completion: .finished)

        self.waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssert(result == expectedResult)
            cancellable.cancel()
        }
    }

    func testPerformRequestLive() {
        let provider: AuthorizationProvider = .live
        // No real device in Swift Package testing, so expect unknown failure with live object
        let expectedResult: AuthorizationControllerClient.DelegateEvent = .didFailWithError(
            NSError(
                domain: AuthenticationServices.ASAuthorizationError.errorDomain,
                code: AuthenticationServices.ASAuthorizationError.unknown.rawValue
            )
        )
        var result: AuthorizationControllerClient.DelegateEvent?
        let expectation = self.expectation(description: "Finished request")

        let cancellable = provider.authorizationController
            .performRequest(.standard)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure:
                    XCTFail("Failed request")
                case .finished:
                    expectation.fulfill()
                }
            }) { value in
                result = value
            }

        self.waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssert(result == expectedResult)
            cancellable.cancel()
        }
    }

    func testPerformRequestMock() {
        let mockDelegate = PassthroughSubject<AuthorizationControllerClient.DelegateEvent, Never>()
        let provider: AuthorizationProvider = update(.live) {
            $0.authorizationController = update(.live) {
                $0.performRequest = { options in
                    return mockDelegate.eraseToEffect()
                }
            }
        }
        let expectedResult: AuthorizationControllerClient.DelegateEvent = .signInPassword(
            ASPasswordCredential(
                user: "12345",
                password: "67890"
            ))
        var result: AuthorizationControllerClient.DelegateEvent?
        let expectation = self.expectation(description: "Finished request")

        let cancellable = provider.authorizationController
            .performRequest(.standard)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure:
                    XCTFail("Failed request")
                case .finished:
                    expectation.fulfill()
                }
            }) { value in
                result = value
            }

        mockDelegate.send(expectedResult)
        mockDelegate.send(completion: .finished)

        self.waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssert(result == expectedResult)
            if case let .signInPassword(credential) = result {
                XCTAssert(credential.user == "12345")
                XCTAssert(credential.password == "67890")
            }
            cancellable.cancel()
        }
    }

#if os(tvOS)
    func testCustomMethod() {
        for type: ASAuthorizationCustomMethod in [.other, .videoSubscriberAccount, .restorePurchase] {
            let mockDelegate = PassthroughSubject<AuthorizationControllerClient.DelegateEvent, Never>()
            let provider: AuthorizationProvider = update(.live) {
                $0.authorizationController = update(.live) {
                    $0.performCustomAuthorization = { options in
                        return mockDelegate.eraseToEffect()
                    }
                }
            }

            let expectedResult: AuthorizationControllerClient.DelegateEvent = .didComplete(type)
            var event: AuthorizationControllerClient.DelegateEvent?
            let expectation = self.expectation(description: "Finished request")
            let cancellable = provider.authorizationController
                .performCustomAuthorization([.other])
                .sink(receiveCompletion: { result in
                    switch result {
                    case .failure:
                        XCTFail("Failed request")
                    case .finished:
                        expectation.fulfill()
                    }
                }) { value in
                    event = value
                }

            mockDelegate.send(expectedResult)
            mockDelegate.send(completion: .finished)

            self.waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
                XCTAssert(event == expectedResult)
                cancellable.cancel()
            }
        }
    }
#endif
}
