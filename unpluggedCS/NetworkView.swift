//
//  NetworkView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct NetworkView : View {
    var body : some View{
        Text("Networks")
            .font(.title)
            .padding()
            .multilineTextAlignment(.center)
        
        Text("""
            A computer network is a collection of interconnected devices that share resources and information. These devices can
            includes computers, servers, printers, and other hardware. Networks allow for the efficient exchange of data, enabling
            various applications for example, email, file sharing, and internet browsing. 
            Think back to what you learned about graphs. A network is a good example of these, its building blocks are nodes and links, 
            where nodes can be any communication device like a router, and links can be either wireless connections between them or physical
            cables.
            """
            )
        
        Text("""
            The way different computer systems communicate over a network is explained by the Open Systems Interconnection (OSI) model
            wconsisting of 7 layers each with specific functions and responsibilites:
                \u{2022} Physical Layer
                \u{2022} Data Link Layer
                \u{2022} Network Layer
                \u{2022} Transport Layer
                \u{2022} Session Layer
                \u{2022} Presentation Layer
                \u{2022} Application Layer
            """)
        VStack(spacing:10){
            HStack(spacing:10){
                NavigationLink(destination: PhysicalLayer()){
                    Text("Physical Layer")
                        .frame(width: 225, height: 100)
                }
                NavigationLink(destination: DataLinkLayer()){
                    Text("Data Link Layer")
                        .frame(width: 225, height: 100)
                }
                NavigationLink(destination: NetworkLayer()){
                    Text("Network Layer")
                        .frame(width: 225, height: 100)
                }
                NavigationLink(destination: TransportLayer()){
                    Text("Transport Layer")
                        .frame(width: 225, height: 100)
                }
            }
            HStack(spacing:10){
                NavigationLink(destination: SessionLayer()){
                    Text("Session Layer")
                        .frame(width: 225, height: 100)
                }
                NavigationLink(destination: PresentationLayer()){
                    Text("Presentation Layer")
                        .frame(width: 225, height: 100)
                }
                NavigationLink(destination: ApplicationLayer()){
                    Text("Application Layer")
                        .frame(width: 225, height: 100)
                }
            }
        }
    }
}

#Preview {
    DataLinkLayer()
}

struct PhysicalLayer : View {
    var body: some View {
        Text("Layer 1 - Physical Layer")
            .font(.title)
            .padding()
            .multilineTextAlignment(.center)
        
        Text("""
            The lowest layer of the OSI reference model is the **physical layer**. It is responsible for the actual phsyical connection 
            between the devices. The physical layer contains information in the form of bits. This layer is responsible for transmitting
            individual bits from one node to the next. When receiving data, this layer will get the signal received and convert it into 
            1s and 0s and send them to the Data Link Layer, which will put the *frame* back together. Common physical layer devices are 
            Hubs, Repeaters, Modems, and Cables
            """)
        Image("physical")
            .resizable()
            .frame(width: 1250, height: 225)
            .aspectRatio(contentMode: .fill)
        Text("""
            Functions of the Physical Layer: 
                \u{2022} Bit Synchronisation - provides synchronisation of the bits by providing a clock controlling both the sender and receiver thus 
                synchronising at the but level.
                \u{2022} Bit Rate Control - The physical layer defines the transmission rate, i.e. the number of bits sent per second.
                \u{2022} Transmission Mode: Physical layer also defines how the data flows between the two connected devices.
            """)
    }
}

struct DataLinkLayer : View {
    var body: some View {
        Text("Layer 2 - Data Link Layer")
            .font(.title)
            .padding()
            .multilineTextAlignment(.center)
        
        Text("""
            The data link layer is responsible for the node-to-node delivery of the message. The main function of this layer is to make
            sure data transfer is error-free from one node to another, over the physical layer. When a packet arrives in a network, it
            is the responsibility of the DLL to transmit it to the Host using its MAC address. Packet in the Data Link layer is referred
            to as Frame. Switches and Bridges are common Data Link Layer devices.
            
            Functions of the Data Link Layer
                \u{2022} Framing: Framing is a function of the data link layer. It provides a way for a sender to transmit a set of bits 
                that are meaningful to the receiver. This can be accomplished by attaching special bit patterns to the beginning
                and end of the frame.
                \u{2022} Physical Addressing: After creating frames, the Data link layer adds physical addresses (MAC addresses) of the 
                sender and/or receiver in the header of each frame.
                \u{2022} Error Control: The data link layer provides the mechanism of error control in which it detects and retransmits 
                damaged or lost frames.
                \u{2022} Flow Control: The data rate must be constant on both sides else the data may get corrupted thus, flow control
                coordinates the amount 
                of data that can be sent before receiving an acknowledgment.
                \u{2022} Access Control: When a single communication channel is shared by multiple devices, the MAC sub-layer of the data
                link layer helps to determine which device has control over the channel at a given time.
            """)
    }
}

struct NetworkLayer : View {
    var body: some View {
        Text("Hello, World!")
    }
}
struct TransportLayer : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct SessionLayer : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct PresentationLayer : View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ApplicationLayer : View {
    var body: some View {
        Text("Hello, World!")
    }
}
