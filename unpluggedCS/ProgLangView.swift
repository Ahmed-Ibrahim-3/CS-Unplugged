//
//  ProgLangView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct ProgLangView : View {
    var body : some View{
        VStack(spacing: 50){
            Text("Programming Languages")
                .font(.system(.largeTitle))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            Text("""
                    Computers work by following a series of instructions exactly as they are written, regardless of 
                    whether or not they make sense.
                    For instance, imagine if people did the same, what would happen if you pointed to a closed door
                    and said "Go through that door" or told someone "Put your shoes and socks on"?.
                    
                    Without common sense, context, and reasoning, these very simple tasks can be vastly different.
                """).foregroundColor(.white)
            Text("""
                    Get into pairs and take turns writing instructions for each other. You could, for example:
                        \u{2022} Write instructions on how to fold a paper plane
                        \u{2022} Write instructions on how to get to a location around the room/building 
                    Give the instructions to your partner, and dont let them ask any questions, or give any hints. 
                    This is more like how a computer works in real life. 
                """).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        
        //TODO: Idek, interaction somehow?
    }
}

#Preview {
    ProgLangView()
}
