//
//  StateView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct StateView : View {
    var body : some View{
        
        VStack{
            Text("State Machines")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            
            Text("""
                Finite-State Automata(FSA) - The simplest form of state machine are a good way to 
                model computation, perform pattern matching, and process text. 
                
                They can be thought of as a map consisting of:
                    \u{2022} a set of states, usually represented by circles
                    \u{2022} transitions(or paths) between each state
                    \u{2022} an initial input state represented by an arrow and
                                and exit state represented by a double circle
                """).foregroundColor(.white)
            HStack{
                Image("FSA")
                    .resizable()
                    .frame(width: 650,height: 150)
                    .scaledToFit()
                    .colorInvert()
                
                Text("""
                    In these examples, we have numbered states 1, 2 and 3, with transitions
                    A and B between each one. From the initial state, the aim is to finish at
                    (one of) the exit states.
                    
                    How will each of these finite state automata reach an exit state?
                    """).foregroundColor(.white)
            }
            HStack{
                Image("sentenceFSA")
                    .resizable()
                    .frame(width: 550,height: 200)
                    .aspectRatio(contentMode: .fill)
                    .colorInvert()
                Text("Discuss amongst yourselves what this state machine constructs? ").foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .background(backgroundGradient)
        
        //TODO: Interactive DFA Builder
    }
}

#Preview {
    StateView()
}
