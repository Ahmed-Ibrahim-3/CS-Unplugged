//
//  StartView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 15/10/2024.
//

import SwiftUI

let backgroundGradient = LinearGradient(
    colors: [Color.purple, Color.blue, Color.green],
    startPoint: .init(x: 1, y: 0), endPoint: .init(x: 0, y: 1))


struct StartView: View {
    @State private var name: String = ""
    @State private var showingAlert = false

        var body: some View {
            ZStack {
                backgroundGradient
                    NavigationStack{
                        HStack {
                            Text("Start")
                                .font(.title)
                                .padding(50)
                                .navigationTitle("CS-Unplugged-Replugged-Start")
                            
                            TextField("Enter name", text: $name)
                                .textFieldStyle(.plain)
                                NavigationLink("Go!") {
                                    HomeView(name:name)
                                }
                                .padding(50)
                        }
                    }
                }
            }
        }

struct ViewItem {
    let name: String
    let view: AnyView
    let image: String
}

struct HomeView : View {
    let views: [ViewItem] = [
        ViewItem(name: "Bit Manipulation", view: AnyView(BitView()), image: "01.square.fill"),
        ViewItem(name: "Searching", view: AnyView(SearchView()), image: "exclamationmark.magnifyingglass"),
        ViewItem(name: "Sorting", view: AnyView(SortingView()), image: "chart.bar.xaxis.ascending"),
        ViewItem(name: "Data Structures", view: AnyView(DataView()),image: "square.stack.3d.up"),
        ViewItem(name: "Computer Architecture", view: AnyView(CAView()), image: "cpu.fill"),
        ViewItem(name: "State Machines", view: AnyView(StateView()), image: "house.fill"),
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
    var body: some View{
        NavigationView {
            GridView(viewItems: views)
                .navigationTitle("Hello, " + name)
        }
    }
}

struct GridView: View {
    let viewItems: [ViewItem]
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewItems, id: \.name) { item in
                        NavigationLink(destination: item.view) {
                            Text(item.name)
                                .foregroundColor(.white)
                                .frame(width: 350, height: 100)
                                .shadow(radius: 5)
                            Image(systemName:item.image)
                        }
                        .cornerRadius(30)
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.1))
    }
}
#Preview {
    HomeView(name:"test")
}
