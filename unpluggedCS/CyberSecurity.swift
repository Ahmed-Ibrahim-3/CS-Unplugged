//
//  SecurityView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct SecurityView : View {
    var body : some View{
        GeometryReader{ geometry in
            VStack{
                Text("Cyber Security")
                    .font(.system(.largeTitle))
                    .multilineTextAlignment(.center)
                    .padding()
                HStack(spacing:5){
                    VStack(spacing:10){
                        Text("Firewalls")
                            .font(.system(.title2))
                        Text("""
                    Data is usually split into what we call 'packets' before it is sent across a network. This means something like an image file is not sent as one single file, rather it is split into lots of different packets that can be reassembled to recreate the image once they are received. Firewalls are used to check data packets as they are sent to or received from a system or network. A firewall can be used to:
                    \u{2022}check that incoming packets meet specific rules before being allowed in 
                    \u{2022}set rules about which **stations** on a network can send or receive packets.
                    Rules are created to take account of the source and destination addresses, port numbers, and protocols. Firewalls protect by stopping an unauthorised user/system from having any kind of access to a computer system by blocking anything sent from an unauthorised address
                    """)
                        Image("firewall")
                            .resizable()
                            .frame(width: 500,height: 115)
                            .scaledToFit()
                        Text("""
                        Firewalls act like security guards for your devices/networks, monitoring all data that tries to enter or leave, makiing sure everything trying to enter is authorisd and not letting it in otherwise. While they are effectinve, firewalls still have limitations, so we often need more layers of security.
                        """)
                    }
                    
                    .frame(width: geometry.size.width * 0.45)
                    
                    VStack(spacing:10){
                        Text("Encryption")
                            .font(.system(.title2))
                            .foregroundColor(.white)
                        Text("""
                    Encryption is a security measure used to try to prevent unauthorised access to data during transmission from one system to another. It is designed to scramble up data so that if an unauthorised person or organisation manages to intercept data packets, they will not be able to read the content
                    """)
                        Image("Encryption")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                        Text("""
                    Encryption makes use of algorithms to create simple symmetric keys that can encrypt data and keeps this key secure by using public and private keys during transmission of data. Only the correct combination of public and private key will allow access to this key, which is then used again to decrypt the data. 
                    The origins of encryption start before the use of computers, starting with cyrptography - the process of scrambling a message using a *secret key*. For example, the **Caeser Cipher** is a common early key used, in which every letter in the original message is moved forward 3 places - for example, "Hello" becomes "Khoor". This is of course too simple and doesnt provide enough security today, so we use much more complicated alogithms to create keys which can't be as easily figures out
                    """)
                    }
                    .frame(width: geometry.size.width * 0.5)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    SecurityView()
}
