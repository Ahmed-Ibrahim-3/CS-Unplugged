//
//  MPC.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 30/12/2024.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

public let kServiceArt = "tv-art"
public let kServiceCPU = "tv-multi-cpu"

public protocol MPCMessageProtocol: Codable {}

public enum MPCMessageArt: MPCMessageProtocol {
    case pixelArtUpdate(pixels: [Int])
}

public enum MPCMessageCPU: MPCMessageProtocol {
    case requestCore
    case assignCore(coreNumber: Int)
    case coreComplete(coreNumber: Int)
}

#if os(iOS)
public class iOSMultipeerServiceBase<MessageType: MPCMessageProtocol>: NSObject, ObservableObject, MCSessionDelegate, MCBrowserViewControllerDelegate {
    private let myPeerID: MCPeerID
    private var mcSession: MCSession!
    
    @Published public var isConnected = false
    
    public init(serviceName: String, username: String) {
        self.myPeerID = MCPeerID(displayName: username)
        super.init()
        
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    public var session: MCSession {
        mcSession
    }
    
    public func startBrowsing(presentingVC: UIViewController, serviceType: String) {
        let browser = MCBrowserViewController(serviceType: serviceType, session: mcSession)
        browser.delegate = self
        presentingVC.present(browser, animated: true)
    }
    
    public func sendMessage(_ msg: MessageType) {
        guard mcSession.connectedPeers.count > 0 else { return }
        
        do {
            let data = try JSONEncoder().encode(msg)
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("iOS: Error sending message: \(error)")
        }
    }
    
    public func handleReceivedMessage(_ message: MessageType, from peerID: MCPeerID) {
        // do NOT delete
    }
    
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
    
    public func onPeerConnected(_ peerID: MCPeerID) {}
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MessageType.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.handleReceivedMessage(msg, from: peerID)
        }
    }
    
    public func session(_ session: MCSession,
                        didReceive stream: InputStream,
                        withName streamName: String,
                        fromPeer peerID: MCPeerID) {}
    
    public func session(_ session: MCSession,
                        didStartReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        with progress: Progress) {}
    
    public func session(_ session: MCSession,
                        didFinishReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        at localURL: URL?, withError error: Error?) {}
    
    public func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    public func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}

public class iOSMultipeerServiceArt: iOSMultipeerServiceBase<MPCMessageArt> {
    public override init(serviceName: String = kServiceArt, username:String) {
        super.init(serviceName: serviceName, username: username)
    }
    
    public func sendPixelArtUpdate(pixels: [Int]) {
        let msg = MPCMessageArt.pixelArtUpdate(pixels: pixels)
        sendMessage(msg)
    }
    
    public func browseForArtService(presentingVC: UIViewController) {
        startBrowsing(presentingVC: presentingVC, serviceType: kServiceArt)
    }
}

public class iOSMultipeerServiceCPU: iOSMultipeerServiceBase<MPCMessageCPU> {
    @Published public var assignedCoreNumber: Int?
    
    public override init(serviceName: String = kServiceCPU, username:String) {
        super.init(serviceName: serviceName, username: username)
    }
    
    public override func onPeerConnected(_ peerID: MCPeerID) {
        requestCoreFromTV()
    }
    
    public func requestCoreFromTV() {
        let msg = MPCMessageCPU.requestCore
        sendMessage(msg)
    }
    
    public func notifyCoreComplete() {
        guard let coreNum = assignedCoreNumber else { return }
        let msg = MPCMessageCPU.coreComplete(coreNumber: coreNum)
        sendMessage(msg)
    }
    
    public override func handleReceivedMessage(_ message: MPCMessageCPU, from peerID: MCPeerID) {
        switch message {
        case .assignCore(let coreNumber):
            self.assignedCoreNumber = coreNumber
        case .requestCore, .coreComplete:
            break
        }
    }
    
    public func browseForCPUService(presentingVC: UIViewController) {
        startBrowsing(presentingVC: presentingVC, serviceType: kServiceCPU)
    }
}
#endif

#if os(tvOS)
public class TVOSMultipeerServiceBase<MessageType: MPCMessageProtocol>: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    
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
    
    public func sendMessage(_ msg: MessageType, to peer: MCPeerID) {
        do {
            let data = try JSONEncoder().encode(msg)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("tvOS: Error sending message to \(peer.displayName): \(error)")
        }
    }
    
    public func handleReceivedMessage(_ message: MessageType, from peerID: MCPeerID) {
        // do NOT delete
    }
    
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
    
    public func onPeerDisconnected(_ peerID: MCPeerID) {}
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MessageType.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.handleReceivedMessage(msg, from: peerID)
        }
    }
    
    public func session(_ session: MCSession,
                        didReceive stream: InputStream,
                        withName streamName: String,
                        fromPeer peerID: MCPeerID) {}
    
    public func session(_ session: MCSession,
                        didStartReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        with progress: Progress) {}
    
    public func session(_ session: MCSession,
                        didFinishReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        at localURL: URL?, withError error: Error?) {}
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                          didReceiveInvitationFromPeer peerID: MCPeerID,
                          withContext context: Data?,
                          invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

public class TVOSMultipeerServiceArt: TVOSMultipeerServiceBase<MPCMessageArt> {
    @Published public var peerPixelArt: [MCPeerID: [Int]] = [:]
    
    public init() {
        super.init(displayName: "tvOS-Art-Host", serviceType: kServiceArt)
    }
    
    public override func handleReceivedMessage(_ message: MPCMessageArt, from peerID: MCPeerID) {
        switch message {
        case .pixelArtUpdate(let pixels):
            peerPixelArt[peerID] = pixels
        }
    }
    
    public override func onPeerDisconnected(_ peerID: MCPeerID) {
        peerPixelArt.removeValue(forKey: peerID)
    }
}

public struct CoreStatus: Identifiable {
    public let id = UUID()
    public let coreNumber: Int
    public var isComplete: Bool
}

public class TVOSMultipeerServiceCPU: TVOSMultipeerServiceBase<MPCMessageCPU> {
    @Published public var cores: [CoreStatus] = []
    @Published public var allCoresReady = false
    
    public init() {
        super.init(displayName: "tvOS-CPU-Host", serviceType: kServiceCPU)
    }
    
    public override func handleReceivedMessage(_ message: MPCMessageCPU, from peerID: MCPeerID) {
        switch message {
        case .requestCore:
            assignNewCore(to: peerID)
        case .assignCore:
            break // tvOS doesn't handle this message
        case .coreComplete(let coreNumber):
            markCoreComplete(coreNumber)
        }
    }
    
    private func assignNewCore(to peer: MCPeerID) {
        let nextCoreNumber = (cores.map { $0.coreNumber }.max() ?? 0) + 1
        let newCore = CoreStatus(coreNumber: nextCoreNumber, isComplete: false)
        cores.append(newCore)
        
        let message = MPCMessageCPU.assignCore(coreNumber: nextCoreNumber)
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
}
#endif

