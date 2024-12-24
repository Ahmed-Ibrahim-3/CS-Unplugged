//
//  CAView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - CPUComponent

/// The possible CPU components, each one draggable.
enum CPUComponent: String, CaseIterable, Identifiable {
    // Major CPU sections
    case controlUnit = "Control Unit"
    case alu = "Arithmetic / Logic Unit"
    
    // Registers
    case pc = "Program Counter (PC)"
    case cir = "Current Instruction Register (CIR)"
    case ac = "Accumulator (AC)"
    case mar = "Memory Address Register (MAR)"
    case mdr = "Memory Data Register (MDR)"
    
    // Memory
    case memoryUnit = "Memory Unit"
    
    var id: String { self.rawValue }
    
    /// Helper to see if this component is one of the registers.
    var isRegister: Bool {
        switch self {
        case .pc, .cir, .ac, .mar, .mdr:
            return true
        default:
            return false
        }
    }
}

// MARK: - CPUSlotType

/// The types of slots in our CPU diagram.
enum CPUSlotType {
    case controlUnit
    case alu
    case memory
    case registerAny   // Accepts any of the register components.
}

// MARK: - CPUSlot

/// Represents one “slot” in the diagram, either a specific component or a generic "register" slot.
struct CPUSlot: Identifiable {
    let id = UUID()
    let slotType: CPUSlotType
    
    /// The component that ended up being placed in this slot
    var placedComponent: CPUComponent? = nil
    
    /// Whether the slot has been filled
    var isFilled: Bool {
        placedComponent != nil
    }
}

// MARK: - Draggable Component View

/// A simple view for each draggable CPU component.
struct CPUDraggableComponentView: View {
    let component: CPUComponent
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.white.opacity(0.15))
            .frame(width: 120, height: 50)
            .overlay {
                Text(component.rawValue)
                    .foregroundColor(.white)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(6)
            }
    }
}

// MARK: - CPUComponentSlotView (with expanded hit area)

/// A custom view that visually represents a “slot” for a CPU component and handles the onDrop logic.
/// We add `.padding(...)` and `.contentShape(...)` to expand the interactive region.
struct CPUComponentSlotView: View {
    @Binding var slot: CPUSlot
    let onDropReceived: (String, CPUSlot) -> Void
    
    @State private var isTargeted: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    slot.isFilled ? Color.green : (isTargeted ? Color.yellow : Color.white),
                    lineWidth: slot.isFilled ? 3 : 1
                )
                .frame(width: 120, height: 50)
                .background(
                    slot.isFilled ? Color.green.opacity(0.2) : Color.clear
                )
                .overlay {
                    // If the slot is not filled, show "?"
                    // If filled, show the placed component's name
                    Text(slot.isFilled ? slot.placedComponent?.rawValue ?? "" : "?")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(4)
                }
        }
        // Increase the drop target area by adding padding
        .padding(10)
        // Make the entire padded area count as the drop shape
        .contentShape(Rectangle())
        .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
            // If this slot is already filled, ignore
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
    }
}

// MARK: - Interactive CPU Builder

struct CPUBuilderView: View {
    
    // We'll define the initial state as constants, so we can easily reset them later.
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
    
    // We keep them in @State, so the UI reacts to changes.
    @State private var slots: [CPUSlot]
    @State private var availableComponents: [CPUComponent]
    @State private var allPlacedCorrectly = false
    @State private var outlineColour: Color = .white
    
    // We define an init so we can shuffle the initial components.
    init() {
        _slots = State(initialValue: initialSlots)
        _availableComponents = State(initialValue: CPUComponent.allCases.shuffled())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // CPU Box + Memory Layout
            VStack(spacing: 0) {
                // CPU Box Outline (wider for clarity)
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(outlineColour, lineWidth: 2)
                    .background(Color.clear)
                    .overlay {
                        VStack(spacing: 10) {
                            // "Central Processing Unit" label at the top
                            Text("Central Processing Unit")
                                .foregroundColor(outlineColour)
                                .padding(.top, 5)
                                .font(.headline)
                            
                            // Control Unit Slot (slots[0])
                            CPUBuilderRowView(
                                slotBinding: $slots[0],
                                onDropReceived: handleDrop
                            )
                            .padding(.horizontal)
                            
                            // ALU Slot (slots[1])
                            CPUBuilderRowView(
                                slotBinding: $slots[1],
                                onDropReceived: handleDrop
                            )
                            .padding(.horizontal)
                            
                            // Registers row
                            Text("Registers")
                                .foregroundColor(outlineColour)
                                .font(.subheadline)
                            
                            HStack(spacing: 8) {
                                CPUComponentSlotView(slot: $slots[2], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[3], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[4], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[5], onDropReceived: handleDrop)
                                CPUComponentSlotView(slot: $slots[6], onDropReceived: handleDrop)
                            }
                            .padding(.bottom, 5)
                        }
                    }
                    .frame(width: 750, height: 300)
                
                // Arrow from CPU to Memory
                HStack(spacing:4) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                    Image(systemName: "arrow.up")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                }
                
                // Memory Unit Slot (slots[7])
                CPUBuilderRowView(
                    slotBinding: $slots[7],
                    onDropReceived: handleDrop
                )
            }
            
            // Success message
            if allPlacedCorrectly {
                Text("All components placed correctly! Great job!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.top)
            }
            
            // Draggable components area
            if !allPlacedCorrectly {
                Text("Drag the components into the correct slots:")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.top, 8)
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
            
            // MARK: - Reset Button
            Button("Reset") {
                resetGame()
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.red)
            .cornerRadius(8)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding([.leading, .trailing], 10)
    }
    
    // MARK: - Drop Handling
    
    private func handleDrop(componentName: String, slot: CPUSlot) {
        guard let droppedComponent = CPUComponent(rawValue: componentName) else { return }
        
        // Figure out if it matches the slot rules:
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
            // Accept any register
            if droppedComponent.isRegister {
                fill(slot: slot, with: droppedComponent)
            }
        }
    }
    
    /// If valid, mark the slot as filled and remove the component from the draggable list.
    private func fill(slot: CPUSlot, with component: CPUComponent) {
        if let index = slots.firstIndex(where: { $0.id == slot.id }) {
            slots[index].placedComponent = component
        }
        if let compIndex = availableComponents.firstIndex(of: component) {
            availableComponents.remove(at: compIndex)
        }
        checkIfAllPlaced()
    }
    
    /// Checks if all slots have been correctly placed, then sets `allPlacedCorrectly`.
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
    
    /// Resets the game to its initial state: slots are empty, components are shuffled, and no success message.
    private func resetGame() {
        slots = initialSlots
        availableComponents = CPUComponent.allCases.shuffled()
        allPlacedCorrectly = false
        outlineColour = .white
    }
}

// MARK: - CPUBuilderRowView

/// A row with just a slot in the center.
struct CPUBuilderRowView: View {
    @Binding var slotBinding: CPUSlot
    let onDropReceived: (String, CPUSlot) -> Void
    
    var body: some View {
        HStack {
            Spacer()
            CPUComponentSlotView(slot: $slotBinding, onDropReceived: onDropReceived)
            Spacer()
        }
    }
}

// MARK: - Integrated CAView

struct CAView: View {
    var body: some View {
        ScrollView {
            VStack {
                // Basic introduction
                Text("Computer Architecture")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                HStack(alignment: .top) {
                    Text("""
                         We can break a computer down into four main structural components:
                         • Central Processing Unit (CPU) (often referred to as the **processor**)
                         • Main Memory (RAM)
                         • I/O - Short for Input-Output, refers to data moving to or from devices.
                         • Some mechanism for communicating among the other 3 parts (e.g., a system bus).
                         
                         Below is a simplified CPU diagram with Control Unit, ALU, and five registers (PC, CIR, AC, MAR, MDR).
                         Now you can place the registers **in any order** you like, as long as they go into the 5 Register slots.
                         The row below shows the components in a random order each time, and you can reset at any time!
                         """)
                    .foregroundColor(.white)
                    .padding(.leading)
                    
                    Image("cpu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .padding(.trailing)
                }
                
                Text("""
                     • **Instruction logic**: Responsible for fetching instructions, decoding them, and determining the memory locations of operands.
                     • **Arithmetic and Logic Unit**: Performs operations specified by an instruction.
                     • **Load/Store logic**: Manages data transfer between main memory and CPU registers.
                     """)
                .foregroundColor(.white)
                .padding(.all)
                Text("Now, Let's build a CPU!").foregroundColor(.white).font(.title2)
                
                // Integrated CPU builder (with multiple register slots accepting any register)
                CPUBuilderView()
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}

#Preview {
    CAView()
}
