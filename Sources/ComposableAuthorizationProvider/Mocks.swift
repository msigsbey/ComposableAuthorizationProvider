//
//  Mocks.swift
//
//
//  Created by Michael Sigsbey on 7/7/22.
//

import Foundation
import ComposableArchitecture

enum AuthorizationProviderError: Error, CustomStringConvertible {
    case unimplemented(String)

    var description: String {
        switch self {
        case .unimplemented(let string):
            return string + " is unimplemented"
        }
    }
}

extension AuthorizationProvider {
    public static var noop: Self {
        return Self(
            authorizationController: .noop,
            getCredentialState: { userId in
                try await Task.never()
            }
        )
    }

    public static var failing: Self {
        return Self(
            authorizationController: .failing,
            getCredentialState: { userId in
                throw AuthorizationProviderError.unimplemented("\(Self.self).getCredentialState")
            }
        )
    }
}

#if os(tvOS)
extension AuthorizationControllerClient {
    public static let noop = Self(
        performRequest: { options in
            try await Task.never()
        },
        performExistingAccountSetup: {
            try await Task.never()
        },
        updatePresentationContext: { window in
            try? await Task.never()
        },
        performCustomAuthorization: { methods in
            try await Task.never()
        }
    )

    public static let failing = Self(
        performRequest: { options in
            unimplemented("\(Self.self).performRequest")
        },
        performExistingAccountSetup: unimplemented("\(Self.self).performExistingAccountSetup"),
        updatePresentationContext: { window in
            unimplemented("\(Self.self).updatePresentationContext")
        },
        performCustomAuthorization: { methods in
            unimplemented("\(Self.self).performCustomAuthorization")
        }
    )
}
#elseif os(iOS)
extension AuthorizationControllerClient {
    public static let noop = Self(
        performRequest: { options in
            try await Task.never()
        },
        performExistingAccountSetup: {
            try await Task.never()
        },
        updatePresentationContext: { window in
            try? await Task.never()
        }
    )

    public static let failing = Self(
        performRequest: { options in
            unimplemented("\(Self.self).performRequest")
        },
        performExistingAccountSetup: unimplemented("\(Self.self).performExistingAccountSetup"),
        updatePresentationContext: { window in
            unimplemented("\(Self.self).updatePresentationContext")
        }
    )
}
#else
extension AuthorizationControllerClient {
    public static let noop = Self(
        performRequest: { options in
            try await Task.never()
        },
        performExistingAccountSetup: {
            try await Task.never()
        }
    )

    public static let failing = Self(
        performRequest: { options in
            unimplemented("\(Self.self).performRequest")
        },
        performExistingAccountSetup: unimplemented("\(Self.self).performExistingAccountSetup")

    )
}
#endif
