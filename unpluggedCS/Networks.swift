//
//  NetworkView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

// MARK: - Main View

/// View that explains computer networks and the OSI model layers
struct NetworkView: View {
    // MARK: Properties
    
     let networkExplanationText: LocalizedStringKey = """
    A computer network is a collection of interconnected devices that share resources and information. These devices can include computers, servers, printers, and other hardware. Networks allow for the efficient exchange of data, enabling various applications for example, email, file sharing, and internet browsing. Think back to what you learned about graphs. A network is a good example of these, its building blocks are nodes and links, where nodes can be any communication device like a router, and links can be either wireless connections between them or physical cables.
    """
    
     let osiModelExplanationText: LocalizedStringKey = """
    The way different computer systems communicate over a network is explained by the Open Systems Interconnection (OSI) model
    consisting of 7 layers each with specific functions and responsibilities:
        \u{2022} Physical Layer
        \u{2022} Data Link Layer
        \u{2022} Network Layer
        \u{2022} Transport Layer
        \u{2022} Session Layer
        \u{2022} Presentation Layer
        \u{2022} Application Layer
    """
    
    // MARK: Body
    
    var body: some View {
        ScrollView{
            VStack {
                Text("Networks")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(networkExplanationText)
                    .padding()
                
                Text(osiModelExplanationText)
                    .accessibilityLabel("OSI Model layers")
                
                Spacer().frame(height: 25)
                
                // Navigation buttons to layer details
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        navigationButton(title: "Physical Layer", destination: PhysicalLayer())
                        navigationButton(title: "Data Link Layer", destination: DataLinkLayer())
                        navigationButton(title: "Network Layer", destination: NetworkLayer())
                        navigationButton(title: "Transport Layer", destination: TransportLayer())
                    }
                    HStack(spacing: 10) {
                        navigationButton(title: "Session Layer", destination: SessionLayer())
                        navigationButton(title: "Presentation Layer", destination: PresentationLayer())
                        navigationButton(title: "Application Layer", destination: ApplicationLayer())
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appBackgroundGradient)
            .foregroundColor(.white)
        }
    }
    
    // MARK: Helper Methods
    
    /// Creates a navigation button with consistent styling
    /// - Parameters:
    ///   - title: The text to display on the button
    ///   - destination: The view to navigate to when tapped
    /// - Returns: A styled NavigationLink
    @ViewBuilder
    func navigationButton<Destination: View>(title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            Text(title)
                .frame(width: 225, height: 100)
                .background(Color.white.opacity(0.3))
                .foregroundStyle(.white)
                .cornerRadius(20)
        }
        .accessibilityHint("Navigate to learn about the \(title)")
    }
}

// MARK: - OSI Layer Views

/// View explaining the Physical Layer (Layer 1) of the OSI model
struct PhysicalLayer: View {
    // MARK: Properties
    
     let explanationText: LocalizedStringKey = """
    The lowest layer of the OSI reference model is the **physical layer**. It is responsible for the actual physical connection between the devices. The physical layer contains information in the form of bits. This layer is responsible for transmitting individual bits from one node to the next. When receiving data, this layer will get the signal received and convert it into 1s and 0s and send them to the Data Link Layer, which will put the *frame* back together. Common physical layer devices are Hubs, Repeaters, Modems, and Cables
    """
    
     let functionsText: LocalizedStringKey = """
    Functions of the Physical Layer: 
        \u{2022} Bit Synchronization - provides synchronization of the bits by providing a clock controlling both the sender and receiver thus synchronizing at the bit level.
        \u{2022} Bit Rate Control - The physical layer defines the transmission rate, i.e. the number of bits sent per second.
        \u{2022} Transmission Mode: Physical layer also defines how the data flows between the two connected devices.
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Layer 1 - Physical Layer")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Spacer().frame(height: 20)
            
            Text(explanationText)
                .padding(.horizontal)
            
            Image("physical")
                .resizable()
                .frame(width: 950, height: 200)
                .colorInvert()
                .accessibilityLabel("Illustration of physical network connections")
            
            Text(functionsText)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

/// View explaining the Data Link Layer (Layer 2) of the OSI model
struct DataLinkLayer: View {
    // MARK: Properties
    
     let layerExplanationText: LocalizedStringKey = """
    The data link layer is responsible for the node-to-node delivery of the message. The main function of this layer is to make sure data transfer is error-free from one node to another, over the physical layer. When a packet arrives in a network, it is the responsibility of the DLL to transmit it to the Host using its MAC address. Packet in the Data Link layer is referred to as Frame. Switches and Bridges are common Data Link Layer devices.
    
    Functions of the Data Link Layer
        \u{2022} Framing: Framing is a function of the data link layer. It provides a way for a sender to transmit a set of bits that are meaningful to the receiver. This can be accomplished by attaching special bit patterns to the beginning and end of the frame.
        \u{2022} Physical Addressing: After creating frames, the Data link layer adds physical addresses (MAC addresses) of the sender and/or receiver in the header of each frame.
        \u{2022} Error Control: The data link layer provides the mechanism of error control in which it detects and retransmits damaged or lost frames.
        \u{2022} Flow Control: The data rate must be constant on both sides else the data may get corrupted thus, flow control coordinates the amount of data that can be sent before receiving an acknowledgment.
        \u{2022} Access Control: When a single communication channel is shared by multiple devices, the MAC sub-layer of the data link layer helps to determine which device has control over the channel at a given time.
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Layer 2 - Data Link Layer")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(layerExplanationText)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

/// View explaining the Network Layer (Layer 3) of the OSI model
struct NetworkLayer: View {
    // MARK: Properties
    
     let layerExplanationText: LocalizedStringKey = """
    The network layer works for the transmission of data from one host to the other in different networks. It also takes care of packet routing, i.e. selecting the shortest path to transmit the packets from the number of available routes. The sender and receiver's IP addresses are placed into the header by the network layer. Segments in the network layer are referred to as **packets**. The network layer is implemented by networking devices such as *routers and switches*
    
    Functions of the Network Layer:
        \u{2022} Routing: The network layer protocols determine which route is suitable from source to destination. This function of the network layer is known as routing. 
        \u{2022} Logical Addressing: To identify each device inter-network uniquely, the network layer defines an addressing scheme. The sender and receiver's IP addresses are placed in the header by the network layer. Such an address distinguishes each device uniquely and universally
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Layer 3 - Network Layer")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(layerExplanationText)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

/// View explaining the Transport Layer (Layer 4) of the OSI model
struct TransportLayer: View {
    // MARK: Properties
    
     let layerExplanationText: LocalizedStringKey = """
    The transport layer provides services to the applications layer and takes services from the network layer. The data in the transport layer is referred to as **segments**. It is responsible for the end-to-end delivery of the complete message. The transport layer also provides the acknowledgements of the successful data transmission and re-transmits the data if an error is found.
    
    At the sender's side, the transport layer receives the formatted data from the upper layers, performs Segmentation, and also implements Flow and error control to ensure proper data transmission. It also adds Source and Destination port number in its header and forwards the segmented data to the Network Layer.
    Functions of the Transport Layer:
        \u{2022} Segmentation and Reassembly: This layer accepts the message from the (session) layer, and breaks the message into smaller units. Each of the segments produced has a header associated with it. The transport layer at the destination station reassembles the message. to destination. This function of the network layer is known as routing. 
        \u{2022} Service Point Addressing: To deliver the message to the correct process, the transport layer header includes a type of address called service point address or port address. Thus by specifying this address, the transport layer makes sure that the message is delivered to the correct process.
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Layer 4 - Transport Layer")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(layerExplanationText)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

/// View explaining the Session Layer (Layer 5) of the OSI model
struct SessionLayer: View {
    // MARK: Properties
    
     let explanationText: LocalizedStringKey = """
    Session Layer in the OSI Model is responsible for the establishment of connections, management of connections, terminations of sessions between two devices. It also provides authentication and security.
    
    Functions of the Session Layer:
        \u{2022} Session Establishment, Maintenance, and Termination: The layer allows the two processes to establish, use, and terminate a connection.
        \u{2022} Synchronization: This layer allows a process to add checkpoints that are considered synchronization points in the data. These synchronization points help to identify the error so that the data is re-synchronized properly, and ends of the messages are not cut prematurely and data loss is avoided.
        \u{2022} Dialog Controller: The session layer allows two systems to start communication with each other in half-duplex or full-duplex.
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Layer 5 - Session Layer")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(explanationText)
                .padding()
            
            Image("session")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 800, height: 200)
                .colorInvert()
                .accessibilityLabel("Illustration of session establishment between devices")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

/// View explaining the Presentation Layer (Layer 6) of the OSI model
struct PresentationLayer: View {
    // MARK: Properties
    
     let layerExplanationText: LocalizedStringKey = """
    The presentation layer is also called the Translation layer. The data from the application layer is extracted here and manipulated as per the required format to transmit over the network. Protocols used in the Presentation Layer are JPEG, MPEG, GIF, TLS/SSL, etc.
    
    Functions of the Presentation Layer:
        \u{2022} Translation: For example, ASCII to EBCDIC.
        \u{2022} Encryption/ Decryption: Data encryption translates the data into another form or code. The encrypted data is known as the ciphertext and the decrypted data is plain text. A key value is used for encrypting as well as decrypting data.
        \u{2022} Compression: Reduces the number of bits that need to be transmitted on the network.
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Layer 6 - Presentation Layer")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(layerExplanationText)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

/// View explaining the Application Layer (Layer 7) of the OSI model
struct ApplicationLayer: View {
    // MARK: Properties
    
     let explanationText: LocalizedStringKey = """
    At the very top of the OSI Reference Model stack of layers, we find the Application layer which is implemented by the network applications. These applications produce the data to be transferred over the network. This layer also serves as a window for the application services to access the network and for displaying the received information to the user. Protocols used in the Application layer are SMTP, FTP, DNS, etc.
    """
    
     let functionsText: LocalizedStringKey = """
    Functions of the Application Layer:
        \u{2022} Network Virtual Terminal(NVT): It allows a user to log on to a remote host.
        \u{2022} File Transfer Access and Management(FTAM): This application allows a user to files in a remote host, retrieve files in a remote host, and manage or control files from a remote computer.
        \u{2022} Mail Services: Provide email service.
        \u{2022} Directory Services: This application provides distributed database sources and access for global information about various objects and services.
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Layer 7 - Application Layer")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            
            Text(explanationText)
                .padding()
            
            Image("Application")
                .resizable()
                .frame(width: 950, height: 200)
                .colorInvert()
                .accessibilityLabel("Illustration of application layer protocols and services")
            
            Text(functionsText)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

// MARK: - Preview Provider

#Preview {
    // Uncomment the desired view to preview
    // NetworkView()
    // PhysicalLayer()
    // DataLinkLayer()
    // NetworkLayer()
    // TransportLayer()
    // SessionLayer()
    // PresentationLayer()
    ApplicationLayer()
}
