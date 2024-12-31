//
//  MPC.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 30/12/2024.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

public let serviceName = "tv-art"

public enum MPCMessage: Codable {
    case pixelArtUpdate(pixels: [Int])
}

#if os(iOS)
public class iOSMultipeerService: NSObject, ObservableObject {
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var mcSession: MCSession!
    private var mcBrowser: MCBrowserViewController!
    
    @Published public var isConnected = false
    
    override public init() {
        super.init()
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    public var session: MCSession {
        mcSession
    }
    
    public func startBrowsing(presentingVC: UIViewController) {
        mcBrowser = MCBrowserViewController(serviceType: serviceName, session: mcSession)
        mcBrowser.delegate = self
        presentingVC.present(mcBrowser, animated: true)
    }
    
    public func sendPixelArtUpdate(pixels: [Int]) {
        guard mcSession.connectedPeers.count > 0 else { return }
        let msg = MPCMessage.pixelArtUpdate(pixels: pixels)
        
        do {
            let data = try JSONEncoder().encode(msg)
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("iOS: Error sending pixelArtUpdate: \(error)")
        }
    }
}

extension iOSMultipeerService: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.isConnected = (state == .connected)
        }
        
        switch state {
        case .connected:
            print("iOS: Connected to \(peerID.displayName)")
        case .connecting:
            print("iOS: Connecting to \(peerID.displayName)...")
        case .notConnected:
            print("iOS: Disconnected from \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MPCMessage.self, from: data) else { return }
        switch msg {
        case .pixelArtUpdate(_):
            break
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
}

extension iOSMultipeerService: MCBrowserViewControllerDelegate {
    public func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    public func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}
#endif

#if os(tvOS)
public class TVOSMultipeerService: NSObject, ObservableObject {
    private let myPeerID = MCPeerID(displayName: "tvOS-Host")
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    
    @Published public var peerPixelArt: [MCPeerID: [Int]] = [:]
    
    override public init() {
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                               discoveryInfo: nil,
                                               serviceType: serviceName)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    private func handlePixelArtUpdate(from peer: MCPeerID, pixels: [Int]) {
        peerPixelArt[peer] = pixels
    }
}

extension TVOSMultipeerService: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
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
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MPCMessage.self, from: data) else { return }
        switch msg {
        case .pixelArtUpdate(let pixels):
            DispatchQueue.main.async {
                self.handlePixelArtUpdate(from: peerID, pixels: pixels)
            }
        }
    }
    
    public func session(_ session: MCSession,
                        didReceive stream: InputStream,
                        withName streamName: String,
                        fromPeer peerID: MCPeerID) {}
    public func session(_ session: MCSession,
                        didStartReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID, with progress: Progress) {}
    public func session(_ session: MCSession,
                        didFinishReceivingResourceWithName resourceName: String,
                        fromPeer peerID: MCPeerID,
                        at localURL: URL?, withError error: Error?) {}
}

extension TVOSMultipeerService: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                           didReceiveInvitationFromPeer peerID: MCPeerID,
                           withContext context: Data?,
                           invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
#endif

public let serviceNameCPU = "tv-multi-cpu"

public enum MPCMessageCPU: Codable {
    case requestCore
    case assignCore(coreNumber: Int)
    case coreComplete(coreNumber: Int)
}

#if os(iOS)
public class iOSMultipeerServiceCPU: NSObject, ObservableObject {
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var mcSession: MCSession!
    private var mcBrowser: MCBrowserViewController!
    
    @Published public var assignedCoreNumber: Int?
    @Published public var isConnected = false
    
    override public init() {
        super.init()
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    public var session: MCSession {
        mcSession
    }
    
    public func startBrowsing(presentingVC: UIViewController) {
        mcBrowser = MCBrowserViewController(serviceType: serviceNameCPU, session: mcSession)
        mcBrowser.delegate = self
        presentingVC.present(mcBrowser, animated: true)
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
    
    private func sendMessage(_ msg: MPCMessageCPU) {
        guard mcSession.connectedPeers.count > 0 else { return }
        do {
            let data = try JSONEncoder().encode(msg)
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("iOS-CPU: Error sending message: \(error)")
        }
    }
}

extension iOSMultipeerServiceCPU: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.isConnected = (state == .connected)
        }
        
        switch state {
        case .connected:
            print("iOS-CPU: Connected to \(peerID.displayName)")
            requestCoreFromTV()
        case .connecting:
            print("iOS-CPU: Connecting to \(peerID.displayName)...")
        case .notConnected:
            print("iOS-CPU: Disconnected from \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    public func session(_ session: MCSession,
                        didReceive data: Data,
                        fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MPCMessageCPU.self, from: data) else { return }
        DispatchQueue.main.async {
            switch msg {
            case .requestCore:
                break
            case .assignCore(let coreNumber):
                self.assignedCoreNumber = coreNumber
            case .coreComplete:
                break
            }
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
}

extension iOSMultipeerServiceCPU: MCBrowserViewControllerDelegate {
    public func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    public func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}
#endif

#if os(tvOS)
public struct CoreStatus: Identifiable {
    public let id = UUID()
    public let coreNumber: Int
    public var isComplete: Bool
}

public class TVOSMultipeerServiceCPU: NSObject, ObservableObject {
    private let myPeerID = MCPeerID(displayName: "tvOS-CPU-Host")
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    
    @Published public var cores: [CoreStatus] = []
    @Published public var allCoresReady = false
    
    override public init() {
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                               discoveryInfo: nil,
                                               serviceType: serviceNameCPU)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
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
    
    private func sendMessage(_ msg: MPCMessageCPU, to peer: MCPeerID) {
        do {
            let data = try JSONEncoder().encode(msg)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("tvOS-CPU: Error sending message to \(peer.displayName): \(error)")
        }
    }
}

extension TVOSMultipeerServiceCPU: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("tvOS-CPU: Peer connected: \(peerID.displayName)")
        case .connecting:
            print("tvOS-CPU: Peer connecting: \(peerID.displayName)")
        case .notConnected:
            print("tvOS-CPU: Peer disconnected: \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let msg = try? JSONDecoder().decode(MPCMessageCPU.self, from: data) else { return }
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
}

extension TVOSMultipeerServiceCPU: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                           didReceiveInvitationFromPeer peerID: MCPeerID,
                           withContext context: Data?,
                           invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
#endif 
