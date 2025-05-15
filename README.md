# FloatingTabBar

A customizable floating tab bar package for SwiftUI apps.

![Screenshot 1](./Assets/1.png)

## Features

- Customizable floating tab bar with center action button
- Tab animation effects with haptic feedback
- Split tab layout
- Support for translucent backgrounds
- Hide/show tab bar functionality
- iOS 17.0+ support

## Installation

### Swift Package Manager

Add this package to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/gurelyusuf/FloatingTabBar.git", from: "1.0.0")
]
```

## Basic Usage

1. Create an enum that conforms to `FloatingTabProtocol`:

```swift
import FloatingTabBar

enum AppTab: String, CaseIterable, FloatingTabProtocol {
    case dashboard = "Dashboard"
    case transactions = "Transactions"
    case analysis = "Analysis"
    case profile = "Profile"
    
    var symbolImage: String {
        switch self {
        case .dashboard: return "rectangle.grid.2x2.fill"
        case .transactions: return "arrow.up.arrow.down"
        case .analysis: return "chart.pie.fill"
        case .profile: return "person.fill"
        }
    }
}
```

2. Create your tab view:

```swift
import SwiftUI
import FloatingTabBar

struct ContentView: View {
    @State private var activeTab: AppTab = .dashboard
    @State private var showCreateSheet: Bool = false
    
    var body: some View {
        FloatingTabView(selection: $activeTab, onCreateTapped: {
            showCreateSheet = true
        }) { tab, bottomInset in
            switch tab {
            case .dashboard:
                Text("Dashboard View")
            case .transactions:
                Text("Transactions View")
            case .analysis:
                Text("Analysis View")
            case .profile:
                Text("Profile View")
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showCreateSheet) {
            Text("Create View")
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
```

## Customization

You can customize the tab bar appearance using `FloatingTabConfig`:

```swift
private func configureTabBar() -> FloatingTabConfig {
    var config = FloatingTabConfig()
    config.activeTint = .white
    config.activeBackgroundTint = .accentColor
    config.inactiveTint = .gray
    config.backgroundColor = Color(.systemGray6)
    config.isTranslucent = true
    config.createButtonColor = .accentColor
    config.createButtonSymbol = "plus"
    // Add more customizations as needed
    return config
}

// Then use in your FloatingTabView
FloatingTabView(configureTabBar(), selection: $activeTab, onCreateTapped: { ... }) { ... }
```

## Available Customization Options

The `FloatingTabConfig` struct provides the following customization options:

- `activeTint`: The color of the active tab icon
- `activeBackgroundTint`: The background color of the active tab
- `inactiveTint`: The color of inactive tab icons
- `tabAnimation`: The animation used for tab transitions
- `backgroundColor`: The background color of the tab bar
- `insetAmount`: The inset amount for the tab items
- `isTranslucent`: Whether the tab bar has a translucent effect
- `hPadding`: Horizontal padding for the tab bar
- `bPadding`: Bottom padding for the tab bar
- `shadowRadius`: Shadow radius for the tab bar
- `createButtonSize`: Size of the center create button
- `createButtonColor`: Color of the center create button
- `createButtonSymbol`: SF Symbol name for the create button
- `createButtonTint`: Tint color for the create button symbol

## Hide/Show Tab Bar

You can hide or show the tab bar using the `hideFloatingTabBar` modifier:

```swift
Text("Some content")
    .hideFloatingTabBar(true) // Hides the tab bar
```

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
