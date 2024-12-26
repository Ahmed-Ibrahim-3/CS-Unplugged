//
//  GraphView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct Node: Identifiable, Equatable {
    let id = UUID()
    var label: String
    var position: CGPoint = .zero
}

struct Edge: Identifiable, Equatable {
    let id = UUID()
    var from: UUID
    var to: UUID
    var weight: Int?
}

class Graph: ObservableObject {
    @Published var nodes: [Node] = []
    @Published var edges: [Edge] = []
    @Published var isDirected: Bool = false
    @Published var isWeighted: Bool = false
    
    var isConnected: Bool {
        guard !nodes.isEmpty else { return false }
        var visited: Set<UUID> = []
        let start = nodes[0].id
        var queue: [UUID] = [start]
        visited.insert(start)
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let connectedEdges = edges.filter {
                $0.from == current || (!isDirected && $0.to == current)
                || $0.to == current || (!isDirected && $0.from == current)
            }
            
            for edge in connectedEdges {
                let neighbor = (edge.from == current) ? edge.to : edge.from
                if !visited.contains(neighbor) {
                    visited.insert(neighbor)
                    queue.append(neighbor)
                }
            }
        }
        
        return visited.count == nodes.count
    }
    
    var isCyclic: Bool {
        var visited = Set<UUID>()
        var stack = Set<UUID>()
        
        func dfs(_ nodeId: UUID) -> Bool {
            visited.insert(nodeId)
            stack.insert(nodeId)
            
            let neighbors = edges.compactMap { edge -> UUID? in
                if edge.from == nodeId { return edge.to }
                if !isDirected && edge.to == nodeId { return edge.from }
                return nil
            }
            
            for n in neighbors {
                if !visited.contains(n) {
                    if dfs(n) {
                        return true
                    }
                } else if stack.contains(n) {
                    return true
                }
            }
            stack.remove(nodeId)
            return false
        }
        
        for node in nodes {
            if !visited.contains(node.id) {
                if dfs(node.id) {
                    return true
                }
            }
        }
        
        return false
    }
    

    func addNode(label: String, position: CGPoint = .zero) {
        nodes.append(Node(label: label, position: position))
    }

    func removeNode(_ nodeId: UUID) {
        nodes.removeAll { $0.id == nodeId }
        edges.removeAll { $0.from == nodeId || $0.to == nodeId }
    }
    
    func addEdge(from: UUID, to: UUID, weight: Int? = nil) {
        if isWeighted {
            edges.append(Edge(from: from, to: to, weight: weight))
        } else {
            edges.append(Edge(from: from, to: to, weight: nil))
        }
    }
    
    func removeEdge(_ edgeId: UUID) {
        edges.removeAll { $0.id == edgeId }
    }
    
    func updateWeight(for edgeId: UUID, newWeight: Int?) {
        guard isWeighted else { return }
        if let idx = edges.firstIndex(where: { $0.id == edgeId }) {
            edges[idx].weight = newWeight
        }
    }
}

struct GraphExplanationView : View {
    var body : some View{
        VStack{
            Button(action: {}) {
                Text("Graphs")
                    .font(.system(.largeTitle))
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            HStack{
                Text("""
                    Unlike arrays, queues, and stacks, a Graph is a **non-linear data structure** consisting of 
                    vertices (also known as nodes) and edges. A vertex is a point or an object in the graph and 
                    an edge is used to connect two vertices to each other.
                    Graphs are non-linear because they allow us to have different paths to get from one path
                    to another, unlike linear data structures.
                        \u{2022} Try finding as many different paths as you can from node B to D
                        
                    Graphs are used to represent and solve problems where the data consists of objects
                    and relationships between them, for example:
                        \u{2022} Social Networks: Each person is a vertex, and their relationships are the edges
                                  Algorithms can suggest potential friends 
                        \u{2022} Maps and Navigation: Locations are vertices and roads are edges. Algorithms can
                                  be used to find the shortest route between locations
                        \u{2022} The Internet: Can be represented as a graph with web pages as vertices
                                  and links as edges
                        \u{2022} Biology: Graphs can be used to model systems like neural networks or virus spread
                    
                    Graphs can have many properties, they can be:
                        \u{2022} Weighted - meaning all the edges have a value representing things like distance, time, etc...
                        \u{2022} Connected - meaning all vertices are connected through at least one path of vertices. 
                        \u{2022} Directed - meaning the edges between vertices have a direction, representing a flow
                        \u{2022} Cyclic - meaning you can follow a path along the edges and get back to where you started
                    """)
                .foregroundColor(.white)
                
                VStack{
                    Image("weightedgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                    Image("connectedgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                    Image("directedgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                        .clipped()
                    Image("cyclicgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if os(iOS)
struct GraphEditorView: View {
    @ObservedObject var graph = Graph()
    
    @State private var draggedNodeId: UUID? = nil
    
    @State private var fromNode: String = ""
    @State private var toNode: String = ""
    @State private var edgeWeight: String = ""
    
    @State private var nodeCounter = 1
    
    @State private var defaultPosition = CGPoint(x: 100, y: 100)
    
    var body: some View {
        VStack {
            HStack(spacing:65) {
                Toggle("Weighted", isOn: $graph.isWeighted).frame(width: 130)
                Toggle("Directed", isOn: $graph.isDirected).frame(width: 130)
                Spacer()
                Text("Connected: \(graph.isConnected ? "Yes" : "No")")
                Text("Cyclic: \(graph.isCyclic ? "Yes" : "No")")
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding([.leading, .trailing], 10)
            .foregroundColor(Color.white)
            
            ZStack {
                ForEach(graph.edges) { edge in
                    EdgeView(edge: edge, graph: graph)
                }
                
                ForEach(graph.nodes) { node in
                    NodeView(node: node, isDragged: draggedNodeId == node.id)
                        .position(node.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if draggedNodeId == nil {
                                        draggedNodeId = node.id
                                    }
                                    if draggedNodeId == node.id {
                                        if let idx = graph.nodes.firstIndex(where: { $0.id == node.id }) {
                                            graph.nodes[idx].position = value.location
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    draggedNodeId = nil
                                }
                        )
                }
            }
            .frame(minHeight: 500)
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
            .padding()
            
            VStack(spacing: 10) {
                HStack {
                    Button("Add Node") {
                        let label = "\(nodeCounter)"
                        graph.addNode(label: label, position: defaultPosition)
                        
                        nodeCounter += 1
                        defaultPosition.x += 30
                        defaultPosition.y += 30
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                HStack {
                    TextField("From node label", text: $fromNode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("To node label", text: $toNode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Weight (opt)", text: $edgeWeight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add Edge") {
                        if let fromId = graph.nodes.first(where: { $0.label == fromNode })?.id,
                           let toId = graph.nodes.first(where: { $0.label == toNode })?.id {
                            let weight = Int(edgeWeight)
                            graph.addEdge(from: fromId, to: toId, weight: weight)
                        }
                        
                        fromNode = ""
                        toNode = ""
                        edgeWeight = ""
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding([.leading, .trailing], 10)
            .foregroundColor(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif

struct EdgeView: View {
    let edge: Edge
    @ObservedObject var graph: Graph
    
    var body: some View {
        if let fromNode = graph.nodes.first(where: { $0.id == edge.from }),
           let toNode = graph.nodes.first(where: { $0.id == edge.to }) {
            
            Path { path in
                path.move(to: fromNode.position)
                path.addLine(to: toNode.position)
            }
            .stroke(Color.orange.opacity(0.7), lineWidth: 2)
            
            if graph.isWeighted, let w = edge.weight {
                let midPoint = CGPoint(
                    x: (fromNode.position.x + toNode.position.x)/2,
                    y: (fromNode.position.y + toNode.position.y)/2
                )
                Text("\(w)")
                    .position(midPoint)
                    .foregroundColor(.red)
            }
            
            if graph.isDirected {
                ArrowHeadShape()
                    .fill(Color.orange.opacity(0.7))
                    .frame(width: 14, height: 14)
                    .position(toNode.position)
                    .rotationEffect(arrowAngle(start: fromNode.position, end: toNode.position),
                                    anchor: .center)
            }
        }
    }
    
    func arrowAngle(start: CGPoint, end: CGPoint) -> Angle {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let radians = atan2(dy, dx)
        return Angle(radians: Double(radians))
    }
}

struct ArrowHeadShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tip = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: tip)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

struct NodeView: View {
    let node: Node
    let isDragged: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isDragged ? Color.orange : Color.orange.opacity(0.7))
                .frame(width: 50, height: 50)
            
            Text(node.label)
                .foregroundColor(.white)
                .bold()
        }
    }
}

#if os(tvOS)
struct GraphEditorView_tvOS: View {
    @ObservedObject var graph = Graph()
    
    @State private var nodeCounter = 1
    
    @State private var selectedNodeIndex: Int = 0
    
    @State private var fromNode: String = ""
    @State private var toNode: String = ""
    @State private var edgeWeight: String = ""
    
    var body: some View {
        VStack {
            HStack() {
                Toggle("Weighted", isOn: $graph.isWeighted)
                Toggle("Directed", isOn: $graph.isDirected)
                Spacer()
                Text("Connected: \(graph.isConnected ? "Yes" : "No")")
                Text("Cyclic: \(graph.isCyclic ? "Yes" : "No")")
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding([.leading, .trailing], 10)
            .foregroundColor(Color.white)
            
            ZStack {
                ForEach(graph.edges) { edge in
                    EdgeView(edge: edge, graph: graph)
                }
                
                ForEach(graph.nodes.indices, id: \.self) { idx in
                    let node = graph.nodes[idx]
                    NodeView(node: node, isDragged: idx == selectedNodeIndex)
                        .position(node.position)
                }
            }
            .frame(minHeight: 500)
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
            .padding()
            
            VStack{
                HStack(spacing:25){
                    Button("Prev Node") {
                        guard !graph.nodes.isEmpty else { return }
                        selectedNodeIndex = (selectedNodeIndex - 1 + graph.nodes.count) % graph.nodes.count
                    }
                    Button("Next Node") {
                        guard !graph.nodes.isEmpty else { return }
                        selectedNodeIndex = (selectedNodeIndex + 1) % graph.nodes.count
                    }
                    Button("Move Up") {
                        moveSelectedNodeBy(CGSize(width: 0, height: -15))
                    }
                    Button("Move Down") {
                        moveSelectedNodeBy(CGSize(width: 0, height: 15))
                    }
                    Button("Move Left") {
                        moveSelectedNodeBy(CGSize(width: -15, height: 0))
                    }
                    Button("Move Right") {
                        moveSelectedNodeBy(CGSize(width: 15, height: 0))
                    }
                }
                .padding(.bottom, 20)
                
                HStack {
                    Button("Add Node") {
                        let label = "\(nodeCounter)"
                        let position = CGPoint(x: 100, y: 100)
                        graph.addNode(label: label, position: position)
                        nodeCounter += 1
                        
                        selectedNodeIndex = max(0, graph.nodes.count - 1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                    TextField("From node label", text: $fromNode)
                        .textFieldStyle(.automatic)
                        .frame(width: 150)
                    TextField("To node label", text: $toNode)
                        .textFieldStyle(.automatic)
                        .frame(width: 150)
                    TextField("Weight (opt)", text: $edgeWeight)
                        .textFieldStyle(.automatic)
                        .frame(width: 100)
                    
                    Button("Add Edge") {
                        if let fromId = graph.nodes.first(where: { $0.label == fromNode })?.id,
                           let toId = graph.nodes.first(where: { $0.label == toNode })?.id {
                            let weight = Int(edgeWeight)
                            graph.addEdge(from: fromId, to: toId, weight: weight)
                        }
                        fromNode = ""
                        toNode = ""
                        edgeWeight = ""
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding([.leading, .trailing], 10)
            .foregroundColor(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func moveSelectedNodeBy(_ offset: CGSize) {
        guard !graph.nodes.isEmpty,
              graph.nodes.indices.contains(selectedNodeIndex) else {
            return
        }
        graph.nodes[selectedNodeIndex].position.x += offset.width
        graph.nodes[selectedNodeIndex].position.y += offset.height
    }
}
#endif

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        GraphEditorView()
        #elseif os(tvOS)
        GraphEditorView_tvOS()
        #else
        Text("Platform not supported")
        #endif
    }
}

struct GraphView: View {
    var body: some View {
        ScrollView {
            GraphExplanationView()
            Spacer()
            ContentView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}

#Preview {
    GraphView()
}
