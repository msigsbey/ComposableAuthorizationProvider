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

extension AuthorizationControllerClient {
    public static let noop = Self(
        performRequest: { operation, scopes in
            .none
        },
        performExistingAccountSetup: .none,
        performCustomAuthorization: { methods in
            .none
        },
        updatePresentationContext: { window in
            .none
        }
    )

    public static let failing = Self(
        performRequest: { operation, scopes in
            .failing("\(Self.self).performRequest is unimplemented")
        },
        performExistingAccountSetup: .failing("\(Self.self).performExistingAccountSetup is unimplemented"),
        performCustomAuthorization: { methods in
            .failing("\(Self.self).performCustomAuthorization is unimplemented")
        },
        updatePresentationContext: { window in
            .failing("\(Self.self).updatePresentationContext is unimplemented")
        }
    )
}
