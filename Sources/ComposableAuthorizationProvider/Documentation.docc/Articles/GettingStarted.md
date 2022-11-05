# GettingStarted

``ComposableAuthorizationProvider`` gives you access to a new provider called ``AuthorizationProvider``. This new type will help you integrate Sign in with Apple into your composable project.

## Overview

Follow the steps below to set up your own ``AuthorizationProvider`` and utilize Sign in with Apple today.

### Step 1 - Add to feature reducer
```swift
public struct Feature: ReducerProtocol {
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
public enum Action: Equatable {
    /// Triggers existing credential check
    case someAction
    /// Triggers sign in flow
    case someSignInAction
    /// Handles ``AuthorizationProvider`` responses
    case authorizationProvider(AuthorizationControllerClient.DelegateEvent)
}
```

### Step 3 - Add logic to reducer
```swift
public var body: Reduce<State, Action> {
    Reduce { state, action in
        switch action {
        case .someAction:
            // Get the existing credential for the user if any exists
            return authorizationProvider.getCredentialState("someUserId").eraseToEffect().map { state in
                // TODO: Decide when you want to perform credential challenges
                
                // Make a credential challenge
                authorizationProvider.authorizationController.performRequest(.standard).map(SomeAction.authorizationProvider)
            }
        case .someSignInAction:
            // Make a credential challenge
            return authorizationProvider.authorizationController.performRequest(.standard).map(SomeAction.authorizationProvider)
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

### (Optional) Step 5 - Utilize built in dependency

```swift
public struct Feature: ReducerProtocol {
    @Dependency(\.authorizationProvider) var authorizationProvider

    public init() {}
}
```
