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
            authorizationController: .noop
        )
    }

    public static var failing: Self {
        return Self(
            authorizationController: .failing
        )
    }
}

extension AuthorizationControllerClient {
    public static let noop = Self(
        present: { operation, scopes in
                .none
        }, getCredentialState: { userId in
                .none
        }
    )

    public static let failing = Self(
        present: { operation, scopes in
                .failing("\(Self.self).present is unimplemented")
        }, getCredentialState: { userId in
                .failing("\(Self.self).getCredentialState is unimplemented")
        }
    )
}
