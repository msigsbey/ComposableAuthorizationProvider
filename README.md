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

`ComposableAuthorizationProvider` gives you access to a new provider called `AuthorizationProvider`. It can be integrated within your composable app like this : 

### Step 1 - Add to Environment
```swift
public struct SomeEnvironment {
    public var authorizationProvider: AuthorizationProvider
    
    public init(
        authorizationProvider: AuthorizationProvider = .live
    ) {
        self.authorizationProvider = authorizationProvider
    }
}
```

### Step 2 - Add to actions
```swift
public enum SomeAction: Equatable {
    case someAction
    case someSignInAction
    case authorizationProvider(AuthorizationControllerClient.DelegateEvent)
}
```

### Step 3 - Add logic to reducer
```swift
public let reducer = Reducer<SomeState, SomeAction, SomeEnvironment>.combine(
    Reducer { state, action, environment in
        switch action {
        case .someAction:
            return environment.authorizationProvider.getCredentialState("someUserId").eraseToEffect().map { state in
                // TODO: Decide when you want to perform credential challenges
                
                // Make a credential challenge
                environment.authorizationProvider.authorizationController.performRequest(.default).map(SomeAction.authorizationProvider)
            }
        case .someSignInAction:
            // Make a credential challenge
            return environment.authorizationProvider.authorizationController.performRequest(.default).map(SomeAction.authorizationProvider)
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
                            self.viewStore.send(.someSignInAction)
                        }
                }
            }
        }
    }

```

## License

ComposableAuthorizationProvider is available under the MIT license. See the LICENSE file for more info.
