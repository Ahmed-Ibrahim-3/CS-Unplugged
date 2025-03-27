//
//  GraphView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

// MARK: - Models

/// Represents a vertex (node) in a graph
struct Node: Identifiable, Equatable {
    /// Unique identifier for the node
    let id = UUID()
    var label: String
    /// Position of the node in the graph visualization
    var position: CGPoint = .zero
}

/// Represents a connection between two nodes in a graph
struct Edge: Identifiable, Equatable {
    /// Unique identifier for the edge
    let id = UUID()
    /// ID of the source node
    var from: UUID
    /// ID of the destination node
    var to: UUID
    /// Optional weight value for weighted graphs
    var weight: Int?
}

/// Model class that manages the graph data structure
class Graph: ObservableObject {
    /// Collection of all nodes in the graph
    @Published var nodes: [Node] = []
    
    /// Collection of all edges in the graph
    @Published var edges: [Edge] = []
    
    @Published var isDirected: Bool = false
    @Published var isWeighted: Bool = false
    
    /// Determines if all nodes in the graph are connected through some path
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
    
    /// Determines if the graph contains a cycle
    var isCyclic: Bool {
        var visited = Set<UUID>()
        var stack = Set<UUID>()
        
        /// Depth-first search helper function to detect cycles
        /// - Parameter nodeId: The ID of the current node being visited
        /// - Returns: True if a cycle is detected, false otherwise
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
    
    /// Adds a new node to the graph with the specified label and position
    /// - Parameters:
    ///   - label: Text label for the node
    ///   - position: Position of the node in the visualization (defaults to origin)
    func addNode(label: String, position: CGPoint = .zero) {
        nodes.append(Node(label: label, position: position))
    }
    
    /// Removes a node from the graph and all its connected edges
    /// - Parameter nodeId: ID of the node to remove
    func removeNode(_ nodeId: UUID) {
        nodes.removeAll { $0.id == nodeId }
        edges.removeAll { $0.from == nodeId || $0.to == nodeId }
    }
    
    /// Adds a new edge connecting two nodes
    /// - Parameters:
    ///   - from: ID of the source node
    ///   - to: ID of the destination node
    ///   - weight: Optional weight value for the edge
    func addEdge(from: UUID, to: UUID, weight: Int? = nil) {
        if isWeighted {
            edges.append(Edge(from: from, to: to, weight: weight))
        } else {
            edges.append(Edge(from: from, to: to, weight: nil))
        }
    }
    
    /// Removes an edge from the graph
    /// - Parameter edgeId: ID of the edge to remove
    func removeEdge(_ edgeId: UUID) {
        edges.removeAll { $0.id == edgeId }
    }
    
    /// Updates the weight of an existing edge
    /// - Parameters:
    ///   - edgeId: ID of the edge to update
    ///   - newWeight: New weight value to set
    func updateWeight(for edgeId: UUID, newWeight: Int?) {
        guard isWeighted else { return }
        
        if let idx = edges.firstIndex(where: { $0.id == edgeId }) {
            edges[idx].weight = newWeight
        }
    }
}

// MARK: - Supporting Views

/// Shape representing an arrow head for directed graphs
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

/// View for displaying a node in the graph
struct NodeView: View {
    let node: Node
    
    /// Whether the node is currently being dragged or selected
    let isDragged: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isDragged ? Color.orange : Color.orange.opacity(0.7))
                .frame(width: 50, height: 50)
            
            Text(node.label)
                .bold()
                .foregroundColor(.white)
        }
        .accessibilityLabel("Node \(node.label)")
        .accessibilityHint(isDragged ? "Currently selected node" : "Tap to select this node")
    }
}

/// View for displaying an edge between two nodes
struct EdgeView: View {
    let edge: Edge
    
    /// Reference to the graph model
    @ObservedObject var graph: Graph
    
    var body: some View {
        if let fromNode = graph.nodes.first(where: { $0.id == edge.from }),
           let toNode = graph.nodes.first(where: { $0.id == edge.to }) {
            
            Path { path in
                path.move(to: fromNode.position)
                path.addLine(to: toNode.position)
            }
            .stroke(Color.orange.opacity(0.7), lineWidth: 2)
            .accessibilityHidden(true)
            
            // Display weight if the graph is weighted
            if graph.isWeighted, let weight = edge.weight {
                let midPoint = CGPoint(
                    x: (fromNode.position.x + toNode.position.x)/2,
                    y: (fromNode.position.y + toNode.position.y)/2
                )
                Text("\(weight)")
                    .position(midPoint)
                    .foregroundColor(.red)
                    .accessibilityLabel("Edge weight: \(weight)")
            }
            
            // Display arrow head if the graph is directed
            if graph.isDirected {
                ArrowHeadShape()
                    .fill(Color.orange.opacity(0.7))
                    .frame(width: 14, height: 14)
                    .position(toNode.position)
                    .rotationEffect(calculateArrowAngle(start: fromNode.position, end: toNode.position),
                                    anchor: .center)
                    .accessibilityHidden(true)
            }
            
            // Add general accessibility label for the edge
            Text("")
                .accessibilityLabel("Edge from node \(fromNode.label) to node \(toNode.label)\(edge.weight != nil ? " with weight \(edge.weight!)" : "")")
                .accessibilityHidden(true)
        }
    }
    
    /// Calculates the angle of rotation for the arrow head
    /// - Parameters:
    ///   - start: Starting point of the edge
    ///   - end: Ending point of the edge
    /// - Returns: Angle of rotation for the arrow head
    private func calculateArrowAngle(start: CGPoint, end: CGPoint) -> Angle {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let radians = atan2(dy, dx)
        return Angle(radians: Double(radians))
    }
}

// MARK: - Main Content Views

/// View explaining graph theory concepts
struct GraphExplanationView: View {
    // MARK: - Content
    
    /// Explanation text describing graphs and their properties
    let explanationText: LocalizedStringKey = """
    Unlike arrays, queues, and stacks, a Graph is a **non-linear data structure** consisting of vertices (also known as nodes) and edges. A vertex is a point or an object in the graph and an edge is used to connect two vertices to each other. Graphs are non-linear because they allow us to have different paths to get from one path to another, unlike linear data structures.
        
    Graphs are used to represent and solve problems where the data consists of objects and relationships between them, for example:
        \u{2022} Social Networks: Each person is a vertex, and their relationships are the edges Algorithms can suggest potential friends 
        \u{2022} Maps and Navigation: Locations are vertices and roads are edges. Algorithms can be used to find the shortest route between locations
        \u{2022} The Internet: Can be represented as a graph with web pages as vertices and links as edges
        \u{2022} Biology: Graphs can be used to model systems like neural networks or virus spread
    
    Graphs can have many properties, they can be:
        \u{2022} Weighted - meaning all the edges have a value representing things like distance, time, etc...
        \u{2022} Connected - meaning all vertices are connected through at least one path of vertices. 
        \u{2022} Directed - meaning the edges between vertices have a direction, representing a flow
        \u{2022} Cyclic - meaning you can follow a path along the edges and get back to where you started
    """
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text("Graphs")
                .font(.system(.largeTitle))
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            HStack(alignment: .top) {
                Text(explanationText)
                    .padding()
                
                VStack(spacing: 5) {
                    Image("weightedgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                        .accessibilityLabel("Example of a weighted graph with numbers on edges")
                    
                    Image("connectedgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                        .accessibilityLabel("Example of a connected graph where all nodes can reach each other")
                    
                    Image("directedgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                        .clipped()
                        .accessibilityLabel("Example of a directed graph with arrows showing direction")
                    
                    Image("cyclicgraph")
                        .resizable()
                        .frame(width: 325, height: 150)
                        .accessibilityLabel("Example of a cyclic graph with paths that form loops")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

/// Interactive view for creating and manipulating graphs
struct GraphEditorView: View {
    // MARK: - Properties
    
    /// The graph model being edited
    @ObservedObject var graph = Graph()
    
#if os(iOS)
    /// ID of the node currently being dragged (iOS only)
    @State private var draggedNodeId: UUID? = nil
    
    /// Whether deletion mode is active (iOS only)
    @State private var deletionMode: Bool = false
#endif
    
#if os(tvOS)
    /// Index of the currently selected node (tvOS only)
    @State var selectedNodeIndex: Int = 0
#endif
    
    /// Label of the source node for new edges
    @State var fromNode: String = ""
    
    /// Label of the destination node for new edges
    @State var toNode: String = ""
    
    /// Weight value for new edges
    @State var edgeWeight: String = ""
    
    /// Counter for generating sequential node labels
    @State var nodeCounter = 1
    
    /// Default position for new nodes
    @State var defaultPosition = CGPoint(x: 350, y: 350)
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 15) {
            graphPropertyControls
            
            graphVisualizationArea
                .frame(minHeight: 500)
                .interactiveArea()
            
            graphEditingControls
                .interactiveArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Subviews
    
    /// Controls for toggling graph properties
    private var graphPropertyControls: some View {
        HStack(spacing: 65) {
#if os(tvOS)
            Toggle("Weighted", isOn: $graph.isWeighted)
                .frame(width: UIScreen.main.bounds.width / 4)
                .accessibilityHint("Toggle to enable or disable edge weights")
            
            Toggle("Directed", isOn: $graph.isDirected)
                .frame(width: UIScreen.main.bounds.width / 4)
                .accessibilityHint("Toggle to enable or disable directed edges")
#else
            Toggle("Weighted", isOn: $graph.isWeighted)
                .frame(width: UIScreen.main.bounds.width / 8)
                .accessibilityHint("Toggle to enable or disable edge weights")
            
            Toggle("Directed", isOn: $graph.isDirected)
                .frame(width: UIScreen.main.bounds.width / 8)
                .accessibilityHint("Toggle to enable or disable directed edges")
#endif
            
#if os(iOS)
            Toggle("Deletion Mode", isOn: $deletionMode)
                .frame(width: UIScreen.main.bounds.width / 6)
                .accessibilityHint("Toggle to enable deletion of nodes and edges by tapping them")
#endif
            
            Spacer()
            
            // Graph property indicators
            Text("Connected: \(graph.isConnected ? "Yes" : "No")")
                .accessibilityLabel("Graph is\(graph.isConnected ? "" : " not") connected")
            
            Text("Cyclic: \(graph.isCyclic ? "Yes" : "No")")
                .accessibilityLabel("Graph is\(graph.isCyclic ? "" : " not") cyclic")
        }
        .interactiveArea()
    }
    
    /// Area displaying the graph visualization
    private var graphVisualizationArea: some View {
        ZStack {
            // Draw all edges
            ForEach(graph.edges) { edge in
#if os(iOS)
                Group {
                    if deletionMode {
                        EdgeView(edge: edge, graph: graph)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                graph.removeEdge(edge.id)
                            }
                            .accessibilityHint("Tap to delete this edge")
                    } else {
                        EdgeView(edge: edge, graph: graph)
                    }
                }
#elseif os(tvOS)
                EdgeView(edge: edge, graph: graph)
#endif
            }
            
            // Draw all nodes
#if os(iOS)
            ForEach(graph.nodes) { node in
                Group {
                    if deletionMode {
                        NodeView(node: node, isDragged: false)
                            .position(node.position)
                            .onTapGesture {
                                graph.removeNode(node.id)
                            }
                            .accessibilityHint("Tap to delete this node")
                    } else {
                        NodeView(node: node, isDragged: draggedNodeId == node.id)
                            .position(node.position)
                            .highPriorityGesture(
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
                            .accessibilityHint("Drag to move this node")
                    }
                }
            }
#elseif os(tvOS)
            ForEach(graph.nodes.indices, id: \.self) { idx in
                let node = graph.nodes[idx]
                NodeView(node: node, isDragged: idx == selectedNodeIndex)
                    .position(node.position)
            }
#endif
        }
    }
    
    /// Controls for editing the graph
    private var graphEditingControls: some View {
        VStack(spacing: 10) {
            // Node controls
#if os(iOS)
            // Simple add node button for iOS
            HStack {
                Button("Add Node") {
                    addNewNode()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green)
                .cornerRadius(8)
                .accessibilityHint("Adds a new node to the graph")
            }
#elseif os(tvOS)
            // Extended node controls for tvOS
            tvOSNodeControls
#endif
            
            // Edge controls
            HStack {
                TextField("From node label", text: $fromNode)
                    .textFieldStyle(.automatic)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Source node label")
                
                TextField("To node label", text: $toNode)
                    .textFieldStyle(.automatic)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Destination node label")
                
                TextField("Weight (opt)", text: $edgeWeight)
                    .textFieldStyle(.automatic)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Edge weight (optional)")
                
                Button("Add Edge") {
                    addNewEdge()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green)
                .cornerRadius(8)
                .accessibilityHint("Adds a new edge between the specified nodes")
            }
        }
    }
    
#if os(tvOS)
    /// Node manipulation controls specific to tvOS
    private var tvOSNodeControls: some View {
        VStack(spacing: 10) {
            // Node selection and movement controls
            HStack(spacing: 5) {
                Button("Prev Node") {
                    guard !graph.nodes.isEmpty else { return }
                    selectedNodeIndex = (selectedNodeIndex - 1 + graph.nodes.count) % graph.nodes.count
                }
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .accessibilityHint("Select the previous node")
                
                Button("Next Node") {
                    guard !graph.nodes.isEmpty else { return }
                    selectedNodeIndex = (selectedNodeIndex + 1) % graph.nodes.count
                }
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .accessibilityHint("Select the next node")
                
                Button("Move Up") {
                    moveSelectedNodeBy(CGSize(width: 0, height: -15))
                }
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .accessibilityHint("Move the selected node upward")
                
                Button("Move Down") {
                    moveSelectedNodeBy(CGSize(width: 0, height: 15))
                }
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .accessibilityHint("Move the selected node downward")
                
                Button("Move Left") {
                    moveSelectedNodeBy(CGSize(width: -15, height: 0))
                }
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .accessibilityHint("Move the selected node left")
                
                Button("Move Right") {
                    moveSelectedNodeBy(CGSize(width: 15, height: 0))
                }
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .accessibilityHint("Move the selected node right")
                
                Button("Delete Node") {
                    deleteSelectedNode()
                }
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .accessibilityHint("Delete the selected node")
            }
            .padding(.bottom, 20)
        
            HStack {
                Button("Add Node") {
                    addNewNode()
                }
                .background(Color.green)
                .cornerRadius(8)
                .frame(width: 250, height: 100)
                .font(.system(size: 30))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .accessibilityHint("Adds a new node to the graph")
            }
        }
    }
    #endif
    
    // MARK: - Helper Methods
    
    /// Adds a new node to the graph
    private func addNewNode() {
        let label = "\(nodeCounter)"
        
#if os(iOS)
        graph.addNode(label: label, position: defaultPosition)
#elseif os(tvOS)
        let position = CGPoint(x: 100, y: 100)
        graph.addNode(label: label, position: position)
        selectedNodeIndex = max(0, graph.nodes.count - 1)
#endif
        
        nodeCounter += 1
    }
    
    /// Adds a new edge between two nodes
    private func addNewEdge() {
        if let fromId = graph.nodes.first(where: { $0.label == fromNode })?.id,
           let toId = graph.nodes.first(where: { $0.label == toNode })?.id {
            let weight = Int(edgeWeight)
            graph.addEdge(from: fromId, to: toId, weight: weight)
        }
        
        // Clear input fields
        fromNode = ""
        toNode = ""
        edgeWeight = ""
    }
    
#if os(tvOS)
    /// Moves the selected node by the specified offset
    /// - Parameter offset: The amount to move the node
    private func moveSelectedNodeBy(_ offset: CGSize) {
        guard !graph.nodes.isEmpty,
              graph.nodes.indices.contains(selectedNodeIndex) else {
            return
        }
        
        graph.nodes[selectedNodeIndex].position.x += offset.width
        graph.nodes[selectedNodeIndex].position.y += offset.height
    }
    
    /// Deletes the currently selected node
    private func deleteSelectedNode() {
        if !graph.nodes.isEmpty, graph.nodes.indices.contains(selectedNodeIndex) {
            let node = graph.nodes[selectedNodeIndex]
            graph.removeNode(node.id)
            selectedNodeIndex = graph.nodes.isEmpty ? 0 : selectedNodeIndex % graph.nodes.count
        }
    }
#endif
}

// MARK: - Main View

/// The main view displaying graph theory explanation and interactive graph editor
struct GraphView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GraphExplanationView()
                
                Spacer(minLength: 30)
                
                GraphEditorView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

// MARK: - Preview Provider

#Preview {
    GraphView()
}
