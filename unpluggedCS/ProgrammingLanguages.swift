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
            ScrollView{
                Text("Programming Languages")
                    .font(.system(.largeTitle))
                    .multilineTextAlignment(.center)
                    .padding()
                Text("""
                Computers work by following a series of instructions exactly as they are written, regardless of whether or not they are logical, the computer will at least attempt to complete them. Programming languages are how we give these instructions, and are made up of several low level building blocks. The part you are likely most familiar with, is a language's **syntax**, which describes how things like *expressions*, *commands*, *declarations*, and other constructs are arranged to make a program.
                
                One way we reperesent syntax rules is with **Regular Expressions**, which is a kind of pattern we use to match a set of strings. Here are some examples of how we can use regular expressions to find patterns in strings
                
                Regular expression notation has some important rules, namely:
                
                \u{2022} 'xyz' : matches the string within the quotes
                \u{2022} "(xyz)": matches any string, grouped by brackets
                \u{2022} "s1|s2": matches string one **or** string two,
                \u{2022} "xyz*": matches any number of the occurences of the string
                \u{2022} "xyz+": matches occurences with one or more of the string
                
                """).padding()
                
                Text("""
                \u{2022} 'M'('r'|'rs'|'iss')
                    - We read this as: An 'M' followed by either an 'r', 'rs', or 'iss'. This represents the strings 'Mr', 'Mrs', and 'Miss'
                \u{2022} 'b'('an')\u{002A}'a'
                    - A 'b', followed by 0 or more 'an's, followed by an 'a'. This represents the strings 'ba', 'bana', banana', 'bananana', etc.
                \u{2022} ('x'|'abc')\u{066d} 
                    - Any number of occurences of  'x' or 'abc', for example: 'x','abc','xx','xabc','abcx’,'abcabc’,' xxx’,'xxabc’,'xabcx’,'abcxx’, etc.
                """)
                Text("""
                Now, think about what programming languages you know. How could regular expressions be used to define Their syntax rules? For example, consider an **if** statement in python, this can be represented as 'if' *command*+ ':' *expression*+ This is a much more simplified represenatation, as it doesn't include the new line and indentation before the expression(s), and doesn't have the 'and's or 'or's between the command(s), which in this case are the conditions of the if statement
                """).padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    ProgLangView()
}
