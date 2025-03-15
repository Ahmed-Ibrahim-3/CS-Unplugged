//
//  MPC.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 30/12/2024.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

// MARK: - Constants and Protocols

/// Service type identifiers
public let kServiceArt = "tv-art"
public let kServiceCPU = "tv-multi-cpu"

/// Protocol that all multipeer communication messages must conform to
public protocol MPCMessageProtocol: Codable {}

/// Messages used for the pixel art sharing feature
public enum MPCMessageArt: MPCMessageProtocol {
    /// Message sent when a user updates their pixel art
    /// - Parameter pixels: Array of integer values representing the pixel colors
    case pixelArtUpdate(pixels: [Int])
}

/// Messages used for the multi-core CPU simulation feature
public enum MPCMessageCPU: MPCMessageProtocol {
    /// Message sent from an iOS device to request assignment to a CPU core
    case requestCore
    
    /// Message sent from tvOS to assign a specific core number to an iOS device
    case assignCore(coreNumber: Int)
    
    /// Message sent from iOS to notify that a core has completed its task
    case coreComplete(coreNumber: Int)
}

// MARK: - iOS Implementation

#if os(iOS)
/// Base class for iOS multipeer connectivity services - Handles session management, peer discovery, and message sending/receiving
public class iOSMultipeerServiceBase<MessageType: MPCMessageProtocol>: NSObject, ObservableObject, MCSessionDelegate, MCBrowserViewControllerDelegate {
    // MARK: Properties
    
    /// The peer ID representing this device
    private let myPeerID: MCPeerID
    
    /// The multipeer session for communication
    private var mcSession: MCSession!
    
    /// Indicates whether the device is connected to a peer
    @Published public var isConnected = false
    
    // MARK: Initialization
    
    /// Initializes the multipeer service with a service name and username
    /// - Parameters:
    ///   - serviceName: The type of service to advertise
    ///   - username: The display name for this device in the multipeer session
    public init(serviceName: String, username: String) {
        self.myPeerID = MCPeerID(displayName: username)
        super.init()
        
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    // MARK: Public Methods
    
    /// Access to the underlying MCSession
    public var session: MCSession { mcSession }
    
    /// Starts browsing for peers advertising the specified service type
    /// - Parameters:
    ///   - presentingVC: The view controller that will present the browser interface
    ///   - serviceType: The type of service to browse for
    public func startBrowsing(presentingVC: UIViewController, serviceType: String) {
        let browser = MCBrowserViewController(serviceType: serviceType, session: mcSession)
        browser.delegate = self
        presentingVC.present(browser, animated: true)
    }
    
    /// Sends a message to all connected peers
    /// - Parameter msg: The message to send
    public func sendMessage(_ msg: MessageType) {
        guard mcSession.connectedPeers.count > 0 else { return }
        
        do {
            let data = try JSONEncoder().encode(msg)
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("iOS: Error sending message: \(error)")
        }
    }
    
    /// Handles received messages from peers.
    public func handleReceivedMessage(_ message: MessageType, from peerID: MCPeerID) {
        // Base implementation is empty. Do Not Delete
    }
    
    /// Called when a peer connects to the session.
    public func onPeerConnected(_ peerID: MCPeerID) {
        // Base implementation is empty. Do Not Delete
    }
    
    // MARK: MCSessionDelegate Methods
    
    /// Called when a peer's connection state changes
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.isConnected = (state == .connected)
        }
        
        switch state {
        case .connected:
            print("iOS: Connected to \(peerID.displayName)")
            self.onPeerConnected(peerID)
        case .connecting:
            print("iOS: Connecting to \(peerID.displayName)...")
        case .notConnected:
            print("iOS: Disconnected from \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    /// Called when data is received from a peer
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MessageType.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.handleReceivedMessage(msg, from: peerID)
        }
    }
    
    /// Called when a stream is received from a peer (not used in this implementation)
    public func session(_ session: MCSession,
                        didReceive stream: InputStream,
                        withName streamName: String,
                        fromPeer peerID: MCPeerID) {}
    
    /// Called when a resource transfer starts (not used in this implementation)
    public func session(_ session: MCSession,
                        didStartReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        with progress: Progress) {}
    
    /// Called when a resource transfer finishes (not used in this implementation)
    public func session(_ session: MCSession,
                        didFinishReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        at localURL: URL?, withError error: Error?) {}
    
    // MARK: MCBrowserViewControllerDelegate Methods
    
    /// Called when the browser view controller finishes
    public func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    /// Called when the browser view controller is cancelled
    public func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}

/// Specialized multipeer service for the pixel art sharing feature on iOS
public class iOSMultipeerServiceArt: iOSMultipeerServiceBase<MPCMessageArt> {
    /// Initializes the pixel art service with the default service name and specified username
    /// - Parameter username: The display name for this device in the multipeer session
    public override init(serviceName: String = kServiceArt, username: String) {
        super.init(serviceName: serviceName, username: username)
    }
    
    /// Sends an update of the pixel art to all connected peers
    /// - Parameter pixels: Array of integer values representing the pixel colors
    public func sendPixelArtUpdate(pixels: [Int]) {
        let msg = MPCMessageArt.pixelArtUpdate(pixels: pixels)
        sendMessage(msg)
    }
    
    /// Starts browsing for pixel art services
    /// - Parameter presentingVC: The view controller that will present the browser interface
    public func browseForArtService(presentingVC: UIViewController) {
        startBrowsing(presentingVC: presentingVC, serviceType: kServiceArt)
    }
}

/// Specialized multipeer service for the multi-core CPU simulation feature on iOS
public class iOSMultipeerServiceCPU: iOSMultipeerServiceBase<MPCMessageCPU> {
    /// The core number assigned to this device by the tvOS host
    @Published public var assignedCoreNumber: Int?
    
    /// Initializes the CPU service with the default service name and specified username
    /// - Parameter username: The display name for this device in the multipeer session
    public override init(serviceName: String = kServiceCPU, username: String) {
        super.init(serviceName: serviceName, username: username)
    }
    
    /// Called when a peer connects - automatically requests a core assignment
    public override func onPeerConnected(_ peerID: MCPeerID) {
        requestCoreFromTV()
    }
    
    /// Sends a request to the tvOS host for core assignment
    public func requestCoreFromTV() {
        let msg = MPCMessageCPU.requestCore
        sendMessage(msg)
    }
    
    /// Notifies the tvOS host that this core has completed its task
    public func notifyCoreComplete() {
        guard let coreNum = assignedCoreNumber else { return }
        let msg = MPCMessageCPU.coreComplete(coreNumber: coreNum)
        sendMessage(msg)
    }
    
    /// Handles messages received from the tvOS host
    /// - Parameters:
    ///   - message: The received message
    ///   - peerID: The peer that sent the message
    public override func handleReceivedMessage(_ message: MPCMessageCPU, from peerID: MCPeerID) {
        switch message {
        case .assignCore(let coreNumber):
            self.assignedCoreNumber = coreNumber
        case .requestCore, .coreComplete:
            // These messages are sent by iOS, not received
            break
        }
    }
    
    /// Starts browsing for CPU services
    /// - Parameter presentingVC: The view controller that will present the browser interface
    public func browseForCPUService(presentingVC: UIViewController) {
        startBrowsing(presentingVC: presentingVC, serviceType: kServiceCPU)
    }
}
#endif

// MARK: - tvOS Implementation

#if os(tvOS)
/// Base class for tvOS multipeer connectivity services. Handles session management, service advertising, and message sending/receiving
public class TVOSMultipeerServiceBase<MessageType: MPCMessageProtocol>: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    // MARK: Properties
    
    /// The peer ID representing this device
    private let myPeerID: MCPeerID
    
    /// The multipeer session for communication
    private var session: MCSession!
    
    /// The advertiser that makes this service discoverable by iOS devices
    private var advertiser: MCNearbyServiceAdvertiser!
    
    // MARK: Initialization
    
    /// Initializes the multipeer service with a display name and service type
    /// - Parameters:
    ///   - displayName: The display name for this device in the multipeer session
    ///   - serviceType: The type of service to advertise
    public init(displayName: String, serviceType: String) {
        self.myPeerID = MCPeerID(displayName: displayName)
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                              discoveryInfo: nil,
                                              serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    // MARK: Public Methods
    
    /// Sends a message to a specific peer
    /// - Parameters:
    ///   - msg: The message to send
    ///   - peer: The peer to send the message to
    public func sendMessage(_ msg: MessageType, to peer: MCPeerID) {
        do {
            let data = try JSONEncoder().encode(msg)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("tvOS: Error sending message to \(peer.displayName): \(error)")
        }
    }
    
    /// Handles received messages from peers.
    public func handleReceivedMessage(_ message: MessageType, from peerID: MCPeerID) {
        // Base implementation is empty.
    }
    
    /// Called when a peer disconnects from the session
    public func onPeerDisconnected(_ peerID: MCPeerID) {
        // Base implementation is empty.
    }
    
    // MARK: MCSessionDelegate Methods
    
    /// Called when a peer's connection state changes
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("tvOS: Peer connected: \(peerID.displayName)")
        case .connecting:
            print("tvOS: Peer connecting: \(peerID.displayName)")
        case .notConnected:
            print("tvOS: Peer disconnected: \(peerID.displayName)")
            self.onPeerDisconnected(peerID)
        @unknown default:
            break
        }
    }
    
    /// Called when data is received from a peer
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MessageType.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.handleReceivedMessage(msg, from: peerID)
        }
    }
    
    /// Called when a stream is received from a peer (not used in this implementation)
    public func session(_ session: MCSession,
                        didReceive stream: InputStream,
                        withName streamName: String,
                        fromPeer peerID: MCPeerID) {}
    
    /// Called when a resource transfer starts (not used in this implementation)
    public func session(_ session: MCSession,
                        didStartReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        with progress: Progress) {}
    
    /// Called when a resource transfer finishes (not used in this implementation)
    public func session(_ session: MCSession,
                        didFinishReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        at localURL: URL?, withError error: Error?) {}
    
    // MARK: MCNearbyServiceAdvertiserDelegate Methods
    
    /// Called when an invitation is received from a peer
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                          didReceiveInvitationFromPeer peerID: MCPeerID,
                          withContext context: Data?,
                          invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Automatically accept all incoming invitations
        invitationHandler(true, session)
    }
}

/// Specialized multipeer service for the pixel art sharing feature on tvOS
public class TVOSMultipeerServiceArt: TVOSMultipeerServiceBase<MPCMessageArt> {
    /// Dictionary mapping connected peers to their pixel art data
    @Published public var peerPixelArt: [MCPeerID: [Int]] = [:]
    
    /// Initializes the pixel art service with the default display name and service type
    public init() {
        super.init(displayName: "Art-Host", serviceType: kServiceArt)
    }
    
    /// Handles pixel art update messages from iOS devices
    /// - Parameters:
    ///   - message: The received message
    ///   - peerID: The peer that sent the message
    public override func handleReceivedMessage(_ message: MPCMessageArt, from peerID: MCPeerID) {
        switch message {
        case .pixelArtUpdate(let pixels):
            peerPixelArt[peerID] = pixels
        }
    }
    
    /// Removes a peer's pixel art when they disconnect
    /// - Parameter peerID: The peer that disconnected
    public override func onPeerDisconnected(_ peerID: MCPeerID) {
        peerPixelArt.removeValue(forKey: peerID)
    }
}

/// Represents the status of a CPU core in the multi-core simulation
public struct CoreStatus: Identifiable {
    /// Unique identifier for the core
    public let id = UUID()
    
    /// The assigned core number
    public let coreNumber: Int
    
    /// Whether the core has completed its task
    public var isComplete: Bool
}

/// Specialized multipeer service for the multi-core CPU simulation feature on tvOS
public class TVOSMultipeerServiceCPU: TVOSMultipeerServiceBase<MPCMessageCPU> {
    /// Array of core statuses representing connected iOS devices
    @Published public var cores: [CoreStatus] = []
    
    /// Whether all connected cores have completed their tasks
    @Published public var allCoresReady = false
    
    /// Initializes the CPU service with the default display name and service type
    public init() {
        super.init(displayName: "CPU-Host", serviceType: kServiceCPU)
    }
    
    /// Handles CPU-related messages from iOS devices
    /// - Parameters:
    ///   - message: The received message
    ///   - peerID: The peer that sent the message
    public override func handleReceivedMessage(_ message: MPCMessageCPU, from peerID: MCPeerID) {
        switch message {
        case .requestCore:
            assignNewCore(to: peerID)
        case .assignCore:
            // tvOS doesn't handle this message - it's sent from tvOS to iOS
            break
        case .coreComplete(let coreNumber):
            markCoreComplete(coreNumber)
        }
    }
    
    /// Removes the last core when a peer disconnects
    /// - Parameter peerID: The peer that disconnected
    public override func onPeerDisconnected(_ peerID: MCPeerID) {
        cores.popLast()
    }
    
    /// Assigns a new core number to a connected iOS device
    /// - Parameter peer: The peer to assign a core to
    private func assignNewCore(to peer: MCPeerID) {
        let nextCoreNumber = (cores.map { $0.coreNumber }.max() ?? 0) + 1
        let newCore = CoreStatus(coreNumber: nextCoreNumber, isComplete: false)
        cores.append(newCore)
        
        let message = MPCMessageCPU.assignCore(coreNumber: nextCoreNumber)
        sendMessage(message, to: peer)
    }
    
    /// Marks a core as having completed its task
    /// - Parameter coreNumber: The core number that completed
    private func markCoreComplete(_ coreNumber: Int) {
        if let index = cores.firstIndex(where: { $0.coreNumber == coreNumber }) {
            cores[index].isComplete = true
            checkAllCoresReady()
        }
    }
    
    /// Checks if all cores have completed their tasks
    private func checkAllCoresReady() {
        allCoresReady = cores.allSatisfy { $0.isComplete } && !cores.isEmpty
    }
}
#endif
