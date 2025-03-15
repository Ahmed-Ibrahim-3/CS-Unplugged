//
//  CAView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import MultipeerConnectivity
import UniformTypeIdentifiers

// MARK: - Models

/// Represents the different components of a CPU
enum CPUComponent: String, CaseIterable, Identifiable {
    case controlUnit = "Control Unit"
    case alu = "Arithmetic / Logic Unit"
    case pc = "Program Counter (PC)"
    case cir = "Current Instruction Register (CIR)"
    case ac = "Accumulator (AC)"
    case mar = "Memory Address Register (MAR)"
    case mdr = "Memory Data Register (MDR)"
    case memoryUnit = "Memory Unit"
    
    /// Unique identifier for each component
    var id: String { self.rawValue }
    
    /// Indicates whether the component is a register
    var isRegister: Bool {
        switch self {
        case .pc, .cir, .ac, .mar, .mdr:
            return true
        case .controlUnit, .alu, .memoryUnit:
            return false
        @unknown default:
            return false
        }
    }
}

/// Defines the types of slots available in the CPU building interface
enum CPUSlotType {
    /// Slot for the control unit component
    case controlUnit
    /// Slot for the arithmetic logic unit component
    case alu
    /// Slot for the memory unit component
    case memory
    /// Slot for any register component
    case registerAny
}

/// Represents a slot where CPU components can be placed
struct CPUSlot: Identifiable {
    /// Unique identifier for the slot
    let id = UUID()
    /// Type of component this slot accepts
    let slotType: CPUSlotType
    /// Component currently placed in this slot, if any
    var placedComponent: CPUComponent? = nil
    
    /// Whether the slot has a component placed in it
    var isFilled: Bool {
        placedComponent != nil
    }
}

// MARK: - iOS Implementation

#if os(iOS)
/// View for building a CPU by dragging and dropping components into correct slots
struct CPUBuilderView: View {
    // MARK: Properties
    
    /// User's name displayed in the interface
    public var name: String?
    
    /// Service for handling multipeer connectivity
    @StateObject private var multipeerService: iOSMultipeerServiceCPU
    
    /// Initial configuration of empty slots
    private let initialSlots: [CPUSlot] = [
        CPUSlot(slotType: .controlUnit),
        CPUSlot(slotType: .alu),
        CPUSlot(slotType: .registerAny),
        CPUSlot(slotType: .registerAny),
        CPUSlot(slotType: .registerAny),
        CPUSlot(slotType: .registerAny),
        CPUSlot(slotType: .registerAny),
        CPUSlot(slotType: .memory)
    ]
    
    /// Current state of the CPU slots
    @State private var slots: [CPUSlot]
    
    /// Components available to be placed in slots
    @State private var availableComponents: [CPUComponent]
    
    /// Tracks whether all components are correctly placed
    @State private var allPlacedCorrectly = false
    
    /// Color for the CPU outline, changes to green when complete
    @State private var outlineColour: Color = .white
    
    /// Controls visibility of the multipeer browser
    @State private var showBrowser = false
    
    // MARK: Initialization
    
    /// Initializes the CPU builder view with the user's name
    /// - Parameter name: The user's name, defaults to device name if nil
    init(name: String?) {
        self.name = name ?? UIDevice.current.name
        _slots = State(initialValue: initialSlots)
        _availableComponents = State(initialValue: CPUComponent.allCases.shuffled())
        _multipeerService = StateObject(wrappedValue: iOSMultipeerServiceCPU(username: name!))
    }
    
    // MARK: Body
    
    var body: some View {
        VStack {
            if !multipeerService.isConnected || multipeerService.assignedCoreNumber == nil {
                connectionView
            }
            puzzleView
        }
        .sheet(isPresented: $showBrowser) {
            MCConnectViewCPU(service: multipeerService)
        }
    }
    
    // MARK: Subviews
    
    /// View for connecting to the classroom multi-core CPU
    private var connectionView: some View {
        VStack {
            Text("Connect to classroom")
                .font(.headline)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)
            
            Button("Connect / Browse") {
                showBrowser = true
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue)
            .cornerRadius(8)
            .accessibilityHint("Opens a browser to connect to the classroom CPU")
            
            if let core = multipeerService.assignedCoreNumber {
                Text("Assigned core #\(core). Waiting for connection...")
                    .accessibilityLabel("You are assigned to core number \(core). Waiting for connection.")
            }
            Spacer()
        }
    }
    
    /// Main puzzle view for building the CPU
    private var puzzleView: some View {
        VStack(spacing: 20) {
            if let coreNumber = multipeerService.assignedCoreNumber {
                Text("Connected as Core #\(coreNumber)")
                    .font(.headline)
                    .padding(.top, 5)
                    .accessibilityLabel("You are connected as Core number \(coreNumber)")
            }
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(outlineColour, lineWidth: 2)
                    .background(Color.clear)
                    .overlay {
                        VStack(spacing: 10) {
                            Text("Central Processing Unit")
                                .foregroundColor(outlineColour)
                                .padding(.top, 5)
                                .font(.headline)
                                .accessibilityAddTraits(.isHeader)
                            
                            CPUBuilderRowView(slotBinding: $slots[0], onDropReceived: handleDrop)
                                .padding(.horizontal)
                            
                            CPUBuilderRowView(slotBinding: $slots[1], onDropReceived: handleDrop)
                                .padding(.horizontal)
                            
                            Text("Registers")
                                .foregroundColor(outlineColour)
                                .font(.subheadline)
                                .accessibilityAddTraits(.isHeader)
                            
                            HStack(spacing: 8) {
                                CPUComponentSlotView(slot: $slots[2], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[3], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[4], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[5], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[6], onDropReceived: handleDrop)
                            }
                            .padding(.bottom, 5)
                            .accessibilityLabel("Five register slots for placement")
                        }
                    }
                    .frame(width: 750, height: 300)
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                    Image(systemName: "arrow.up")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                }
                .accessibilityLabel("Bidirectional connection to memory")
                
                CPUBuilderRowView(slotBinding: $slots[7], onDropReceived: handleDrop)
            }
            
            if allPlacedCorrectly {
                Text("All components placed correctly! Great job!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.top)
            } else {
                Text("Drag the components into the correct slots:")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.top, 8)
                    .accessibilityHint("Drag components from below and drop them into matching slots")
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(availableComponents) { component in
                        CPUDraggableComponentView(component: component)
                            .padding(4)
                            .onDrag {
                                NSItemProvider(object: component.rawValue as NSString)
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .accessibilityLabel("Available CPU components to drag")
            
            Button("Reset") {
                resetGame()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.red)
            .cornerRadius(8)
            .padding(.bottom, 10)
            .accessibilityHint("Resets the puzzle to its initial state")
        }
        .interactiveArea()
        .onChange(of: allPlacedCorrectly) { newValue in
            if newValue {
                multipeerService.notifyCoreComplete()
            }
        }
    }
    
    // MARK: Methods
    
    /// Handles component drops onto a slot
    /// - Parameters:
    ///   - componentName: Name of the component being dropped
    ///   - slot: The target slot receiving the component
    private func handleDrop(componentName: String, slot: CPUSlot) {
        guard let droppedComponent = CPUComponent(rawValue: componentName) else { return }
        
        switch slot.slotType {
        case .controlUnit:
            if droppedComponent == .controlUnit {
                fill(slot: slot, with: droppedComponent)
            }
        case .alu:
            if droppedComponent == .alu {
                fill(slot: slot, with: droppedComponent)
            }
        case .memory:
            if droppedComponent == .memoryUnit {
                fill(slot: slot, with: droppedComponent)
            }
        case .registerAny:
            if droppedComponent.isRegister {
                fill(slot: slot, with: droppedComponent)
            }
        }
    }
    
    /// Places a component in a slot and removes it from available components
    /// - Parameters:
    ///   - slot: The slot to fill
    ///   - component: The component to place in the slot
    private func fill(slot: CPUSlot, with component: CPUComponent) {
        if let index = slots.firstIndex(where: { $0.id == slot.id }) {
            slots[index].placedComponent = component
        }
        if let compIndex = availableComponents.firstIndex(of: component) {
            availableComponents.remove(at: compIndex)
        }
        checkIfAllPlaced()
    }
    
    /// Checks if all components are correctly placed
    private func checkIfAllPlaced() {
        let allCorrect = slots.allSatisfy { slot in
            guard let placed = slot.placedComponent else { return false }
            switch slot.slotType {
            case .controlUnit:
                return placed == .controlUnit
            case .alu:
                return placed == .alu
            case .memory:
                return placed == .memoryUnit
            case .registerAny:
                return placed.isRegister
            }
        }
        if allCorrect {
            allPlacedCorrectly = true
            outlineColour = .green
        }
    }
    
    /// Resets the game to its initial state
    private func resetGame() {
        slots = initialSlots
        availableComponents = CPUComponent.allCases.shuffled()
        allPlacedCorrectly = false
        outlineColour = .white
    }
}

// MARK: - Supporting Views (iOS)

/// View for draggable CPU components
struct CPUDraggableComponentView: View {
    /// The CPU component this view represents
    let component: CPUComponent
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.white.opacity(0.15))
            .frame(width: 120, height: 50)
            .overlay {
                Text(component.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(6)
            }
            .accessibilityLabel("\(component.rawValue) component")
    }
}

/// View for a single CPU component slot
struct CPUComponentSlotView: View {
    /// Binding to the slot data
    @Binding var slot: CPUSlot
    
    /// Callback when a component is dropped on this slot
    let onDropReceived: (String, CPUSlot) -> Void
    
    /// Tracks if this slot is currently being targeted for a drop
    @State private var isTargeted: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    slot.isFilled ? Color.green : (isTargeted ? Color.yellow : Color.white),
                    lineWidth: slot.isFilled ? 3 : 1
                )
                .frame(width: 120, height: 50)
                .background(slot.isFilled ? Color.green.opacity(0.2) : Color.clear)
                .overlay {
                    Text(slot.isFilled ? slot.placedComponent?.rawValue ?? "" : "?")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .padding(4)
                }
        }
        .padding(10)
        .contentShape(Rectangle())
        .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
            guard !slot.isFilled else { return false }
        
            if let provider = providers.first {
                provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { data, _ in
                    DispatchQueue.main.async {
                        guard let itemData = data as? Data,
                              let stringValue = String(data: itemData, encoding: .utf8)
                        else { return }
                        
                        onDropReceived(stringValue, slot)
                    }
                }
            }
            return true
        }
        .accessibilityHint(
            slot.isFilled
            ? "Contains \(slot.placedComponent?.rawValue ?? "")"
            : "Empty slot for \(slotTypeDescription(for: slot.slotType))"
        )
    }
    
    /// Provides a description of what type of component belongs in a slot
    /// - Parameter slotType: The type of slot
    /// - Returns: A human-readable description of the slot type
    private func slotTypeDescription(for slotType: CPUSlotType) -> String {
        switch slotType {
        case .controlUnit:
            return "control unit"
        case .alu:
            return "arithmetic logic unit"
        case .memory:
            return "memory unit"
        case .registerAny:
            return "any register"
        }
    }
}

/// View for a row containing a single CPU component slot
struct CPUBuilderRowView: View {
    /// Binding to the slot data
    @Binding var slotBinding: CPUSlot
    
    /// Callback when a component is dropped on this slot
    let onDropReceived: (String, CPUSlot) -> Void
    
    var body: some View {
        HStack {
            Spacer()
            CPUComponentSlotView(slot: $slotBinding, onDropReceived: onDropReceived)
            Spacer()
        }
    }
}

/// View controller for browsing and connecting to multipeer sessions
struct MCConnectViewCPU: UIViewControllerRepresentable {
    /// Service for handling multipeer connectivity
    @ObservedObject var service: iOSMultipeerServiceCPU
    
    func makeUIViewController(context: Context) -> MCBrowserViewController {
        let viewController = MCBrowserViewController(serviceType: kServiceCPU, session: service.session)
        viewController.delegate = service
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MCBrowserViewController, context: Context) {
        // No updates needed
    }
}
#endif

// MARK: - tvOS Implementation

#if os(tvOS)
/// View for displaying the state of all CPU cores in a classroom setting
struct MultiCoreTVOSView: View {
    /// Service for managing connected CPU cores
    @StateObject var service = TVOSMultipeerServiceCPU()
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Multi-Core CPU")
                    .font(.largeTitle)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Number of Cores (devices): \(service.cores.count)")
                    .accessibilityLabel("Number of connected cores: \(service.cores.count)")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(service.cores) { core in
                            VStack {
                                Text("Core #\(core.coreNumber)")
                                    .font(.headline)
                                
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(core.isComplete ? .green : .red, lineWidth: 4)
                                    )
                                    .cornerRadius(8)
                            }
                            .accessibilityLabel(
                                "Core number \(core.coreNumber): \(core.isComplete ? "Complete" : "Incomplete")"
                            )
                        }
                    }
                    .padding()
                }
                
                if service.allCoresReady {
                    Text("All Cores Ready!")
                        .foregroundColor(.green)
                        .font(.system(size: 36, weight: .bold))
                }
                
                Spacer()
            }
            .interactiveArea()
        }
    }
}
#endif

// MARK: - Main View

/// Main view for computer architecture content and interactive elements
struct CAView: View {
    /// User's name to display
    public var name: String
    
    /// Initializes the view with an optional user name
    /// - Parameter name: The user's name, defaults to device name if nil
    init(name: String) {
        self.name = name
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Computer Architecture")
                    .font(.largeTitle)
                    .padding()
                    .accessibilityAddTraits(.isHeader)
                
                HStack(alignment: .top) {
                    Text("""
                        We can break a computer down into four main structural components:
                        • Central Processing Unit (CPU) (the "processor")
                        • Main Memory (RAM)
                        • I/O - Input/Output devices
                        • Some mechanism for communication among them (system bus).
                        
                        Below is a simplified CPU diagram (Control Unit, ALU, and 5 registers).
                        """)
                    .padding()
                    
                    Image("cpu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .padding()
                        .accessibilityLabel("Diagram of CPU showing Control Unit, ALU, and 5 registers")
                }
                
#if os(iOS)
                CPUBuilderView(name: name)
#elseif os(tvOS)
                MultiCoreTVOSView()
                #endif
            }
        }
        .background(appBackgroundGradient)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.white)
    }
}

// MARK: - Preview Provider

#Preview {
    CAView(name: "test")
}
