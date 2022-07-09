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
        }
    )

    public static let failing = Self(
        performRequest: { operation, scopes in
                .failing("\(Self.self).present is unimplemented")
        }
    )
}
