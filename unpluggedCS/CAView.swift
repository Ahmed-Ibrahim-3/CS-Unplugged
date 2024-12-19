//
//  CAView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct CAView : View {
    var body : some View{
        VStack{
            Text("Computer Architecture")
                .font(.title)
            
            HStack{
                Text("""
                    We can break a computer down into four main structural components
                    \u{2022} Central Processing Unit (CPU) (often referred to as the **processor**
                    \u{2022} Main Memory (RAM)
                    \u{2022} I/O - Short for Input-Ouput, refers to data moving to or
                        from devices connected to the computer. 
                    \u{2022} Some mechanism for communicating among the other 3 parts, 
                        for example the *system bus*, a number of wires connecting to 
                        all the components
                    Lets zoom in on the cpu and its individual cores 
                    """)
                Image("cpu")
                    .resizable()
                    .frame(width: 350,height: 300)
            }
            Text("""
                \u{2022} **Instruction logic**: This includes the tasks involved in 
                    fetching instructions, and decoding each instruction to determine
                    the operation and the memory locations of its operands
                \u{2022} **Arithmetic and Logic Unit**: Performs the operations 
                    specified by an instructions 
                \u{2022} **Load/Store Logic**: Manages the transfer of data to and 
                    from main memory via the cache.
                """)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}

#Preview{
    CAView()
}
