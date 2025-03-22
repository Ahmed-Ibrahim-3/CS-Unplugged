//
//  SecurityView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

// MARK: - Supporting Views

/// A reusable view for displaying security topic sections with consistent styling
struct SecurityTopicView: View {
    
    let title: String
    let contentText: LocalizedStringKey
    let imageName: String
    let additionalText: LocalizedStringKey
    
    /// The width constraint for the section
    let width: CGFloat
    /// The preferred height for the image, if specified
    var imageHeight: CGFloat? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(.title2))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
                .focusable()
            
            Text(contentText)
                .multilineTextAlignment(.leading)
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: nil, height: imageHeight)
                .accessibilityLabel("Illustration of \(title.lowercased())")
            
            Text(additionalText)
                .multilineTextAlignment(.leading)
                .focusable()
        }
        .frame(width: width)
    }
}

// MARK: - Main View

/// View that presents information about cybersecurity concepts including firewalls and encryption
struct SecurityView: View {
    // MARK: - Content Definitions
    
    private let firewallsText: LocalizedStringKey = """
    Data is usually split into what we call 'packets' before it is sent across a network. This means something like an image file is not sent as one single file, rather it is split into lots of different packets that can be reassembled to recreate the image once they are received. Firewalls are used to check data packets as they are sent to or received from a system or network. A firewall can be used to:
    \u{2022} check that incoming packets meet specific rules before being allowed in 
    \u{2022} set rules about which **stations** on a network can send or receive packets.
    
    Rules are created to take account of the source and destination addresses, port numbers, and protocols. Firewalls protect by stopping an unauthorised user/system from having any kind of access to a computer system by blocking anything sent from an unauthorised address
    """
    
    private let firewallsAdditionalText: LocalizedStringKey = """
    Firewalls act like security guards for your devices/networks, monitoring all data that tries to enter or leave, making sure everything trying to enter is authorized and not letting it in otherwise. While they are effective, firewalls still have limitations, so we often need more layers of security.
    """
    
    private let encryptionText: LocalizedStringKey = """
    Encryption is a security measure used to try to prevent unauthorised access to data during transmission from one system to another. It is designed to scramble up data so that if an unauthorised person or organisation manages to intercept data packets, they will not be able to read the content
    """
    
    private let encryptionAdditionalText: LocalizedStringKey = """
    Encryption makes use of algorithms to create simple symmetric keys that can encrypt data and keeps this key secure by using public and private keys during transmission of data. Only the correct combination of public and private key will allow access to this key, which is then used again to decrypt the data. 
    
    The origins of encryption start before the use of computers, starting with cryptography - the process of scrambling a message using a *secret key*. For example, the **Caesar Cipher** is a common early key used, in which every letter in the original message is moved forward 3 places - for example, "Hello" becomes "Khoor". This is of course too simple and doesn't provide enough security today, so we use much more complicated algorithms to create keys which can't be as easily figured out
    """
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    Text("Cyber Security")
                        .font(.system(.largeTitle))
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    
                    // Content sections
                    HStack(alignment: .top, spacing: 15) {
                        SecurityTopicView(
                            title: "Firewalls",
                            contentText: firewallsText,
                            imageName: "firewall",
                            additionalText: firewallsAdditionalText,
                            width: geometry.size.width * 0.45,
                            imageHeight: 115
                        )
                        
                        // Encryption section
                        SecurityTopicView(
                            title: "Encryption",
                            contentText: encryptionText,
                            imageName: "Encryption",
                            additionalText: encryptionAdditionalText,
                            width: geometry.size.width * 0.5,
                            imageHeight: 200
                        )
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(appBackgroundGradient)
            .foregroundColor(.white)
        }
    }
}

// MARK: - Preview Provider

#Preview {
    SecurityView()
}
