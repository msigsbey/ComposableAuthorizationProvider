import XCTest
import AuthenticationServices
import ComposableArchitecture
import Overture
@testable import ComposableAuthorizationProvider

final class ComposableAuthorizationProviderTests: XCTestCase {

    func testGetCredentialState() async {
        let expectedResult = AuthorizationProvider.State(
            credentialState: .notFound
        )
        let provider: AuthorizationProvider = update(.live) {
            $0.getCredentialState = { string in
                return expectedResult
            }
        }
        do {
            let result = try await provider
                .getCredentialState("")
            XCTAssertEqual(result, expectedResult)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

#if !os(tvOS)
    func testPerformRequestLive() async {
        let provider: AuthorizationProvider = .live
        // No real device in Swift Package testing, so expect unknown failure with live object
        let expectedResult: AuthorizationControllerClient.AuthorizationEvent = .didFailWithError(
            NSError(
                domain: AuthenticationServices.ASAuthorizationError.errorDomain,
                code: AuthenticationServices.ASAuthorizationError.unknown.rawValue
            )
        )
        do {
            let result = try await provider.authorizationController
                .performRequest(.standard)
            XCTAssertEqual(result, expectedResult)
        } catch {
            XCTFail("Failed request: \(error)")
        }
    }
#endif
    func testPerformRequestMock() async {
        let expectedResult: AuthorizationControllerClient.AuthorizationEvent = .signInPassword(
            ASPasswordCredential(
                user: "12345",
                password: "67890"
            ))

        let provider: AuthorizationProvider = update(.live) {
            $0.authorizationController = update(.live) {
                $0.performRequest = { options in
                    return expectedResult
                }
            }
        }

        do {
            let result = try await provider.authorizationController
                .performRequest(.standard)
            XCTAssertEqual(result, expectedResult)
            if case let .signInPassword(credential) = result {
                XCTAssert(credential.user == "12345")
                XCTAssert(credential.password == "67890")
            }
        } catch {
            XCTFail("Failed request: \(error)")
        }
    }

#if os(tvOS)
    func testCustomMethod() async {
        for type: ASAuthorizationCustomMethod in [.other, .videoSubscriberAccount, .restorePurchase] {
            let expectedResult: AuthorizationControllerClient.AuthorizationEvent = .didComplete(type)
            let provider: AuthorizationProvider = update(.live) {
                $0.authorizationController = update(.live) {
                    $0.performCustomAuthorization = { options in
                        return expectedResult
                    }
                }
            }

            do {
                let result = try await provider.authorizationController
                    .performCustomAuthorization([.other])
                XCTAssertEqual(result, expectedResult)
            } catch {
                XCTFail("Failed request: \(error)")
            }
        }
    }
#endif
}
