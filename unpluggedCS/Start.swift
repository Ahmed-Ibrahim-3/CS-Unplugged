//
//  StartView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 15/10/2024.


import SwiftUI

// MARK: - UI Constants and Helpers

/// Gradient used as the background for all main views in the app
let appBackgroundGradient = LinearGradient(
    colors: [Color(.teal1), Color(.navyBlue), Color(.darkPurple)],
    startPoint: .init(x: 1.1, y: 1.1),
    endPoint: .init(x: 0.1, y: 0.1)
)

/// Modifier that applies a consistent interactive area style to views
struct InteractiveAreaModifier: ViewModifier {
    /// Applies standardized styling to content
    /// - Parameter content: The view to modify
    /// - Returns: The styled view
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding([.leading, .trailing], 10)
    }
}

/// View extension for applying the interactive area modifier
extension View {
    /// Applies the interactive area styling to a view
    /// - Returns: The styled view
    func interactiveArea() -> some View {
        self.modifier(InteractiveAreaModifier())
    }
}

// MARK: - Model

/// Represents a topic item in the grid view
struct TopicItem {
    let name: String      // Display name of the topic
    let view: AnyView     // Associated view for the topic
    let iconName: String  // System image name or asset name for the topic icon
}

// MARK: - Views

/// Initial view for user to enter their name before proceeding to main content
struct StartView: View {
    // MARK: Properties
    @State private var userName: String = ""
    @State private var showingAlert = false

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                appBackgroundGradient.ignoresSafeArea()
                
#if os(tvOS)
                // tvOS layout - horizontal orientation
                HStack {
                    Text("Start")
                        .font(.title)
                        .padding(50)
                    
                    TextField("Enter name", text: $userName)
                        .padding()
                        .cornerRadius(20)
                        .textFieldStyle(.plain)

                    NavigationLink("Go!") {
                        HomeView(name: userName)
                    }
                    .padding(50)
                }
#elseif os(iOS)
                // iOS layout - vertical orientation
                VStack {
                    Text("Start")
                        .font(.title)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    TextField("Enter name", text: $userName)
                        .padding()
                        .cornerRadius(20)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 400, height: 50)
                        .foregroundColor(.gray)

                    NavigationLink("Go!") {
                        // Use device name if no name entered
                        if userName.isEmpty {
                            HomeView(name: UIDevice.current.name)
                        } else {
                            HomeView(name: userName)
                        }
                    }
                }
#endif
            }
            .foregroundStyle(.white)
        }
    }
}

/// Main view displaying a grid of computer science topics
struct HomeView: View {
    // MARK: Properties
    
    /// User's name to display in greeting
    var userName: String?
    
    // MARK: Initialization
    
    /// Initializes the HomeView with an optional user name
    /// - Parameter name: The user's name. If nil, uses the device name
    init(name: String?) {
        self.userName = name ?? UIDevice.current.name
    }
    
    // MARK: Body
    var body: some View {
        // Define all topic items with their associated views
        let topics: [TopicItem] = [
            TopicItem(name: "Bit Manipulation", view: AnyView(BitView()), iconName: "01.square.fill"),
            TopicItem(name: "Searching", view: AnyView(SearchView()), iconName: "exclamationmark.magnifyingglass"),
            TopicItem(name: "Sorting", view: AnyView(SortingView()), iconName: "chart.bar.xaxis.ascending"),
            TopicItem(name: "Data Structures", view: AnyView(DataView()), iconName: "square.stack.3d.up"),
            TopicItem(name: "Computer Architecture", view: AnyView(CAView(name: userName!)), iconName: "cpu.fill"),
            TopicItem(name: "State Machines", view: AnyView(StateView()), iconName: "statemachine"),
            TopicItem(name: "Graphs", view: AnyView(GraphView()), iconName: "point.3.connected.trianglepath.dotted"),
            TopicItem(name: "Security", view: AnyView(SecurityView()), iconName: "lock.icloud"),
            TopicItem(name: "Programming Languages", view: AnyView(ProgLangView()), iconName: "books.vertical.fill"),
            TopicItem(name: "Image Representation", view: AnyView(ImgView(name: userName!)), iconName: "photo.artframe"),
            TopicItem(name: "Network Protocols", view: AnyView(NetworkView()), iconName: "network"),
            TopicItem(name: "Human-Computer Interaction", view: AnyView(HCIView()), iconName: "desktopcomputer.trianglebadge.exclamationmark")
        ]
        
        VStack {
            // Platform-specific UI
#if os(tvOS)
            NavigationView {
                GridView(topicItems: topics)
                    .navigationTitle("Hello, " + userName!)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appBackgroundGradient)
#elseif os(iOS)
            NavigationStack {
                GridView(topicItems: topics)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Hello, " + userName!)
                                .font(.largeTitle.bold())
                                .accessibilityAddTraits(.isHeader)
                        }
                    }
            }
#endif
        }
        .foregroundColor(.white)
    }
}

/// Displays a grid of topic items for navigation
struct GridView: View {
    // MARK: Properties
    
    /// List of topic items to display in the grid
    let topicItems: [TopicItem]

    /// Grid layout definition - 3 flexible columns
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: Body
    var body: some View {
#if os(tvOS)
        // tvOS layout
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(topicItems, id: \.name) { item in
                    NavigationLink(destination: item.view) {
                        tvOSItemLabel(for: item)
                    }
                    .cornerRadius(30)
                }
            }
        }
#elseif os(iOS)
        // iOS layout
        VStack {
            NavigationStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(topicItems, id: \.name) { item in
                        NavigationLink(destination: item.view) {
                            iOSItemLabel(for: item)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
#endif
    }

    /// Creates a label view for a topic item on tvOS
    /// - Parameter item: The topic item to create a label for
    /// - Returns: A styled view for the topic item
    private func tvOSItemLabel(for item: TopicItem) -> some View {
        HStack {
            Text(item.name)
                .frame(width: 300, height: 100)
                .shadow(radius: 5)
            
            // Special case for State Machines icon which uses an asset instead of SF Symbol
            if item.name == "State Machines" {
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
            } else {
                Image(systemName: item.iconName)
            }
        }
        .frame(width: 450, height: 100)
    }

    /// Creates a label view for a topic item on iOS
    /// - Parameter item: The topic item to create a label for
    /// - Returns: A styled view for the topic item
    private func iOSItemLabel(for item: TopicItem) -> some View {
        VStack(spacing: 10) {
            Text(item.name)
                .font(.headline)
                .frame(width: 150, height: 40)
                .cornerRadius(10)

            // Special case for State Machines icon which uses an asset instead of SF Symbol
            if item.name == "State Machines" {
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            } else {
                Image(systemName: item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// MARK: - Preview Provider
#Preview {
    StartView()
    // HomeView(name: "User")
}
