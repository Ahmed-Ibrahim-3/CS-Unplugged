//
//  DataStructures.swift
//  unpluggedCS
//
//  Created on 17/10/2024.
//

import SwiftUI

// MARK: - Models

/// Represents the different types of data structures that can be displayed
enum DataStructureType {
    case array
    case queue
    case stack
    
    /// Returns the prefix character for elements of this data structure type
    var prefix: String {
        switch self {
        case .array: return "A"
        case .queue: return "Q"
        case .stack: return "S"
        }
    }
    
    /// Returns a human-readable name for this data structure type
    var displayName: String {
        switch self {
        case .array: return "Array"
        case .queue: return "Queue"
        case .stack: return "Stack"
        }
    }
}

// MARK: - View Model

/// View model for managing data structure operations
class DataStructureViewModel: ObservableObject {
    /// The array of elements in the data structure
    @Published private(set) var elements: [String] = []
    
    /// Counter for generating sequential element IDs
    private var elementCounter = 0
    
    /// The type of data structure being visualized
    let type: DataStructureType
    
    /// Creates a new data structure view model
    /// - Parameter type: The type of data structure to visualize
    init(type: DataStructureType) {
        self.type = type
    }
    
    /// Adds a new element to the data structure
    func addElement() {
        elementCounter += 1
        let newElement = "\(type.prefix)\(elementCounter)"
        elements.append(newElement)
    }
    
    /// Removes an element from the data structure according to its type's rules
    func removeElement() {
        guard !elements.isEmpty else { return }
        
        switch type {
        case .array, .stack:
            // Both array and stack remove from the end (LIFO for stack)
            elements.removeLast()
        case .queue:
            // Queue removes from the beginning (FIFO)
            elements.removeFirst()
        }
    }
    
    /// Resets the data structure by clearing all elements
    func reset() {
        elements.removeAll()
        elementCounter = 0
    }
    
    /// Returns a description of how the data structure removes elements
    var removalDescription: String {
        switch type {
        case .array:
            return "Removes the last element from the array"
        case .queue:
            return "Removes the first element from the queue (following FIFO principle)"
        case .stack:
            return "Removes the top element from the stack (following LIFO principle)"
        }
    }
}

// MARK: - Data Structure View Components

/// A reusable view for displaying a specific data structure
struct DataStructureView: View {
    /// View model for the data structure
    @StateObject private var viewModel: DataStructureViewModel
    
    /// The type of data structure to display
    let type: DataStructureType
    
    /// Text describing the data structure
    let description1: String
    let description2: String
    
    /// Reference to scroll proxy for programmatic scrolling
    let scrollProxy: ScrollViewProxy
    
    /// Spacing between elements in visualizations
    private var elementSpacing: CGFloat {
        #if os(tvOS)
        return 5
        #else
        return 10
        #endif
    }
    
    /// Focus state for buttons
    @FocusState private var isButtonFocused: Bool
    
    /// Initializes a new data structure view
    /// - Parameters:
    ///   - type: Type of data structure to display
    ///   - title: Title for the view
    ///   - description1: Technical description
    ///   - description2: Real-world examples
    ///   - scrollProxy: Proxy for programmatic scrolling
    init(type: DataStructureType, title: String, description1: String, description2: String, scrollProxy: ScrollViewProxy) {
        self.type = type
        self.description1 = description1
        self.description2 = description2
        self.scrollProxy = scrollProxy
        self._viewModel = StateObject(wrappedValue: DataStructureViewModel(type: type))
    }
    
    var body: some View {
        content
            #if os(tvOS)
            .focusSection()
            #endif
            .onChange(of: viewModel.elements.isEmpty) { isEmpty in
                if isEmpty {
                    viewModel.reset()
                }
            }
    }
    
    /// The main content layout for the data structure view
    private var content: some View {
        VStack(spacing: 10) {
            Text(type.displayName)
                .font(.title3)
                .accessibilityAddTraits(.isHeader)
            
            // Three-column layout: description, interactive demo, examples
            HStack(spacing: 10) {
                // Left column: Technical description
                VStack(alignment: .leading, spacing: 10) {
                    Text(description1)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Middle column: Interactive demonstration
                interactiveDemo()
                    .frame(maxWidth: .infinity)
                
                // Right column: Real-world examples
                VStack(alignment: .leading, spacing: 10) {
                    Text(description2)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .interactiveArea()
    }
    
    /// Builds the interactive demonstration for the current data structure type
    @ViewBuilder
    private func interactiveDemo() -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Different visualization based on data structure type
            switch type {
            case .array:
                arrayVisualization()
                
            case .queue:
                queueVisualization()
                
            case .stack:
                stackVisualization()
            }
            
            Spacer()
            
            // Add/Remove control buttons
            controlButtons()
        }
    }
    
    /// Creates a visualization for an array data structure
    private func arrayVisualization() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: elementSpacing) {
                ForEach(viewModel.elements.indices, id: \.self) { index in
                    Text(viewModel.elements[index])
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(8)
                        .transition(.scale)
                        .accessibilityLabel("Array element \(viewModel.elements[index])")
                }
            }
            .animation(.default, value: viewModel.elements)
        }
        .frame(height: 50)
        .accessibilityLabel("Array visualization with \(viewModel.elements.count) elements")
        .focusable()
    }
    
    /// Creates a visualization for a queue data structure
    private func queueVisualization() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: elementSpacing) {
                ForEach(viewModel.elements, id: \.self) { element in
                    Text(element)
                        .padding()
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(8)
                        .transition(.scale)
                        .accessibilityLabel("Queue element \(element)")
                }
            }
            .animation(.default, value: viewModel.elements)
        }
        .frame(height: 50)
        .accessibilityLabel("Queue visualization with \(viewModel.elements.count) elements")
        .focusable()
    }
    
    /// Creates a visualization for a stack data structure
    private func stackVisualization() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: elementSpacing) {
                ForEach(viewModel.elements.reversed(), id: \.self) { element in
                    Text(element)
                        .padding()
                        .background(Color.orange.opacity(0.7))
                        .cornerRadius(8)
                        .transition(.scale)
                        .accessibilityLabel("Stack element \(element)")
                }
            }
            .animation(.default, value: viewModel.elements)
        }
        .frame(height: 200)
        .accessibilityLabel("Stack visualization with \(viewModel.elements.count) elements")
    }
    
    /// Creates the control buttons for manipulating data structures
    private func controlButtons() -> some View {
        HStack(spacing: 20) {
            // Add button
            Button(action: { viewModel.addElement() }) {
                Text("Add")
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .hoverEffect(.highlight)
            .buttonStyle(.plain)
            .focused($isButtonFocused)
            .onChange(of: isButtonFocused) { focused in
                if focused {
                    withAnimation {
                        scrollProxy.scrollTo(type, anchor: .center)
                    }
                }
            }
            .accessibilityHint("Adds a new element to the \(type.displayName.lowercased())")
            
            // Remove button
            Button(action: { viewModel.removeElement() }) {
                Text("Remove")
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .hoverEffect(.highlight)
            .buttonStyle(.plain)
            .focused($isButtonFocused)
            .onChange(of: isButtonFocused) { focused in
                if focused {
                    withAnimation {
                        scrollProxy.scrollTo(type, anchor: .center)
                    }
                }
            }
            .accessibilityHint(viewModel.removalDescription)
        }
    }
}

// MARK: - Main View

/// Main view displaying information about different data structures
struct DataView: View {
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text("Data Structures")
                        .font(.system(size: 60))
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    
                    VStack(spacing: 50) {
                        // Array data structure section
                        DataStructureView(
                            type: .array,
                            title: "Array",
                            description1: """
                            In memory, all the elements in
                            an array are stored in contiguous
                            memory locations, meaning they are
                            next to each other in memory. If we
                            initialise an array, its elements
                            will be allocated sequentially in
                            memory, allowing for efficient
                            access and manipulation of elements
                            """,
                            description2: """
                            Let's say we were trying to create a
                            variable to represent the marks for
                            each student in a class. We could use
                            several normal variables, but this
                            becomes difficult to manage if we
                            have many values to track. The idea of
                            an array is to store many instances
                            in one variable.
                            """,
                            scrollProxy: proxy
                        )
                        .id(DataStructureType.array)
                        .accessibilityLabel("Array data structure section")
                        
                        // Queue data structure section
                        DataStructureView(
                            type: .queue,
                            title: "Queue",
                            description1: """
                            A queue is a linear data structure
                            that follows the First In First Out
                            principle, so the element inserted
                            first is the first to leave.
                            
                            We define a queue to be a list in which
                            all additions are made at one end and all
                            deletions are made at the other.
                            """,
                            description2: """
                            A queue, as the name suggests, is like a line
                            of people waiting to buy an item. The first
                            person to enter the queue is the first
                            person to be able to buy it, and the
                            last in the queue is the last to be able
                            to buy it. There are different types of
                            queues in computing science:
                            • Simple Queue
                            • Double ended Queue
                            • Circular Queue
                            • Priority Queue
                            """,
                            scrollProxy: proxy
                        )
                        .id(DataStructureType.queue)
                        .accessibilityLabel("Queue data structure section")
                        
                        // Stack data structure section
                        DataStructureView(
                            type: .stack,
                            title: "Stack",
                            description1: """
                            A stack is another linear data
                            structure, this time following
                            the Last In First Out principle,
                            meaning the last element inserted
                            is the first element to be removed.
                            """,
                            description2: """
                            Imagine a pile of plates kept on top of
                            each other. The plate which was put on
                            last is the only one we can (safely) access
                            and remove. Since we can only remove the
                            plate that is at the top, we can say that
                            the plate that was put last comes out first.
                            A stack can be fixed size or dynamic. A fixed
                            size stack cannot grow or shrink, and if it
                            gets full, no more can be added to it. A
                            dynamic stack on the other hand changes
                            size when elements are added.
                            """,
                            scrollProxy: proxy
                        )
                        .id(DataStructureType.stack)
                        .accessibilityLabel("Stack data structure section")
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appBackgroundGradient)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    DataView()
}
