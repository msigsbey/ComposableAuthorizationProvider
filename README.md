# ComposableAuthorizationProvider

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/msigsbey/ComposableAuthorizationProvider)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
![Swift5](https://img.shields.io/badge/Swift-5-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS|macOS|tvOS-blue.svg?style=flat)
![GitHub repo size](https://img.shields.io/github/repo-size/msigsbey/ComposableAuthorizationProvider)

ComposableAuthorizationProvider is a composable component built with the [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) for handling [Sign in with Apple](https://developer.apple.com/sign-in-with-apple/) on iOS, macOS, tvOS.

## Integration

ComposableAuthorizationProvider is available via [Swift Package Manager](https://swift.org/package-manager/)

## Usage

`ComposableAuthorizationProvider` gives you access to a new provider called `AuthorizationProvider`. It can be integrated within your composable app like this: 

### Step 1 - Add to Reducer
```swift
public struct SomeReducer {
    @Dependency(\.authorizationProvider) var authorizationProvider
}
```

### Step 2 - Add to actions
```swift
public enum Action: Equatable {
    /// Triggers existing credential check
    case someAction
    /// Triggers sign in flow
    case someSignInAction
    /// Handles ``AuthorizationProvider`` responses
    case authorizationProvider(AuthorizationControllerClient.AuthorizationEvent)
}
```

### Step 3 - Add logic to reducer
```swift
public var body: some Reducer<State, Action> {
    Reduce { state, action in
        switch action {
        case .someAction:
            return .run { send in 
                // Get current state
                let state = await authorizationProvider.getCredentialState("someUserId")
                
                // TODO: Decide when you want to perform credential challenges
                
                // Make a credential challenge
                let authorization = try? await authorizationProvider.authorizationController.performRequest(.standard)
                return .send(.authorizationProvider(authorization))
            }
        case .someSignInAction:
            return .run { send in
                // Make a credential challenge
                let authorization = try? await authorizationProvider.authorizationController.performRequest(.standard).map(SomeAction.authorizationProvider)
                return .send(.authorizationProvider(authorization))
            }
        }
    },
    ...
)
```

### Step 4 - Add the sign in button to a view
```swift
public var body: some View {
    ZStack{
        Color.accentColor.edgesIgnoringSafeArea(.all)
        VStack {
            Spacer()
            if viewStore.loginButtonVisible {
                SignInWithAppleButton(type: .default, style: .white)
                    .frame(width: UIScreen.main.bounds.width / 2, height: 30)
                    .onTapGesture {
                        // Send the sign in flow action when pressed
                        self.viewStore.send(.someSignInAction)
                    }
            }
        }
    }
}
```

## License

ComposableAuthorizationProvider is available under the MIT license. See the LICENSE file for more info.
