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
class BitViewModel: ObservableObject {
    @Published var bitValues: [Bool]
    @Published var decimalValue: Int = 0
    @Published var currentSectionIndex = 0
    @State var isFocused = false

    
    let maxBits: Int
    
    init(maxBits: Int, initialBits: [Bool]? = nil) {
        self.maxBits = maxBits
        if let initialBits = initialBits, initialBits.count == maxBits {
            self.bitValues = initialBits
        } else {
            self.bitValues = Array(repeating: false, count: maxBits)
        }
        self.decimalValue = calculateBinaryValue(from: self.bitValues)
    }
    
    func toggleBit(at index: Int) {
        guard index >= 0 && index < bitValues.count else { return }
        bitValues[index].toggle()
        #if os(iOS)
        decimalValue = calculateBinaryValue(from: bitValues)
        #endif
    }
    
    func setAllBits(to value: Bool) {
        bitValues = Array(repeating: value, count: maxBits)
        decimalValue = calculateBinaryValue(from: bitValues)
    }
    
    func nextSection() {
        if currentSectionIndex < 4 {
            currentSectionIndex += 1
        }
    }
    
    func calculateBinaryValue(from binaryArray: [Bool]) -> Int {
        var value = 0
        for (index, bit) in binaryArray.reversed().enumerated() {
            if bit {
                value += 2 ** index
            }
        }
        return value
    }
}
/// Interactive view for learning about bit manipulation and binary numbers
struct BitView: View {
    @ObservedObject var viewModel: BitViewModel
        
        // Text content for the bit manipulation activity
        let bitActivity = """
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
        
        /// Array of possible circle counts for each section
        private let bitCounts = [1, 2, 4, 8, 16]
        
        @State var isFocused = false
        
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
        
    #if os(tvOS)
        /// Content specific to tvOS interface
        /// - Parameter proxy: ScrollViewProxy for programmatic scrolling
        /// - Returns: tvOS-specific view hierarchy
        func tvOSContent(proxy: ScrollViewProxy) -> some View {
            VStack(spacing: 40) {
                // Binary pattern demonstration
                HStack {
                    Button(action: {
                        viewModel.nextSection()
                    }) {
                        HStack(spacing: 30) {
                            ForEach(0...viewModel.currentSectionIndex, id: \.self) { index in
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
                        ForEach(0..<viewModel.maxBits, id: \.self) { index in
                            Button(action: {
                                viewModel.toggleBit(at: index)
                            }) {
                                Image(systemName: viewModel.bitValues[index] ? "circle.fill" : "circle.dotted")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 75)
                                    .clipped()
                                    .foregroundColor(Color.orange.opacity(0.7))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel(viewModel.bitValues[index] ? "Bit \(index) is on" : "Bit \(index) is off")
                            .accessibilityHint("Press to toggle this bit")
                        }
                    }
                    
                    Button(action: {
                        viewModel.decimalValue = viewModel.calculateBinaryValue(from: viewModel.bitValues)
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
                    
                    Text(String(viewModel.decimalValue))
                        .focusable(true)
                        .accessibilityLabel("Decimal value: \(viewModel.decimalValue)")
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
        func iOSContent() -> some View {
            VStack(spacing: 20) {
                Text(bitActivity)
                    .accessibilityLabel("Discussion questions about binary numbers")
                
                // Interactive binary toggles
                HStack(spacing: 10) {
                    ForEach(0..<viewModel.maxBits, id: \.self) { index in
                        Image(systemName: viewModel.bitValues[index] ? "circle.fill" : "circle.dotted")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .clipped()
                            .foregroundColor(Color.orange.opacity(0.7))
                            .onTapGesture {
                                viewModel.toggleBit(at: index)
                            }
                            .accessibilityLabel(viewModel.bitValues[index] ? "Bit \(index) is on" : "Bit \(index) is off")
                            .accessibilityHint("Tap to toggle this bit")
                    }
                }
                .interactiveArea()
                
                Text(String(viewModel.decimalValue))
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding()
                    .accessibilityLabel("Decimal value: \(viewModel.decimalValue)")
            }
        }
    #endif
    }

// MARK: - Preview Provider

#Preview {
    BitView(viewModel: BitViewModel(maxBits: 5))
}
