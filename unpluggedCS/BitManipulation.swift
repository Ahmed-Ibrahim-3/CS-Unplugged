//
//  BitView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
import SwiftUI

struct SectionView: View {
    let circleCount: Int
    func createCircle(size: CGFloat) -> some View{
        Circle()
            .fill(Color.orange.opacity(0.7))
            .frame(width: size, height: size)
    }
    
    var body: some View {
        switch circleCount {
        case 1:
            let size: CGFloat = 60
            createCircle(size: size)
        case 2:
            let size: CGFloat = 50
            VStack(spacing: 16) {
                createCircle(size: size)
                createCircle(size: size)
            }
        case 4:
            let size: CGFloat = 40
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    createCircle(size: size)
                    createCircle(size: size)
                }
                HStack(spacing: 16) {
                    createCircle(size: size)
                    createCircle(size: size)
                }
            }
        case 8:
            let size: CGFloat = 30
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    createCircle(size: size); createCircle(size: size); createCircle(size: size); createCircle(size: size)
                }
                HStack(spacing: 16) {
                    createCircle(size: size); createCircle(size: size); createCircle(size: size); createCircle(size: size)
                }
            }
        case 16:
            let size: CGFloat = 10
            VStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in
                    HStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { _ in
                            createCircle(size: size)
                        }
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

struct BitView : View {

    private let bitActivity = """
                    Discuss the following:
                       \u{2022} What is the smallest nymber you can make?
                       \u{2022} What is the largest? 
                    
                    Starting from 0, count up each number one by one (1,2,3,4...)
                       \u{2022} What patterns do you see?
                       \u{2022} Once you have reached 31, whats next? how might we get 32
                    
                    Lets look deeper...
                       \u{2022} What is the maximum number you can make with 5 bits?
                       \u{2022} What value would the next bit have?
                       \u{2022} What is the maximum value of these 6 bits?
                       \u{2022} Again, what value would the next bit have?
                       \u{2022} What pattern do you see?
                    
                    Now we know the maximum, minimum, and how to find them, what else?
                       \u{2022} How many different numbers can you make with 2 bits?
                       \u{2022} How many could you make with one more?
                       \u{2022} Do you see a pattern? If not, keep adding a bit and looking 
                                numbers you can make until one becomes clear
                    """
    
    @State private var imgIndex = 0
    @State private var isImageOne: [Bool] = Array(repeating: true, count: 5)
    @State private var decimalVal = 31
    @State private var isFocused = false
    @State private var totalShapes = 1
    private let bitCounts = [1,2,4,8,16]
    @State private var currentSectionIndex = 0
    private let maxBits = 5
    
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
        VStack{
            Text("Bit Manipulation")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
#if os(tvOS)
            ScrollViewReader { proxy in
                ScrollView{
                    VStack(spacing: 40){
                        HStack{
                            Button(action: {
                                if currentSectionIndex < bitCounts.count - 1 {
                                    currentSectionIndex += 1
                                }
                            }) {
                                HStack(spacing: 30) {
                                    ForEach(0...currentSectionIndex, id: \.self) { index in
                                        SectionView(circleCount: bitCounts[index])
                                        Divider()
                                    }
                                }
                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 100, height: 100)
                        }
                        .padding()
                        .frame(width:1100, height:400)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding([.leading, .trailing], 10)
                        
                        Text("""
                            What do you notice about this pattern? How many dots should the next card have?
                        
                            Now, Lets see what we can do with these 
                        """)
                        VStack{
                            HStack(spacing:25){
                                ForEach(0..<5, id: \.self) { index in
                                    Button(action: {
                                        isImageOne[index].toggle()
                                    }) {
                                        Image(systemName: isImageOne[index] ? "circle.fill" : "circle.dotted")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 75)
                                            .clipped()
                                            .foregroundColor(Color.orange.opacity(0.7))
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
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                            
                            Text(String(decimalVal))
                                .focusable(true)
                        }
                        .padding()
                        .frame(width:1100, height:400)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding([.leading, .trailing], 10)
                    }
                    Spacer().frame(height: 200)
                    Text(bitActivity)
                        .id(999)
                        .scaleEffect(isFocused ? 1.2: 1)
                        .focusable(true)
                        .animation(.easeInOut, value: isFocused)
                }
            }
#elseif os(iOS)
            VStack(spacing: 20) {
                Text(bitActivity)
                
                HStack(spacing: 10) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: isImageOne[index] ? "circle.fill" : "circle.dotted")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75)
                            .clipped()
                            .foregroundColor(Color.orange.opacity(0.7))
                            .onTapGesture {
                                isImageOne[index].toggle()
                                decimalVal = calculateBinaryValue(from: isImageOne)
                            }
                    }
                }.interactiveArea()
                
                Text(String(decimalVal))
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding()
            }
#endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
    }
}
#Preview{
    BitView()
}
