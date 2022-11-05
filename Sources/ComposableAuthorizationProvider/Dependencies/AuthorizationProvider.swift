import ComposableArchitecture

extension DependencyValues {
    /// The authorization provider that should be used when performing Sign in with Apple authorization.
    public var authorizationProvider: AuthorizationProvider {
        get { self[AuthorizationProviderKey.self] }
        set { self[AuthorizationProviderKey.self] = newValue }
    }

    private enum AuthorizationProviderKey: DependencyKey {
        static let liveValue = AuthorizationProvider.live
    }
}
