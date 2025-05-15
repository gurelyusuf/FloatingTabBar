/// Created by Yusuf Gürel

import SwiftUI
import UIKit

// MARK: Tab Protocol For Enum Cases
@available(iOS 17.0, *)
public protocol FloatingTabProtocol {
    var symbolImage: String { get }
}

// MARK: Tab Bar Config
@available(iOS 17.0, *)
public struct FloatingTabConfig {
    public var activeTint: SwiftUI.Color = .white
    public var activeBackgroundTint: SwiftUI.Color = .accentColor
    public var inactiveTint: SwiftUI.Color = .gray
    public var tabAnimation: SwiftUI.Animation = .easeInOut(duration: 0.35)
    public var backgroundColor: SwiftUI.Color = .gray.opacity(0.1)
    public var insetAmount: CGFloat = 6
    public var isTranslucent: Bool = false
    public var hPadding: CGFloat = 20
    public var bPadding: CGFloat = 30
    /// Shadows
    public var shadowRadius: CGFloat = 4
    
    // Create Button Config
    public var createButtonSize: CGFloat = 65
    public var createButtonColor: SwiftUI.Color = .accentColor
    public var createButtonSymbol: String = "plus"
    public var createButtonTint: SwiftUI.Color = .white
    
    public init() {}
}

// MARK: Helps to Hide Tab anywhere inside "FloatingTabView" context
@available(iOS 17.0, *)
fileprivate class FloatingTabViewHelper: ObservableObject {
    @Published var hideTabBar: Bool = false
    @Published var tabPopTriggers: [AnyHashable: UUID] = [:]
}

@available(iOS 17.0, *)
fileprivate struct HideFloatingTabBarModifier: ViewModifier {
    var status: Bool
    @EnvironmentObject private var helper: FloatingTabViewHelper
    func body(content: Content) -> some View {
        content
            .onAppear {
                helper.hideTabBar = status
            }
            .onChange(of: status) { _, newValue in
                helper.hideTabBar = newValue
            }
    }
}

@available(iOS 17.0, *)
public extension View {
    func hideFloatingTabBar(_ status: Bool) -> some View {
        self
            .modifier(HideFloatingTabBarModifier(status: status))
    }
}

// MARK: Tab Bar Container
@available(iOS 17.0, *)
public struct FloatingTabView<Content: View, Value: CaseIterable & Hashable & FloatingTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    var config: FloatingTabConfig
    @Binding var selection: Value
    var content: (Value, CGFloat) -> Content
    var onCreateTapped: () -> Void
    
    public init(_ config: FloatingTabConfig = .init(),
         selection: Binding<Value>,
         onCreateTapped: @escaping () -> Void,
         @ViewBuilder content: @escaping (Value, CGFloat) -> Content) {
        self.config = config
        self._selection = selection
        self.onCreateTapped = onCreateTapped
        self.content = content
    }
    
    @State private var tabBarSize: CGSize = .zero
    @StateObject private var helper: FloatingTabViewHelper = .init()
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Wrap each tab content in NavigationStack with pop to root capability
            TabView(selection: $selection) {
                ForEach(Array(Value.allCases), id: \.hashValue) { tab in
                    TabContentView(helper: helper, tab: tab) {
                        content(tab, tabBarSize.height)
                    }
                    .tag(tab)
                    .toolbar(.hidden, for: .tabBar)
                }
            }
            
            FloatingTabBar(config: config, activeTab: $selection, helper: helper, onCreateTapped: onCreateTapped)
                .padding(.horizontal, config.hPadding)
                .padding(.bottom, config.bPadding)
                .background(
                    GeometryReader { proxy in
                        SwiftUI.Color.clear
                            .onAppear {
                                tabBarSize = proxy.size
                            }
                            .onChange(of: proxy.size) { _, newSize in
                                tabBarSize = newSize
                            }
                    }
                )
                .offset(y: helper.hideTabBar ? (tabBarSize.height + 100) : 0)
                .animation(config.tabAnimation, value: helper.hideTabBar)
        }
        .environmentObject(helper)
    }
}

// Tab content wrapper that handles pop to root
@available(iOS 17.0, *)
fileprivate struct TabContentView<Content: View, Tab: Hashable>: View {
    @ObservedObject var helper: FloatingTabViewHelper
    let tab: Tab
    @ViewBuilder let content: () -> Content
    
    @State private var navPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navPath) {
            content()
        }
        .onChange(of: helper.tabPopTriggers[tab]) { _, _ in
            // When this tab's trigger UUID changes, reset the navigation path
            withAnimation {
                navPath = NavigationPath()
            }
        }
    }
}

// MARK: Tab Bar
@available(iOS 17.0, *)
fileprivate struct FloatingTabBar<Value: CaseIterable & Hashable & FloatingTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    
    var config: FloatingTabConfig
    @Binding var activeTab: Value
    @ObservedObject var helper: FloatingTabViewHelper
    var onCreateTapped: () -> Void
    
    /// For Tab Sliding Effect
    @Namespace private var animation
    /// For Tab states
    @State private var toggleStates: [Bool] = []
    @State private var hapticsTrigger: Bool = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Split tabs into two groups
                let allTabs = Array(Value.allCases)
                let halfCount = allTabs.count / 2
                let leftTabs = Array(allTabs.prefix(halfCount))
                let rightTabs = Array(allTabs.suffix(allTabs.count - halfCount))
                
                // Left tabs
                HStack(spacing: 0) {
                    ForEach(leftTabs, id: \.hashValue) { tab in
                        createTabButton(for: tab)
                    }
                }
                
                // Create button placeholder
                Spacer()
                    .frame(width: config.createButtonSize + 20)
                
                // Right tabs
                HStack(spacing: 0) {
                    ForEach(rightTabs, id: \.hashValue) { tab in
                        createTabButton(for: tab)
                    }
                }
            }
            .padding(.horizontal, config.insetAmount)
            .frame(height: 60)
            .background {
                ZStack {
                    if config.isTranslucent {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    } else {
                        Rectangle()
                            .fill(SwiftUI.Color(.systemBackground))
                    }
                    
                    Rectangle()
                        .fill(config.backgroundColor)
                }
            }
            .clipShape(Capsule())
            
            // Create button
            Button(action: {
                hapticsTrigger.toggle()
                onCreateTapped()
            }) {
                Image(systemName: config.createButtonSymbol)
                    .font(.title.bold())
                    .foregroundColor(config.createButtonTint)
                    .frame(width: config.createButtonSize, height: config.createButtonSize)
                    .background(
                        Circle()
                            .fill(config.createButtonColor)
                            .shadow(radius: 5)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .animation(config.tabAnimation, value: activeTab)
        .onAppear {
            // Initialize toggle states array with correct count
            toggleStates = Array(repeating: false, count: Value.allCases.count)
        }
    }
    
    @ViewBuilder
    private func createTabButton(for tab: Value) -> some View {
        let isActive = activeTab == tab
        let index = (Value.allCases.firstIndex(of: tab) as? Int) ?? 0
        
        Image(systemName: tab.symbolImage)
            .font(.title2)
            .foregroundColor(isActive ? config.activeTint : config.inactiveTint)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background {
                if isActive {
                    Capsule()
                        .fill(config.activeBackgroundTint)
                        .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                }
            }
            .onTapGesture {
                // If tab is already active, trigger pop to root
                if activeTab == tab {
                    // Update the trigger for this specific tab
                    helper.tabPopTriggers[tab] = UUID()
                    
                    // Haptic feedback for pop to root
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                    
                    print("Pop to root triggered for tab: \(tab)")
                } else {
                    // Normal tab switching
                    activeTab = tab
                    
                    // Only toggle if within array bounds
                    if index < toggleStates.count {
                        toggleStates[index].toggle()
                    }
                    
                    hapticsTrigger.toggle()
                    
                    // Standard haptic feedback for tab change
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
            .padding(.vertical, config.insetAmount)
    }
}

// Simplified Size Reader without PreferenceKey issues
@available(iOS 17.0, *)
struct SizeReaderView: View {
    @State private var size: CGSize = .zero
    var onChange: (CGSize) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            SwiftUI.Color.clear
                .onAppear {
                    size = geometry.size
                    onChange(size)
                }
                .onChange(of: geometry.size) { _, newSize in
                    size = newSize
                    onChange(newSize)
                }
        }
    }
}

// Extension for size reading
@available(iOS 17.0, *)
public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            SizeReaderView(onChange: onChange)
        )
    }
}
