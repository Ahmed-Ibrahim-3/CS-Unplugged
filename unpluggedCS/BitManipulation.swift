//
//  BitView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

// MARK: - Utility Functions and Operators

/// Custom power operator that raises the first number to the power of the second
infix operator ** : MultiplicationPrecedence

func ** (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

// MARK: - Supporting Views

/// A view that renders a configurable number of circles in different layouts
struct SectionView: View {
    /// The number of circles to display (1, 2, 4, 8, or 16)
    let circleCount: Int
    
    /// Creates a circle with the specified size
    /// - Parameter size: The diameter of the circle
    /// - Returns: A styled circle view
    func createCircle(size: CGFloat) -> some View {
        Circle()
            .fill(Color.orange.opacity(0.7))
            .frame(width: size, height: size)
            .accessibilityLabel("Circle")
    }
    
    var body: some View {
        switch circleCount {
        case 1:
            let size: CGFloat = 60
            createCircle(size: size)
                .accessibilityLabel("One circle")
        case 2:
            let size: CGFloat = 50
            VStack(spacing: 16) {
                createCircle(size: size)
                createCircle(size: size)
            }
            .accessibilityLabel("Two circles stacked vertically")
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
            .accessibilityLabel("Four circles in a 2x2 grid")
        case 8:
            let size: CGFloat = 30
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    createCircle(size: size)
                    createCircle(size: size)
                    createCircle(size: size)
                    createCircle(size: size)
                }
                HStack(spacing: 16) {
                    createCircle(size: size)
                    createCircle(size: size)
                    createCircle(size: size)
                    createCircle(size: size)
                }
            }
            .accessibilityLabel("Eight circles in a 4x2 grid")
        case 16:
            let size: CGFloat = 10
            VStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { column in
                            createCircle(size: size)
                        }
                    }
                }
            }
            .accessibilityLabel("Sixteen circles in a 4x4 grid")
        default:
            EmptyView()
        }
    }
}

// MARK: - Main View

/// Interactive view for learning about bit manipulation and binary numbers
struct BitView: View {
    // MARK: Properties
    
    /// Text content for the bit manipulation activity
    private let bitActivity = """
                    Discuss the following:
                       \u{2022} What is the smallest number you can make?
                       \u{2022} What is the largest? 
                    
                    Starting from 0, count up each number one by one (1,2,3,4...)
                       \u{2022} What patterns do you see?
                       \u{2022} Once you have reached 31, what's next? How might we get 32?
                    
                    Let's look deeper...
                       \u{2022} What is the maximum number you can make with 5 bits?
                       \u{2022} What value would the next bit have?
                       \u{2022} What is the maximum value of these 6 bits?
                       \u{2022} Again, what value would the next bit have?
                       \u{2022} What pattern do you see?
                    
                    Now we know the maximum, minimum, and how to find them, what else?
                       \u{2022} How many different numbers can you make with 2 bits?
                       \u{2022} How many could you make with one more?
                       \u{2022} Do you see a pattern? If not, keep adding a bit and looking 
                                numbers you can make until one becomes clear.
                    """
    
    /// Array of boolean values representing binary bits (true = 1, false = 0)
    @State private var bitValues: [Bool]
    
    /// Tracks focus state for tvOS UI
    @State private var isFocused = false
    
    /// Array of possible circle counts for each section
    private let bitCounts = [1, 2, 4, 8, 16]
    
    /// Index of the current section being displayed in the pattern demonstration
    @State private var currentSectionIndex = 0
    
    // MARK: - Maximum number of bits to display in the interactive bit toggles
    private let maxBits = 5
    
    /// Current decimal value represented by the binary bits
    @State var decimalValue = 0
    
    // MARK: Initialization
    
    init() {
        // Initialize all bits to false (0)
        bitValues = Array(repeating: false, count: maxBits)
        
        // Calculate the maximum possible value with maxBits (2^maxBits - 1)
        decimalValue = (2 ** maxBits) - 1
    }
    
    // MARK: Methods
    
    /// Calculates the decimal value represented by an array of binary bits
    /// - Parameter binaryArray: Array of boolean values where true = 1 and false = 0
    /// - Returns: The decimal value of the binary number
    func calculateBinaryValue(from binaryArray: [Bool]) -> Int {
        var value = 0
        for (index, bit) in binaryArray.reversed().enumerated() {
            if bit {
                value += Int(pow(2.0, Double(index)))
            }
        }
        return value
    }
    
    // MARK: Body
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text("Bit Manipulation")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding()
                        .accessibilityAddTraits(.isHeader)
                    
#if os(tvOS)
                    tvOSContent(proxy: proxy)
#elseif os(iOS)
                    iOSContent()
#endif
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
    
    // MARK: Platform-Specific Views
    
#if os(tvOS)
    /// Content specific to tvOS interface
    /// - Parameter proxy: ScrollViewProxy for programmatic scrolling
    /// - Returns: tvOS-specific view hierarchy
    private func tvOSContent(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 40) {
            // Binary pattern demonstration
            HStack {
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
                .accessibilityLabel("Pattern demonstration, showing powers of 2")
                .accessibilityHint("Press to add the next pattern in the sequence")
            }
            .padding()
            .frame(width: 1100, height: 400)
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding([.leading, .trailing], 10)
            
            Text("""
                What do you notice about this pattern? How many dots should the next card have?
                
                Now, let's see what we can do with these:
                """)
            
            // Interactive binary toggles
            VStack {
                HStack(spacing: 25) {
                    ForEach(0..<maxBits, id: \.self) { index in
                        Button(action: {
                            bitValues[index].toggle()
                        }) {
                            Image(systemName: bitValues[index] ? "circle.fill" : "circle.dotted")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75)
                                .clipped()
                                .foregroundColor(Color.orange.opacity(0.7))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityLabel(bitValues[index] ? "Bit \(index) is on" : "Bit \(index) is off")
                        .accessibilityHint("Press to toggle this bit")
                    }
                }
                
                Button(action: {
                    decimalValue = calculateBinaryValue(from: bitValues)
                }) {
                    Image(systemName: "equal")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipped()
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
                .accessibilityLabel("Calculate decimal value")
                .accessibilityHint("Press to calculate the decimal value of the binary number")
                
                Text(String(decimalValue))
                    .focusable(true)
                    .accessibilityLabel("Decimal value: \(decimalValue)")
            }
            .padding()
            .frame(width: 1100, height: 400)
            .background(Color.black.opacity(0.6))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding([.leading, .trailing], 10)
            
            Spacer().frame(height: 200)
            
            // Activity discussion text
            Text(bitActivity)
                .id(999)
                .scaleEffect(isFocused ? 1.2 : 1)
                .focusable(true)
                .animation(.easeInOut, value: isFocused)
                .accessibilityLabel("Discussion questions about binary numbers")
        }
    }
#endif
    
#if os(iOS)
    /// Content specific to iOS interface
    /// - Returns: iOS-specific view hierarchy
    private func iOSContent() -> some View {
        VStack(spacing: 20) {
            Text(bitActivity)
                .accessibilityLabel("Discussion questions about binary numbers")
            
            // Interactive binary toggles
            HStack(spacing: 10) {
                ForEach(0..<maxBits, id: \.self) { index in
                    Image(systemName: bitValues[index] ? "circle.fill" : "circle.dotted")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .clipped()
                        .foregroundColor(Color.orange.opacity(0.7))
                        .onTapGesture {
                            bitValues[index].toggle()
                            decimalValue = calculateBinaryValue(from: bitValues)
                        }
                        .accessibilityLabel(bitValues[index] ? "Bit \(index) is on" : "Bit \(index) is off")
                        .accessibilityHint("Tap to toggle this bit")
                }
            }
            .interactiveArea()
            
            Text(String(decimalValue))
                .font(.system(size: 30))
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityLabel("Decimal value: \(decimalValue)")
        }
    }
#endif
}

// MARK: - Preview Provider

#Preview {
    BitView()
}
