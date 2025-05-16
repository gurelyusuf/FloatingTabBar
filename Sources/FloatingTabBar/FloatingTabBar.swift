/// Created by Yusuf Gürel

import SwiftUI
import UIKit

// MARK: Tab Protocol
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

    public var shadowRadius: CGFloat = 4
    

    public var createButtonSize: CGFloat = 65
    public var createButtonColor: SwiftUI.Color = .accentColor
    public var createButtonSymbol: String = "plus"
    public var createButtonTint: SwiftUI.Color = .white
    

    public var enablePopToRoot: Bool = true
    
    public init() {}
}

// MARK: Hide Tab Bar
@available(iOS 17.0, *)
fileprivate class FloatingTabViewHelper: ObservableObject {
    @Published var hideTabBar: Bool = false
    @Published var navigationStacks: [AnyHashable: NavigationPath] = [:]
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
    @State private var lastTab: Value?
    @StateObject private var helper: FloatingTabViewHelper = .init()
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Using if available for iOS 18 features
            if #available(iOS 18, *) {
                /// New Tab View for iOS 18+
                TabView(selection: tabSelection) {
                    ForEach(Array(Value.allCases), id: \.hashValue) { tab in
                        SwiftUI.Tab(value: tab) {
                            NavigationStackWithPath(tab: tab, content: { path in
                                content(tab, tabBarSize.height)
                            })
                            .toolbar(.hidden, for: .tabBar)
                        }
                    }
                }
            } else {
                /// Tab View for iOS 17
                TabView(selection: tabSelection) {
                    ForEach(Array(Value.allCases), id: \.hashValue) { tab in
                        NavigationStackWithPath(tab: tab, content: { path in
                            content(tab, tabBarSize.height)
                        })
                        .tag(tab)
                        .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            
            FloatingTabBar(config: config, activeTab: tabSelection, onCreateTapped: onCreateTapped)
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
        .onAppear {
            lastTab = selection
        }
    }
    

    @ViewBuilder
    private func NavigationStackWithPath(tab: Value, @ViewBuilder content: @escaping (Binding<NavigationPath>) -> Content) -> some View {

        let pathBinding = Binding<NavigationPath>(
            get: {
                helper.navigationStacks[tab] ?? NavigationPath()
            },
            set: { newValue in
                helper.navigationStacks[tab] = newValue
            }
        )
        
        NavigationStack(path: pathBinding) {
            content(pathBinding)
        }
    }
    
    // Tab with Pop-to-Root Functionality
    private var tabSelection: Binding<Value> {
        Binding(
            get: { selection },
            set: { newTab in
                if config.enablePopToRoot && newTab == selection && newTab == lastTab {
                    // Same tab tapped again - Pop to root
                    helper.navigationStacks[newTab] = NavigationPath()
                }
                
                // Store last selected tab
                lastTab = newTab
                selection = newTab
            }
        )
    }
}

// MARK: Tab Bar
@available(iOS 17.0, *)
fileprivate struct FloatingTabBar<Value: CaseIterable & Hashable & FloatingTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    
    var config: FloatingTabConfig
    @Binding var activeTab: Value
    var onCreateTapped: () -> Void
    

    @Namespace private var animation

    @State private var toggleStates: [Bool] = []
    @State private var hapticsTrigger: Bool = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {

                let allTabs = Array(Value.allCases)
                let halfCount = allTabs.count / 2
                let leftTabs = Array(allTabs.prefix(halfCount))
                let rightTabs = Array(allTabs.suffix(allTabs.count - halfCount))
                
                HStack(spacing: 0) {
                    ForEach(leftTabs, id: \.hashValue) { tab in
                        createTabButton(for: tab)
                    }
                }
                
                Spacer()
                    .frame(width: config.createButtonSize + 20)
                
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
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
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
            // Initialize toggle states with correct count
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
                activeTab = tab
                
                // Only toggle if within array bounds
                if index < toggleStates.count {
                    toggleStates[index].toggle()
                }
                
                hapticsTrigger.toggle()
                
                // Simple haptic feedback available on all iOS 17+ devices
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
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
