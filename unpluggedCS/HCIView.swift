//
//  HCIView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct HCIView : View {
    var body : some View{
        VStack{
            Text("Human-Computer Interaction")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Text("""
                    Human Computer interaction is about designing, evaluating, and implementing computer sytems in a way that lets people
                    use them productively and safely. Since computers are so common now, and are everyday tools that everyone uses, as computer
                    scientists we need to pay attention to the human interface of both hardware and software.
                
                    Consider the doors below...
                    How might you open them? Which side do they open on? Do they open in or out? how do you know?
                """)
            .foregroundColor(.white)
            Image("doors")
                .resizable()
                .scaledToFill()
                .frame(width: 300, height:  500)
                .colorInvert()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        
        //TODO: Potentially replace with different topic
    }
}

#Preview {
    HCIView()
}
