//
//  ExampleUsage.swift
//  FloatingTabBar
//
//  Created by Yusuf Gürel on 16.05.2025.
//

import SwiftUI

/// Example enum showing how to implement FloatingTabProtocol
public enum ExampleTab: String, CaseIterable, FloatingTabProtocol {
    case home = "Home"
    case search = "Search"
    case favorites = "Favorites"
    case settings = "Settings"
    
    public var symbolImage: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .favorites: return "heart.fill"
        case .settings: return "gear"
        }
    }
}

/// Example view showing how to use FloatingTabView
public struct ExampleTabBarView: View {
    @State private var activeTab: ExampleTab = .home
    @State private var showCreateSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        FloatingTabView(configureTabBar(), selection: $activeTab, onCreateTapped: {
            showCreateSheet = true
        }) { tab, _ in
            switch tab {
            case .home:
                Text("Home View")
                    .font(.largeTitle)
            case .search:
                Text("Search View")
                    .font(.largeTitle)
            case .favorites:
                Text("Favorites View")
                    .font(.largeTitle)
            case .settings:
                Text("Settings View")
                    .font(.largeTitle)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showCreateSheet) {
            ExampleCreateView(isPresented: $showCreateSheet)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func configureTabBar() -> FloatingTabConfig {
        var config = FloatingTabConfig()
        config.activeTint = .white
        config.activeBackgroundTint = .blue
        config.inactiveTint = .gray
        config.backgroundColor = Color(.systemGray6)
        config.isTranslucent = true
        config.createButtonColor = .blue
        config.createButtonSymbol = "plus"
        return config
    }
}

struct ExampleCreateView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Create View")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
