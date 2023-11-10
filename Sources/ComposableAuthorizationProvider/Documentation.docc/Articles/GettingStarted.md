# GettingStarted

``ComposableAuthorizationProvider`` gives you access to a new provider called ``AuthorizationProvider``. This new type will help you integrate Sign in with Apple into your composable project.

## Overview

Follow the steps below to set up your own ``AuthorizationProvider`` and utilize Sign in with Apple today.

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
                
                TODO: Decide when you want to perform credential challenges
                
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

### (Optional) Step 5 - Utilize built in dependency

```swift
public struct Feature: ReducerProtocol {
    @Dependency(\.authorizationProvider) var authorizationProvider

    public init() {}
}
```
