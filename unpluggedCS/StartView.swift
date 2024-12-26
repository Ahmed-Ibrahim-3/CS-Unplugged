//
//  StartView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 15/10/2024.
//

import SwiftUI

let backgroundGradient = LinearGradient(
    colors: [Color.purple, Color.blue, Color.green],
    startPoint: .init(x: 1, y: 0), endPoint: .init(x: 0, y: 1)
)

struct StartView: View {
    @State private var name: String = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
#if os(tvOS)
        HStack {
            titleView.padding(50)
                .navigationTitle("CS-Unplugged-Replugged-Main")

            textFieldView
                .textFieldStyle(.plain)

            navigationLinkView.padding(50)
        }
#elseif os(iOS)
        VStack {
            titleView.padding()
                .multilineTextAlignment(.center)

            textFieldView
                .textFieldStyle(.roundedBorder)
                .frame(width: 400, height: 50)

            navigationLinkView
        }
#endif
    }
    private var titleView: some View {
        Text("Start")
            .font(.title)
            .foregroundColor(.white)
    }
    private var textFieldView: some View {
        TextField("Enter name", text: $name)
            .padding()
            .cornerRadius(20)
    }

    private var navigationLinkView: some View {
        NavigationLink("Go!") {
            HomeView(name: name)
        }
        .foregroundColor(.white)
    }
}

struct ViewItem {
    let name: String
    let view: AnyView
    let image: String
}

struct HomeView: View {
    let views: [ViewItem] = [
        ViewItem(name: "Bit Manipulation", view: AnyView(BitView()), image: "01.square.fill"),
        ViewItem(name: "Searching", view: AnyView(SearchView()), image: "exclamationmark.magnifyingglass"),
        ViewItem(name: "Sorting", view: AnyView(SortingView()), image: "chart.bar.xaxis.ascending"),
        ViewItem(name: "Data Structures", view: AnyView(DataView()), image: "square.stack.3d.up"),
        ViewItem(name: "Computer Architecture", view: AnyView(CAView()), image: "cpu.fill"),
        ViewItem(name: "State Machines", view: AnyView(StateView()), image: "statemachine"),
        ViewItem(name: "Graphs", view: AnyView(GraphView()), image: "point.3.connected.trianglepath.dotted"),
        ViewItem(name: "Security", view: AnyView(SecurityView()), image: "lock.icloud"),
        ViewItem(name: "Programming Languages", view: AnyView(ProgLangView()), image: "books.vertical.fill"),
        ViewItem(name: "Image Representation", view: AnyView(ImgView()), image: "photo.artframe"),
        ViewItem(name: "Network Protocols", view: AnyView(NetworkView()), image: "network"),
        ViewItem(name: "Human-Computer Interaction", view: AnyView(HCIView()), image: "desktopcomputer.trianglebadge.exclamationmark")
    ]
    
    let home = "bold"
    var name : String = ""
    
    init(name: String) {
        self.name = name
    }
    
    var body: some View {
        #if os(tvOS)
        NavigationView {
            GridView(viewItems: views)
                .navigationTitle("Hello, " + name)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        #elseif os(iOS)
        VStack {
            NavigationStack {
                GridView(viewItems: views)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Hello, " + name)
                                .font(.largeTitle.bold())
                                .accessibilityAddTraits(.isHeader)
                                .foregroundColor(.white)
                        }
                    }
            }
        }
        #endif
    }
}

struct GridView: View {
    let viewItems: [ViewItem]

    // 3 columns in both tvOS and iOS
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        #if os(tvOS)
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(viewItems, id: \.name) { item in
                    NavigationLink(destination: item.view) {
                        tvOSItemLabel(for: item)
                    }
                    .cornerRadius(30)
                }
            }
        }
        #elseif os(iOS)
        VStack {
            NavigationStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewItems, id: \.name) { item in
                        NavigationLink(destination: item.view) {
                            iOSItemLabel(for: item)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        #endif
    }

    // MARK: - tvOS Item Label
    private func tvOSItemLabel(for item: ViewItem) -> some View {
        HStack {
            Text(item.name)
                .foregroundColor(.white)
                .frame(width: 300, height: 100)
                .shadow(radius: 5)
            // For "State Machines" use asset, else system name
            if item.name == "State Machines" {
                Image(item.image) // Asset named "statemachine"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125, height: 125)
                    .foregroundColor(.white)
            } else {
                Image(systemName: item.image) // SF Symbol
            }
        }.frame(width: 450, height: 100)
    }

    private func iOSItemLabel(for item: ViewItem) -> some View {
        VStack(spacing: 10) {
            Text(item.name)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 150, height: 40)
                .cornerRadius(10)

            if item.name == "State Machines" {
                Image(item.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            } else {
                Image(systemName: item.image)
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

#Preview {
//    StartView()
    HomeView(name: "test")
}
