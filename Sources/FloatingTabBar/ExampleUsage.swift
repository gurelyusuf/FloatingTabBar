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

/// Example view showing how to use FloatingTabView with Pop to Root
public struct ExampleTabBarView: View {
    @State private var activeTab: ExampleTab = .home
    @State private var showCreateSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        FloatingTabView(configureTabBar(), selection: $activeTab, onCreateTapped: {
            showCreateSheet = true
        }) { tab, _ in
            Group {
                switch tab {
                case .home:
                    HomeTabView()
                case .search:
                    SearchTabView()
                case .favorites:
                    FavoritesTabView()
                case .settings:
                    SettingsTabView()
                }
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

// Example Tab Views with Navigation
struct HomeTabView: View {
    var body: some View {
        List {
            NavigationLink("Go to Detail", destination: DetailView(title: "Home Detail"))
            NavigationLink("Go to Another Detail", destination: DetailView(title: "Another Home Detail"))
            NavigationLink("Go to Third Detail", destination: DetailView(title: "Third Home Detail"))
        }
        .navigationTitle("Home")
    }
}

struct SearchTabView: View {
    var body: some View {
        List {
            NavigationLink("Search Result 1", destination: DetailView(title: "Search Result 1"))
            NavigationLink("Search Result 2", destination: DetailView(title: "Search Result 2"))
            NavigationLink("Search Result 3", destination: DetailView(title: "Search Result 3"))
        }
        .navigationTitle("Search")
    }
}

struct FavoritesTabView: View {
    var body: some View {
        List {
            NavigationLink("Favorite Item 1", destination: DetailView(title: "Favorite Item 1"))
            NavigationLink("Favorite Item 2", destination: DetailView(title: "Favorite Item 2"))
            NavigationLink("Favorite Item 3", destination: DetailView(title: "Favorite Item 3"))
        }
        .navigationTitle("Favorites")
    }
}

struct SettingsTabView: View {
    var body: some View {
        List {
            NavigationLink("Account Settings", destination: DetailView(title: "Account Settings"))
            NavigationLink("Appearance", destination: DetailView(title: "Appearance Settings"))
            NavigationLink("Notifications", destination: DetailView(title: "Notification Settings"))
        }
        .navigationTitle("Settings")
    }
}

struct DetailView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.largeTitle)
                .padding()
            
            Text("This is a detail view.")
                .foregroundColor(.secondary)
            
            Text("Tap the tab again to pop to root")
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            NavigationLink("Go Deeper", destination: DetailView(title: "Deeper Detail"))
                .padding()
        }
        .navigationTitle(title)
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
