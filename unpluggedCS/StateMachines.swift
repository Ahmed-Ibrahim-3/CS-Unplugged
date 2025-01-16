//
//  StateView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

struct DFAState: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var isAccepting: Bool = false
    var position: CGPoint
}

struct DFATransition: Identifiable, Hashable {
    let id = UUID()
    var fromStateID: UUID
    var toStateID: UUID
    var symbol: String
}

class DFAViewModel: ObservableObject {
    @Published var states: [DFAState] = []
    @Published var transitions: [DFATransition] = []
    
    private var nextStateNumber: Int = 1
    
    init() {
        addState()
    }
    
    func addState() {
        #if os(tvOS)
        let maxWidth:  CGFloat = 600
        let maxHeight: CGFloat = 600
        let collisionRadius: CGFloat = 60
        let maxAttempts = 50
        
        var chosenPoint: CGPoint = CGPoint(x: 100, y: 100)
        
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
        
        let newState = DFAState(
            name: "\(nextStateNumber)",
            position: chosenPoint
        )
        nextStateNumber += 1
        states.append(newState)
        
        #else
        let x = 100 + CGFloat(nextStateNumber - 1) * 120
        let newState = DFAState(
            name: "\(nextStateNumber)",
            position: CGPoint(x: x, y: 200)
        )
        nextStateNumber += 1
        states.append(newState)
        #endif
    }

    
    func removeState(_ state: DFAState) {
        states.removeAll { $0.id == state.id }
        transitions.removeAll { $0.fromStateID == state.id || $0.toStateID == state.id }
    }
    
    func toggleAccepting(_ state: DFAState) {
        guard let idx = states.firstIndex(where: { $0.id == state.id }) else { return }
        states[idx].isAccepting.toggle()
    }
    
    func addTransition(from: DFAState, to: DFAState, symbol: String) {
        let transition = DFATransition(fromStateID: from.id, toStateID: to.id, symbol: symbol)
        transitions.append(transition)
    }
    
    func removeTransition(_ transition: DFATransition) {
        transitions.removeAll { $0.id == transition.id }
    }
}


struct LineShape: Shape {
    let from: CGPoint
    let to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: from)
        p.addLine(to: to)
        return p
    }
}

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

struct TransitionLineView: View {
    let from: CGPoint
    let to: CGPoint
    let label: String
    
    var body: some View {
        ZStack {
            LineShape(from: from, to: to)
                .stroke(Color.white, lineWidth: 2)
            Text(label)
                
                .position(
                    x: (from.x + to.x)/2,
                    y: (from.y + to.y)/2
                )
        }
    }
}

struct SelfLoopView: View {
    let center: CGPoint
    let label: String
    
    var body: some View {
        ZStack {
            SelfLoopShape(center: center)
                .stroke(Color.white, lineWidth: 2)
            Text(label)
                
                .position(x: center.x, y: center.y - 60)
        }
    }
}

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
                
        }
    }
}

#if os(iOS)
struct DFACanvasiOSView: View {
    @ObservedObject var viewModel: DFAViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
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

                }
                
                ForEach($viewModel.states) { $state in
                    StateCircleView(state: state)
                        .position(state.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    state.position = value.location
                                }
                        )
                }
            }
        }
    }

#endif

#if os(tvOS)
struct DFACanvastvOSView: View {
    @ObservedObject var viewModel: DFAViewModel
    
    @FocusState private var focusedStateID: UUID?
    
    var body: some View {
        GeometryReader { geo in
            let allTransitions = viewModel.transitions
            let allStates = viewModel.states
            
            ZStack {
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
                }
            }
        }
    }
}
#endif

struct UnifiedDFABuilderView: View {
    @StateObject private var viewModel = DFAViewModel()
    
    @State private var selectedFromState: DFAState?
    @State private var selectedToState: DFAState?
    @State private var transitionSymbol: String = ""
    
    var body: some View {
        Text("Interactive DFA Builder")
            .font(.title)
            
        HStack(spacing: 10) {
            #if os(iOS)
            DFACanvasiOSView(viewModel: viewModel)
                .frame(minHeight: 300)
            HStack(alignment: .top, spacing: 30) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("States").font(.headline)
                    
                    ForEach(viewModel.states) { state in
                        HStack {
                            Text("State \(state.name)")
                                
                            Button(action: { viewModel.toggleAccepting(state) }) {
                                Text(state.isAccepting ? "Accepting" : "Mark Accepting")
                                    .foregroundColor(state.isAccepting ? .green : .red)
                            }.frame(width: 150, height: 20)
                            Button(action: { viewModel.removeState(state) }) {
                                Image(systemName: "trash").foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button("Add State") {
                        viewModel.addState()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(width: 350)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transitions").font(.headline)
                    
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
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add Transition")
                        
                        Picker("From:", selection: $selectedFromState) {
                            Text("Select").tag(DFAState?.none)
                            ForEach(viewModel.states, id: \.id) { state in
                                Text(state.name).tag(DFAState?.some(state))
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Picker("To:", selection: $selectedToState) {
                            Text("Select").tag(DFAState?.none)
                            ForEach(viewModel.states, id: \.id) { state in
                                Text(state.name).tag(DFAState?.some(state))
                            }
                        }
                        .pickerStyle(.menu)
                        
                        TextField("Symbol (e.g. a, b, c)", text: $transitionSymbol)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.gray)
                        
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
                    }
                }
                .frame(width: 250)
            }
            .padding(.horizontal, 10)

            #elseif os(tvOS)
            DFACanvastvOSView(viewModel: viewModel)
                .frame(minWidth:300 , maxWidth: 600, minHeight: 300, maxHeight: 600)
            HStack(alignment: .top, spacing: 30) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("States").font(.headline)
                    
                    ForEach(viewModel.states) { state in
                        HStack {
                            Text("State \(state.name)")
                                
                            Button(action: { viewModel.toggleAccepting(state) }) {
                                Text(state.isAccepting ? "Accepting" : "Mark Accepting")
                                    .foregroundColor(state.isAccepting ? .green : .red)
                            }.frame(width: 350, height: 20)
                            Button(action: { viewModel.removeState(state) }) {
                                Image(systemName: "trash").foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button("Add State") {
                        viewModel.addState()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(width: 800)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transitions").font(.headline)
                    
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
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add Transition")
                        
                        Picker("From:", selection: $selectedFromState) {
                            Text("Select").tag(DFAState?.none)
                            ForEach(viewModel.states, id: \.id) { state in
                                Text(state.name).tag(DFAState?.some(state))
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Picker("To:", selection: $selectedToState) {
                            Text("Select").tag(DFAState?.none)
                            ForEach(viewModel.states, id: \.id) { state in
                                Text(state.name).tag(DFAState?.some(state))
                            }
                        }
                        .pickerStyle(.menu)
                        
                        TextField("Symbol (e.g. a, b, c)", text: $transitionSymbol)
                            .textFieldStyle(.plain)
                            .foregroundColor(.gray)
                            
                        
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
                    }
                }
                .frame(width: 250)
            }
            .padding(.horizontal, 10)

            #endif
            
        }
        .interactiveArea()
    }
}

struct StateView: View {
    var body: some View {
        ScrollView {
            VStack() {
                Text("State Machines")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                    
                
                Text("""
                Finite-State Automata (FSA) — The simplest form of state machine — are a good way to model computation, perform pattern matching, and process text.
                
                They can be thought of as a map consisting of:
                    \u{2022} a set of states, usually represented by circles
                    \u{2022} transitions (or paths) between each state
                    \u{2022} an initial input state represented by an arrow
                    \u{2022} an exit (accepting) state represented by a double circle
                """).padding()
                
                
                HStack {
                    Image("FSA")
                        .resizable()
                        .frame(width: 650, height: 150)
                        .scaledToFit()
                        .colorInvert()
                    
                    Text("""
                    In these examples, we have numbered states 1, 2 and 3, with transitions A and B between each one. From the initial state, the aim is to finish at (one of) the exit states.
                    
                    How will each of these finite state automata reach an exit state?
                    """).padding()
                    
                }
                
                HStack {
                    Image("sentenceFSA")
                        .resizable()
                        .frame(width: 550, height: 200)
                        .aspectRatio(contentMode: .fill)
                        .colorInvert()
                    
                    Text("Discuss amongst yourselves what this state machine constructs?")
                        
                }
                
                Divider().padding(.vertical, 10)
                
                UnifiedDFABuilderView()
            }
            .padding()
            .background(backgroundGradient)
            .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    StateView()
}
