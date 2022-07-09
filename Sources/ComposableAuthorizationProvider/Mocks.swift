//
//  Mocks.swift
//
//
//  Created by Michael Sigsbey on 7/7/22.
//

import Foundation
import ComposableArchitecture

extension AuthorizationProvider {
    public static var noop: Self {
        return Self(
            authorizationController: .noop,
            getCredentialState: { userId in
                    .none
            }
        )
    }

    public static var failing: Self {
        return Self(
            authorizationController: .failing,
            getCredentialState: { userId in
                    .failing("\(Self.self).getCredentialState is unimplemented")
            }
        )
    }
}

#if os(tvOS)
extension AuthorizationControllerClient {
    public static let noop = Self(
        performRequest: { operation, scopes in
            .none
        },
        performExistingAccountSetup: .none,
        updatePresentationContext: { window in
            .none
        },
        performCustomAuthorization: { methods in
            .none
        }
    )

    public static let failing = Self(
        performRequest: { operation, scopes in
            .failing("\(Self.self).performRequest is unimplemented")
        },
        performExistingAccountSetup: .failing("\(Self.self).performExistingAccountSetup is unimplemented"),
        updatePresentationContext: { window in
            .failing("\(Self.self).updatePresentationContext is unimplemented")
        },
        performCustomAuthorization: { methods in
            .failing("\(Self.self).performCustomAuthorization is unimplemented")
        }
    )
}
#elseif os(iOS)
extension AuthorizationControllerClient {
    public static let noop = Self(
        performRequest: { operation, scopes in
            .none
        },
        performExistingAccountSetup: .none,
        updatePresentationContext: { window in
            .none
        }
    )

    public static let failing = Self(
        performRequest: { operation, scopes in
            .failing("\(Self.self).performRequest is unimplemented")
        },
        performExistingAccountSetup: .failing("\(Self.self).performExistingAccountSetup is unimplemented"),
        updatePresentationContext: { window in
            .failing("\(Self.self).updatePresentationContext is unimplemented")
        }
    )
}
#else
extension AuthorizationControllerClient {
    public static let noop = Self(
        performRequest: { operation, scopes in
            .none
        },
        performExistingAccountSetup: .none
    )

    public static let failing = Self(
        performRequest: { operation, scopes in
            .failing("\(Self.self).performRequest is unimplemented")
        },
        performExistingAccountSetup: .failing("\(Self.self).performExistingAccountSetup is unimplemented")
    )
}
#endif
