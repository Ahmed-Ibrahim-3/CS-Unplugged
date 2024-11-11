//
//  GraphView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct GraphView : View {
    var body : some View{
        Text("Graphs")
            .font(.system(.title2))
            .multilineTextAlignment(.center)
            .padding()
        HStack{
            Text("""
                Unlike arrays, queues, and stacks, a Graph is a **non-linear data structure** consisting of 
                vertices (also known as nodes) and edges. A vertex is a point or an object in the graph and 
                en edge is used to connect two vertices to each other.
                Graphs are non-linear because they allow us to have different paths to get from one path
                to another,unlike linear data structures.
                    \u{2022} Try finding as many different paths as you can from node B to D
                    
                Graphs are used to represent and solve problems where the data consists of objects
                and relationships between them, for example:
                    \u{2022} Social Networks: Each person is a vertex, and their relationships are the edges
                            Algorithms can suggest potential friends 
                    \u{2022} Maps and Navigation: Locations are vertices and roads are edges. Algorithms can
                            be used to find the shorted route between locations
                    \u{2022} The Internet: Can be represented as graph with web pages as vertices as links as edges
                    \u{2022} Biology: Graphs can be used to model systems like neural networks or virus spread
                
                graphs can have many properties, they can be;
                    \u{2022} Weighted - meaning all the edges have a value representing things like distance, time, etc...
                    \u{2022} Connected - meaning all vertices are connected though at least one path of vertices. 
                    \u{2022} Directed - meaning the edges between vertices have a direction, representing a flow
                    \u{2022} Cyclinc - meaning you can follow a path along the edges from and get back to where you start
                """)
            VStack{
                Image("weightedgraph")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 325, height: 200)
                    .clipped()
                Image("connectedgraph")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 325, height: 200)
                    .clipped()
                Image("directedgraph")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 325, height: 200)
                    .clipped()
                Image("cyclicgraph")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 325, height: 200)
                    .clipped()
            }
        }
    }
}

#Preview {
    GraphView()
}
