import XCTest
@testable import ComposableAuthorizationProvider

final class ComposableAuthorizationProviderTests: XCTestCase {

    func testExample() {
        let provider: AuthorizationProvider = .live

        provider.getCredentialState("")

        provider.authorizationController.performRequest(.operationImplicit, [.fullName, .email])
    }
}
