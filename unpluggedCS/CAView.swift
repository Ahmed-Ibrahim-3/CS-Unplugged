//
//  CAView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import MultipeerConnectivity
import UniformTypeIdentifiers

let serviceName = "tv-multicore"

enum MPCMessage: Codable {
    case requestCore
    case assignCore(coreNumber: Int)
    case coreComplete(coreNumber: Int)
}


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

#if os(tvOS)
import Combine

struct CoreStatus: Identifiable {
    let id = UUID()
    let coreNumber: Int
    var isComplete: Bool
}

class TVOSMultipeerService: NSObject, ObservableObject {
    private let myPeerID = MCPeerID(displayName: "tvOS-Host")
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    
    @Published var cores: [CoreStatus] = []
    @Published var allCoresReady = false
    
    override init() {
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                               discoveryInfo: nil,
                                               serviceType: serviceName)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    private func assignNewCore(to peer: MCPeerID) {
        let nextCoreNumber = (cores.map { $0.coreNumber }.max() ?? 0) + 1
        let newCore = CoreStatus(coreNumber: nextCoreNumber, isComplete: false)
        cores.append(newCore)
        
        let message = MPCMessage.assignCore(coreNumber: nextCoreNumber)
        sendMessage(message, to: peer)
    }
    
    private func markCoreComplete(_ coreNumber: Int) {
        if let index = cores.firstIndex(where: { $0.coreNumber == coreNumber }) {
            cores[index].isComplete = true
            checkAllCoresReady()
        }
    }
    
    private func checkAllCoresReady() {
        allCoresReady = cores.allSatisfy { $0.isComplete } && !cores.isEmpty
    }
    
    private func sendMessage(_ msg: MPCMessage, to peer: MCPeerID) {
        do {
            let data = try JSONEncoder().encode(msg)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("tvOS: Error sending message to \(peer.displayName): \(error)")
        }
    }
}

extension TVOSMultipeerService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("tvOS: Peer connected: \(peerID.displayName)")
        case .connecting:
            print("tvOS: Peer connecting: \(peerID.displayName)")
        case .notConnected:
            print("tvOS: Peer disconnected: \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MPCMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            switch msg {
            case .requestCore:
                self.assignNewCore(to: peerID)
            case .assignCore:
                break
            case .coreComplete(let coreNumber):
                self.markCoreComplete(coreNumber)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension TVOSMultipeerService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

struct MultiCoreTVOSView: View {
    @StateObject var service = TVOSMultipeerService()
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Multi-Core CPU")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                
//                Text("Advertising service: \(serviceName)")
//                    .foregroundColor(.white)
                
                Text("Number of Cores (devices): \(service.cores.count)")
                    .foregroundColor(.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(service.cores) { core in
                            VStack {
                                Text("Core #\(core.coreNumber)")
                                    .foregroundColor(.white)
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
            .padding()
        }
    }
}
#endif


#if os(iOS)

class iOSMultipeerService: NSObject, ObservableObject {
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var mcSession: MCSession!
    private var mcBrowser: MCBrowserViewController!
    
    @Published var assignedCoreNumber: Int?
    @Published var isConnected = false
    
    override init() {
        super.init()
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    var session: MCSession {
        mcSession
    }
    
    func startBrowsing(presentingVC: UIViewController) {
        mcBrowser = MCBrowserViewController(serviceType: serviceName, session: mcSession)
        mcBrowser.delegate = self
        presentingVC.present(mcBrowser, animated: true)
    }
    
    func requestCoreFromTV() {
        let msg = MPCMessage.requestCore
        sendMessage(msg)
    }
    
    func notifyCoreComplete() {
        guard let coreNum = assignedCoreNumber else { return }
        let msg = MPCMessage.coreComplete(coreNumber: coreNum)
        sendMessage(msg)
    }
    
    private func sendMessage(_ msg: MPCMessage) {
        guard mcSession.connectedPeers.count > 0 else { return }
        
        do {
            let data = try JSONEncoder().encode(msg)
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("iOS: Error sending message: \(error)")
        }
    }
}

extension iOSMultipeerService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.isConnected = (state == .connected)
        }
        
        switch state {
        case .connected:
            print("iOS: Connected to \(peerID.displayName)")
            requestCoreFromTV()
        case .connecting:
            print("iOS: Connecting to \(peerID.displayName)...")
        case .notConnected:
            print("iOS: Disconnected from \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MPCMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            switch msg {
            case .requestCore:
                break
            case .assignCore(let coreNumber):
                print("iOS: Assigned core #\(coreNumber)")
                self.assignedCoreNumber = coreNumber
            case .coreComplete:
                break
            }
        }
    }
    
    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {}
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {}
}

extension iOSMultipeerService: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}

struct MCConnectView: UIViewControllerRepresentable {
    @ObservedObject var service: iOSMultipeerService
    
    func makeUIViewController(context: Context) -> MCBrowserViewController {
        let vc = MCBrowserViewController(serviceType: serviceName, session: service.session)
        vc.delegate = service
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MCBrowserViewController, context: Context) {
        // No-op
    }
}


struct CPUBuilderView: View {
    
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
    
    @StateObject private var service = iOSMultipeerService()
    @State private var showBrowser = false
    
    init() {
        _slots = State(initialValue: initialSlots)
        _availableComponents = State(initialValue: CPUComponent.allCases.shuffled())
    }
    
    var body: some View {
        VStack {
            if !service.isConnected || service.assignedCoreNumber == nil {
                Text("Connect to classroom Multi-Core CPU")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Button("Connect / Browse") {
                    showBrowser = true
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.blue)
                .cornerRadius(8)
                
                if let core = service.assignedCoreNumber {
                    Text("Assigned core #\(core). Waiting for connection...")
                        .foregroundColor(.white)
                }
                Spacer()
            }
            puzzleView
        }
        .sheet(isPresented: $showBrowser) {
            MCConnectView(service: service)
        }
    }
    
    private var puzzleView: some View {
        VStack(spacing: 20) {
            if let coreNumber = service.assignedCoreNumber {
                Text("Connected as Core #\(coreNumber)")
                    .foregroundColor(.white)
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
                            
                            CPUBuilderRowView(
                                slotBinding: $slots[0],
                                onDropReceived: handleDrop
                            )
                            .padding(.horizontal)
                            
                            CPUBuilderRowView(
                                slotBinding: $slots[1],
                                onDropReceived: handleDrop
                            )
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
                
                HStack(spacing:4) {
                    Image(systemName: "arrow.down")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                    Image(systemName: "arrow.up")
                        .foregroundColor(outlineColour)
                        .padding(.vertical, 4)
                }
                
                CPUBuilderRowView(
                    slotBinding: $slots[7],
                    onDropReceived: handleDrop
                )
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
                    .foregroundColor(.white)
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
                        .foregroundColor(.white)
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
#endif

struct CAView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Computer Architecture")
                    .font(.largeTitle)
                    .foregroundColor(.white)
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
                    .foregroundColor(.white)
                    .padding()
                    
                    Image("cpu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .padding()
                }
                
                
            }
            #if os(iOS)
            CPUBuilderView()
            #elseif os(tvOS)
            MultiCoreTVOSView()
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
                .padding()
            #else
            Text("Not implemented on this platform.")
                .font(.largeTitle)
            #endif
        }
        .background(backgroundGradient)
        .frame(width: .infinity,height: .infinity)
    }
}

#Preview{
    CAView()
}

