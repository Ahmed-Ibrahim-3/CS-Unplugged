//
//  StateView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

// MARK: - Models

/// Represents a state in a Deterministic Finite Automaton (DFA)
struct DFAState: Identifiable, Hashable {
    /// Unique identifier for the state
    let id = UUID()
    var name: String
    
    /// Whether this is an accepting/final state
    var isAccepting: Bool = false
    
    /// Position of the state in the canvas
    var position: CGPoint
}

/// Represents a transition between states in a DFA
struct DFATransition: Identifiable, Hashable {
    /// Unique identifier for the transition
    let id = UUID()
    
    /// ID of the source state
    var fromStateID: UUID
    
    /// ID of the destination state
    var toStateID: UUID
    
    /// Symbol that triggers this transition
    var symbol: String
}

// MARK: - View Model

/// View model for managing the states and transitions of a DFA
class DFAViewModel: ObservableObject {
    /// Collection of states in the DFA
    @Published var states: [DFAState] = []
    
    /// Collection of transitions between states
    @Published var transitions: [DFATransition] = []
    
    /// Counter for generating sequential state names
    private var nextStateNumber: Int = 1
    
    /// Initializes a new DFA with a single state
    init() {
        addState()
    }
    
    /// Adds a new state to the DFA at a non-overlapping position
    func addState() {
#if os(tvOS)
        let maxWidth:  CGFloat = 600
        let maxHeight: CGFloat = 600
#elseif os(iOS)
        let maxWidth:  CGFloat = 300
        let maxHeight: CGFloat = 300
#endif

        let collisionRadius: CGFloat = 60
        let maxAttempts = 50
        
        var chosenPoint: CGPoint = CGPoint(x: 100, y: 100)
        
        // Try to find a non-overlapping position
        for _ in 0..<maxAttempts {
            let randomX = CGFloat.random(in: 0...maxWidth)
            let randomY = CGFloat.random(in: 0...maxHeight)
            let candidate = CGPoint(x: randomX, y: randomY)
            
            let isOverlapping = states.contains { s in
                let dx = s.position.x - candidate.x
                let dy = s.position.y - candidate.y
                let distance = hypot(dx, dy)
                return distance < collisionRadius
            }
            
            if !isOverlapping {
                chosenPoint = candidate
                break
            }
        }
        
        // Create and add the new state
        let newState = DFAState(
            name: "\(nextStateNumber)",
            position: chosenPoint
        )
        nextStateNumber += 1
        states.append(newState)
    }
    
    /// Removes a state and all its associated transitions
    /// - Parameter state: The state to remove
    func removeState(_ state: DFAState) {
        states.removeAll { $0.id == state.id }
        transitions.removeAll { $0.fromStateID == state.id || $0.toStateID == state.id }
    }
    
    /// Toggles whether a state is an accepting state
    /// - Parameter state: The state to toggle
    func toggleAccepting(_ state: DFAState) {
        guard let idx = states.firstIndex(where: { $0.id == state.id }) else { return }
        states[idx].isAccepting.toggle()
    }
    
    /// Adds a new transition between states
    /// - Parameters:
    ///   - from: The source state
    ///   - to: The destination state
    ///   - symbol: The symbol that triggers this transition
    func addTransition(from: DFAState, to: DFAState, symbol: String) {
        let transition = DFATransition(fromStateID: from.id, toStateID: to.id, symbol: symbol)
        transitions.append(transition)
    }
    
    /// Removes a transition
    /// - Parameter transition: The transition to remove
    func removeTransition(_ transition: DFATransition) {
        transitions.removeAll { $0.id == transition.id }
    }
}

// MARK: - Drawing Components

/// Shape representing a line between two points
struct LineShape: Shape {
    /// Starting point of the line
    let from: CGPoint
    
    /// Ending point of the line
    let to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        return p
    }
}

/// Shape representing a self-loop (transition from a state to itself)
struct SelfLoopShape: Shape {
    let center: CGPoint
    let loopRadius: CGFloat = 40
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        
        let loopCenter = CGPoint(x: center.x, y: center.y - loopRadius)
        
        p.addArc(
            center: loopCenter,
            radius: loopRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        return p
    }
}

/// View for displaying a transition line between states
struct TransitionLineView: View {
    /// Starting point of the transition
    let from: CGPoint
    
    /// Ending point of the transition
    let to: CGPoint
    
    /// Symbol for this transition
    let label: String
    
    var body: some View {
        ZStack {
            LineShape(from: from, to: to)
                .stroke(Color.white, lineWidth: 2)
                .accessibilityHidden(true)
            
            Text(label)
                .position(
                    x: (from.x + to.x)/2,
                    y: (from.y + to.y)/2
                )
                .accessibilityLabel("Transition with symbol \(label)")
        }
    }
}

/// View for displaying a self-loop transition
struct SelfLoopView: View {
    /// Center of the state
    let center: CGPoint
    
    /// Symbol for this transition
    let label: String
    
    var body: some View {
        ZStack {
            SelfLoopShape(center: center)
                .stroke(Color.white, lineWidth: 2)
                .accessibilityHidden(true)
            
            Text(label)
                .position(x: center.x, y: center.y - 60)
                .accessibilityLabel("Self-loop transition with symbol \(label)")
        }
    }
}

/// View for displaying a state as a circle
struct StateCircleView: View {
    let state: DFAState
    
    var body: some View {
        ZStack {
            Circle()
                .fill(state.isAccepting ? Color.green : Color.blue)
                .frame(width: 50, height: 50)
            
            if state.isAccepting {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 56, height: 56)
            }
            
            Text(state.name)
                .foregroundColor(.white)
        }
        .accessibilityLabel("State \(state.name)\(state.isAccepting ? ", accepting state" : "")")
    }
}

// MARK: - Platform-Specific Canvas Views

#if os(iOS)
/// Interactive canvas for displaying and manipulating the DFA on iOS
struct DFACanvasiOSView: View {
    /// The view model controlling the DFA
    @ObservedObject var viewModel: DFAViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Draw all transitions
                ForEach(viewModel.transitions, id: \.id) { transition in
                    let fromState = viewModel.states.first { $0.id == transition.fromStateID }
                    let toState   = viewModel.states.first { $0.id == transition.toStateID }
                    
                    if let from = fromState, let to = toState {
                        if from.id == to.id {
                            SelfLoopView(center: from.position, label: transition.symbol)
                        } else {
                            TransitionLineView(
                                from: from.position,
                                to: to.position,
                                label: transition.symbol
                            )
                        }
                    } else {
                        EmptyView()
                    }
                }
                
                // Draw all states
                ForEach($viewModel.states) { $state in
                    StateCircleView(state: state)
                        .position(state.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    state.position = value.location
                                }
                        )
                        .accessibilityHint("Drag to move this state")
                }
            }
        }
    }
}
#endif

#if os(tvOS)
/// Interactive canvas for displaying and manipulating the DFA on tvOS
struct DFACanvastvOSView: View {
    /// The view model controlling the DFA
    @ObservedObject var viewModel: DFAViewModel
    
    /// ID of the currently focused state
    @FocusState private var focusedStateID: UUID?
    
    var body: some View {
        GeometryReader { geo in
            let allTransitions = viewModel.transitions
            let allStates = viewModel.states
            
            ZStack {
                // Draw all transitions
                ForEach(viewModel.transitions, id: \.id) { transition in
                    let fromState = viewModel.states.first { $0.id == transition.fromStateID }
                    let toState   = viewModel.states.first { $0.id == transition.toStateID }
                    
                    if let from = fromState, let to = toState {
                        if from.id == to.id {
                            SelfLoopView(center: from.position, label: transition.symbol)
                        } else {
                            TransitionLineView(
                                from: from.position,
                                to: to.position,
                                label: transition.symbol
                            )
                        }
                    } else {
                        EmptyView()
                    }
                }
                
                // Draw all states
                ForEach(allStates, id: \.id) { state in
                    let isFocused = (focusedStateID == state.id)
                    
                    StateCircleView(state: state)
                        .position(state.position)
                        .focusable(true) { _ in
                            focusedStateID = state.id
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(isFocused ? Color.yellow : Color.clear, lineWidth: 4)
                                .frame(width: 60, height: 60)
                        )
                        .accessibilityHint("Navigate to focus on this state")
                }
            }
        }
    }
}
#endif

// MARK: - DFA Builder View

/// Interactive view for building and manipulating a DFA
struct UnifiedDFABuilderView: View {
    /// View model for the DFA
    @StateObject private var viewModel = DFAViewModel()
    
    /// Currently selected source state for a new transition
    @State private var selectedFromState: DFAState?
    
    /// Currently selected destination state for a new transition
    @State private var selectedToState: DFAState?
    
    /// Symbol for a new transition
    @State private var transitionSymbol: String = ""
    
    var body: some View {
        Text("Interactive DFA Builder")
            .font(.title)
            .focusable(true)
            .accessibilityAddTraits(.isHeader)
            
        HStack(spacing: 10) {
#if os(iOS)
            // iOS-specific layout
            DFACanvasiOSView(viewModel: viewModel)
                .frame(minHeight: 300)
            
            // Controls panel
            HStack(alignment: .top, spacing: 30) {
                statesPanel
                transitionsPanel
            }
            .padding(.horizontal, 10)

#elseif os(tvOS)
            // tvOS-specific layout
            DFACanvastvOSView(viewModel: viewModel)
                .frame(minWidth: 300, maxWidth: 600, minHeight: 300, maxHeight: 600)
            
            // Controls panel
            HStack(alignment: .top, spacing: 30) {
                statesPanel
                transitionsPanel
            }
            .padding(.horizontal, 10)
#endif
        }
        .interactiveArea()
    }
    
    // MARK: Control Panels
    /// Panel for managing states
    private var statesPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("States")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            // List of states with controls
            ForEach(viewModel.states) { state in
                HStack {
                    Text("State \(state.name)")
                    
                    Button(action: { viewModel.toggleAccepting(state) }) {
                        Text(state.isAccepting ? "Accepting" : "Mark Accepting")
                            .foregroundColor(state.isAccepting ? .green : .red)
                    }
#if os(tvOS)
                    .frame(width: 350,  height: 20)
#else
                    .frame(width: 150,  height: 20)
#endif
                    .accessibilityHint("Toggle whether this is an accepting state")
                    
                    Button(action: { viewModel.removeState(state) }) {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                    .accessibilityLabel("Delete State \(state.name)")
                }
            }
            
            // Add state button
            Button("Add State") {
                viewModel.addState()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Creates a new state in the DFA")
        }
#if os(tvOS)
        .frame(width: 800)
#else
        .frame(width: 350)
#endif
    }
    
    /// Panel for managing transitions
    private var transitionsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transitions")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            // List of transitions with controls
            ForEach(viewModel.transitions) { transition in
                if let fromState = viewModel.states.first(where: { $0.id == transition.fromStateID }),
                   let toState = viewModel.states.first(where: { $0.id == transition.toStateID }) {
                    HStack {
                        if fromState.id == toState.id {
                            Text("\(fromState.name) -\(transition.symbol)-> (self)")
                        } else {
                            Text("\(fromState.name) -\(transition.symbol)-> \(toState.name)")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.removeTransition(transition)
                        }) {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                        .accessibilityLabel("Delete transition from \(fromState.name) to \(toState.name) with symbol \(transition.symbol)")
                    }
                }
            }
            
            // Add transition controls
            VStack(alignment: .leading, spacing: 4) {
                Text("Add Transition")
                    .accessibilityAddTraits(.isHeader)
                
                // From state picker
                Picker("From:", selection: $selectedFromState) {
                    Text("Select").tag(DFAState?.none)
                    ForEach(viewModel.states, id: \.id) { state in
                        Text(state.name).tag(DFAState?.some(state))
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Select source state")
                
                // To state picker
                Picker("To:", selection: $selectedToState) {
                    Text("Select").tag(DFAState?.none)
                    ForEach(viewModel.states, id: \.id) { state in
                        Text(state.name).tag(DFAState?.some(state))
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Select destination state")
                
                // Symbol input
                TextField("Symbol (e.g. a, b, c)", text: $transitionSymbol)
                #if os(iOS)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #else
                    .textFieldStyle(.plain)
                #endif
                    .foregroundColor(.gray)
                    .accessibilityLabel("Transition symbol")
                
                // Add transition button
                Button("Add Transition") {
                    guard
                        let from = selectedFromState,
                        let to = selectedToState,
                        !transitionSymbol.isEmpty
                    else { return }
                    viewModel.addTransition(from: from, to: to, symbol: transitionSymbol)
                    selectedFromState = nil
                    selectedToState = nil
                    transitionSymbol = ""
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Creates a new transition between the selected states")
            }
        }
        .frame(width: 250)
    }
}

// MARK: - Main View

/// Main view for learning about and interacting with state machines
struct StateView: View {
    // MARK: Content Text
    
    /// Text explaining state machines and their components
    let explanationText: LocalizedStringKey = """
    Finite-State Automata — or simply state machines — are a good way to model computation, perform pattern matching, and process text.
    
    They can be thought of as a map consisting of:
        \u{2022} a set of states, usually represented by circles
        \u{2022} transitions (or paths) between each state
        \u{2022} an initial input state represented by an arrow
        \u{2022} an exit (accepting) state represented by a double circle
    
    You are starting at the input state, your destination is the exit state, and you take the transitions to get there.
    
    A finite state automata where every state has exactly one transition for each input is called a **Deterministic Finite Automaton(DFA)**
    """
    
    /// Text explaining the examples shown in the diagram
    let examplesText: LocalizedStringKey = """
    In these examples, we have numbered states 1, 2 and 3, with transitions A and B between each one. From the initial state, the aim is to finish at (one of) the exit states.
    
    How will each of these finite state automata reach an exit state?
    """
    
    // MARK: Body
    
    var body: some View {
        ScrollView {
            VStack {
                Text("State Machines")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                    .focusable(true)
                    .accessibilityAddTraits(.isHeader)
                
                Text(explanationText)
                    .padding()
                    .accessibilityLabel("Explanation of state machines")
                
                HStack {
                    Image("FSA")
                        .resizable()
                        .frame(width: 650, height: 150)
                        .scaledToFit()
                        .colorInvert()
                        .accessibilityLabel("Diagram showing three examples of finite state automata")
                    
                    Text(examplesText)
                        .padding()
                }
                
                HStack {
                    Image("sentenceFSA")
                        .resizable()
                        .frame(width: 550, height: 200)
                        .aspectRatio(contentMode: .fill)
                        .colorInvert()
                        .accessibilityLabel("Diagram of a state machine for constructing sentences")
                    
                    Text("Discuss amongst yourselves what this state machine constructs?")
                        .accessibilityLabel("Discussion question about the sentence state machine")
                }
                
                Divider().padding(.vertical, 10)
                
                UnifiedDFABuilderView()
            }
            .padding()
            .background(appBackgroundGradient)
            .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Preview Provider

#Preview {
    StateView()
}
