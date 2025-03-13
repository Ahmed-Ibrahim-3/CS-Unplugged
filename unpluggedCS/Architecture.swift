//
//  CAView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import MultipeerConnectivity
import UniformTypeIdentifiers

enum CPUComponent: String, CaseIterable, Identifiable {
    case controlUnit = "Control Unit"
    case alu = "Arithmetic / Logic Unit"
    
    case pc = "Program Counter (PC)"
    case cir = "Current Instruction Register (CIR)"
    case ac = "Accumulator (AC)"
    case mar = "Memory Address Register (MAR)"
    case mdr = "Memory Data Register (MDR)"
    
    case memoryUnit = "Memory Unit"
    
    var id: String { self.rawValue }
    
    var isRegister: Bool {
        switch self {
        case .pc, .cir, .ac, .mar, .mdr:
            return true
        default:
            return false
        }
    }
}

enum CPUSlotType {
    case controlUnit
    case alu
    case memory
    case registerAny
}

struct CPUSlot: Identifiable {
    let id = UUID()
    let slotType: CPUSlotType
    var placedComponent: CPUComponent? = nil
    var isFilled: Bool {
        placedComponent != nil
    }
}

#if os(iOS)
struct CPUBuilderView: View {
    public var name : String?
    
    @StateObject private var service : iOSMultipeerServiceCPU

    init(name: String?) {
        self.name = name ?? UIDevice.current.name
        _slots = State(initialValue: initialSlots)
        _availableComponents = State(initialValue: CPUComponent.allCases.shuffled())
        _service = StateObject(wrappedValue: iOSMultipeerServiceCPU(username: name!))

    }
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
    
    @State private var slots: [CPUSlot]
    @State private var availableComponents: [CPUComponent]
    @State private var allPlacedCorrectly = false
    @State private var outlineColour: Color = .white
    
    @State private var showBrowser = false
    
    var body: some View {
        VStack {
            if !service.isConnected || service.assignedCoreNumber == nil {
                Text("Connect to classroom Multi-Core CPU")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Button("Connect / Browse") {
                    showBrowser = true
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.blue)
                .cornerRadius(8)
                
                if let core = service.assignedCoreNumber {
                    Text("Assigned core #\(core). Waiting for connection...")
                }
                Spacer()
            }
            puzzleView
        }
        .sheet(isPresented: $showBrowser) {
            MCConnectViewCPU(service: service)
        }
    }
    
    private var puzzleView: some View {
        VStack(spacing: 20) {
            if let coreNumber = service.assignedCoreNumber {
                Text("Connected as Core #\(coreNumber)")
                    .font(.headline)
                    .padding(.top, 5)
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
                            
                            CPUBuilderRowView(slotBinding: $slots[0], onDropReceived: handleDrop)
                                .padding(.horizontal)
                            
                            CPUBuilderRowView(slotBinding: $slots[1], onDropReceived: handleDrop)
                                .padding(.horizontal)
                            
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
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                    Image(systemName: "arrow.up")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                }
                
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
            
            Button("Reset") {
                resetGame()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.red)
            .cornerRadius(8)
            .padding(.bottom, 10)
        }
        .interactiveArea()
        .onChange(of: allPlacedCorrectly) { newValue in
            if newValue {
                service.notifyCoreComplete()
            }
        }
    }
    
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
    
    private func fill(slot: CPUSlot, with component: CPUComponent) {
        if let index = slots.firstIndex(where: { $0.id == slot.id }) {
            slots[index].placedComponent = component
        }
        if let compIndex = availableComponents.firstIndex(of: component) {
            availableComponents.remove(at: compIndex)
        }
        checkIfAllPlaced()
    }
    
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
    
    private func resetGame() {
        slots = initialSlots
        availableComponents = CPUComponent.allCases.shuffled()
        allPlacedCorrectly = false
        outlineColour = .white
    }
}

struct CPUDraggableComponentView: View {
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
    }
}

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
    }
}

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

struct MCConnectViewCPU: UIViewControllerRepresentable {
    @ObservedObject var service: iOSMultipeerServiceCPU
    
    func makeUIViewController(context: Context) -> MCBrowserViewController {
        let vc = MCBrowserViewController(serviceType: kServiceCPU, session: service.session)
        vc.delegate = service
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MCBrowserViewController, context: Context) {
    }
}
#endif

#if os(tvOS)
struct MultiCoreTVOSView: View {
    @StateObject var service = TVOSMultipeerServiceCPU()
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Multi-Core CPU")
                    .font(.largeTitle)
                
                Text("Number of Cores (devices): \(service.cores.count)")
                
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

struct CAView: View {
    public var name : String?
    
    init(name: String?) {
        self.name = name ?? UIDevice.current.name
    }
    var body: some View {
        ScrollView {
            VStack {
                Text("Computer Architecture")
                    .font(.largeTitle)
                    .padding()
                
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
                }
            }
            #if os(iOS)
            CPUBuilderView(name:name)
            #elseif os(tvOS)
            MultiCoreTVOSView()

            #endif
        }
        .background(backgroundGradient)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.white)
    }
}

#Preview {
    CAView(name: "test")
}
