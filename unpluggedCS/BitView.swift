//
//  BitView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct BitView : View {
    
    private let Gimages = [
        "Grid1",
        "Grid2",
        "Grid3",
        "Grid4",
        "Grid5"
    ]
    
    @State private var imgIndex = 0
    @State private var isImageOne = [true, true, true, true, true]
    @State private var decimalVal = 0
    
    func calculateBinaryValue(from binaryArray: [Bool]) -> Int {
        var value = 0
        for (index, bit) in binaryArray.reversed().enumerated() {
            if bit {
                value += Int(pow(2.0, Double(index)))
            }
        }
        return value
    }
    
    var body : some View{
        
        ScrollView{
            Text("Bit Manipulation")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(spacing: 40){
                Button(action: {
                    if imgIndex < Gimages.count - 1 {
                        imgIndex += 1
                    }
                }) {
                    Image(Gimages[imgIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                }
                .disabled(imgIndex >= Gimages.count - 1)
                
                Text("""
                        What do you notice about this pattern? How many dots should the next card have?
                    
                        Now, Lets see what we can do with these 
                    """)
                
                HStack(spacing:10){
                    ForEach(0..<5, id: \.self) { index in
                        Button(action: {
                            isImageOne[index].toggle()
                        }) {
                            Image(isImageOne[index] ? "Grid1" : "bitOff")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75,height: 125)
                                .clipped()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                Button (action: {
                    decimalVal = calculateBinaryValue(from: isImageOne)
                }){
                    Image(systemName: "equal")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50,height: 50)
                        .clipped()
                }
                Button{
                }
                label: {Text(String(decimalVal))
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            Text("""
                    Get into pairs and take a set of binary number cards 
                
                    Discuss the following:
                       \u{2022} What is the smallest nymber you can make?
                       \u{2022} What is the largest? 
                
                    Starting from 0, count up each number one by one (1,2,3,4...)
                       \u{2022} What patterns do you see?
                       \u{2022} Once you have reached 31, whats next? how might we get 32
                
                    Lets look deeper...
                       \u{2022} What is the maximum number you can make with 2 bits?
                       \u{2022} How many dots would the next card have?
                       \u{2022} What is the maximum value of these **3** bits?
                       \u{2022} Again, how many dots would the next card have?
                       \u{2022} What pattern do you see?
                
                    Now we know the maximum, minimum, and how to find them, what else?
                       \u{2022} How many different numbers can you make with 2 bits?
                       \u{2022} How many could you make with one more?
                       \u{2022} Do you see a pattern? If not, keep adding a bit and looking 
                                numbers you can make until one becomes clear
                """)
        }
    }
}
//#Preview{
//    BitView()
//}
