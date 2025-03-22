//
//  ImgView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import MultipeerConnectivity

// MARK: - Main View

/// View that explains digital image representation and provides interactive pixel art creation
struct ImgView: View {
    // MARK: Properties
    
    public var name: String
    
    // MARK: Content Text
    
     let pixelIntroText: LocalizedStringKey = """
    Have you ever looked *really* close at a screen and noticed a grid of small squares making up the image you see? We call these **pixels** in computing science, they are what make up anything you can see on a screen, most screens have millions of pixels to make the resulting image as sharp as possible.
    """
    
    let blackWhiteExplanationText: LocalizedStringKey = """
    Let's start simple...
    
    To make a black and white image, we can make each pixel either black or white, so the computer would need to store which pixels are black and which are white. We can represent this using bits, with ones representing black pixels and zeroes representing white pixels. Experiment with this for a while, what kind of images can and can't you make with this, what else do we need?
    """
    
    let grayscaleExplanationText: LocalizedStringKey = """
    If we allow each pixel to use **2** bits this time, we can double the colours we can use, and now have grey. Now, rather than each pixel being 0 or 1, each can be 00, 01, 10, or 11, each representing a  different brightness, and allowing us to make images like this.
    """
    
    let colorExplanationText: LocalizedStringKey = """
    Let's double the number of bits available to us again, to 4 bits per pixel. This brings us all the way up to **16** different colours, letting us make all sorts of pictures!
    """
    
    let colorDepthScalingText: LocalizedStringKey = """
    As you might have noticed, every time we double the number of pixels, the number of colours we can represent is **squared**. In other words, when we go from one 1 bit to 2 to 4 to 8, we go from 2 colours to 4 to 16 to 256. Most TVs and monitors use 24-bit colour, that's 8 bits just for each colour channel (red, green, and blue) or 16,777,216 in total! Some even have 32-bit color -- Over 4 **billion**!
    """
    
    // MARK: Initialization
    
    /// Initializes the view with the user's name
    /// - Parameter name: The user's name for multiplayer features
    init(name: String) {
        self.name = name
    }
    
    // MARK: Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Image Representation")
                    .font(.system(.largeTitle))
                    .padding()
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                    .focusable()
                
                imageRepresentationContent
                    .focusable()
                
                // Platform-specific interactive components
#if os(iOS)
                Divider()
                    .background(Color.white)
                    .padding(.vertical, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("4-Bit Color Image Builder")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    ColorPixelBuilderView(name: name)
                        .interactiveArea()
                }
                .padding()
#elseif os(tvOS)
                Divider()
                    .background(Color.white)
                    .padding(.vertical, 20)
                
                PixelArtShowcaseView(service: TVOSMultipeerServiceArt())
                    .focusable()
#endif
            }
        }
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
    
    // MARK: Subviews
    
    /// The main educational content explaining image representation concepts
    var imageRepresentationContent: some View {
        VStack(spacing: 20) {
            Text(pixelIntroText)
            
            HStack(alignment: .top, spacing: 15) {
                Text(blackWhiteExplanationText)
                
                Image("blackwhiteimg")
                    .resizable()
                    .frame(width: 350, height: 250)
                    .aspectRatio(contentMode: .fill)
                    .accessibilityLabel("Black and white image example showing 1-bit color depth")
            }
            
            Spacer()
            
            HStack(alignment: .top, spacing: 15) {
                Text(grayscaleExplanationText)
                
                Image("greyimg")
                    .resizable()
                    .frame(width: 350, height: 250)
                    .aspectRatio(contentMode: .fill)
                    .accessibilityLabel("Grayscale image example showing 2-bit color depth with four shades")
            }
            
            HStack(alignment: .top, spacing: 15) {
                Text(colorExplanationText)
                
                Image("colourimg")
                    .resizable()
                    .frame(width: 350, height: 250)
                    .aspectRatio(contentMode: .fill)
                    .accessibilityLabel("Color image example showing 4-bit color depth with sixteen colors")
            }
            
            Text(colorDepthScalingText)
                .focusable(true)
                .accessibilityHint("Explains how the number of available colors increases exponentially with bit depth")
        }
        .padding()
    }
}

// MARK: - iOS Implementation

#if os(iOS)
/// Interactive view for creating pixel art with a 16-color palette
struct ColorPixelBuilderView: View {
    // MARK: Properties
    
    /// User's name for peer-to-peer connection
    let name: String
    
    /// 16-color palette for the 4-bit pixel art
    let palette: [Color] = [
        .black, .white, .red, .green,
        .blue, .yellow, .orange, .purple,
        .pink, .gray, .brown, .cyan,
        .mint, .indigo, .teal, .darkPurple
    ]
    
    let gridSize = 16
    
    /// Array representing the color index of each pixel in the grid
    @State private var pixels: [Int] = Array(repeating: 0, count: 256)
    
    /// Currently selected color from the palette
    @State private var selectedColor: Int = 0
    
    /// Service for sharing pixel art between devices
    @StateObject private var multipeerService: iOSMultipeerServiceArt
    
    // MARK: Initialization
    
    /// Initializes the pixel builder with the user's name
    /// - Parameter name: User's name for peer-to-peer identification
    init(name: String) {
        self.name = name
        _multipeerService = StateObject(wrappedValue: iOSMultipeerServiceArt(username: name))
    }
    
    // MARK: Body
    
    var body: some View {
        VStack {
            // Connection control
            if !multipeerService.isConnected {
                connectionButton
            }
            
            colorPaletteSelector
            
            pixelGrid
            
            controlButtons
        }
    }
    
    // MARK: Subviews
    
    /// Button for initiating connection to other devices
    private var connectionButton: some View {
        Button("Connect / Browse") {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                multipeerService.browseForArtService(presentingVC: rootVC)
            }
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(8)
        .accessibilityHint("Opens a browser to connect with other devices")
    }
    
    /// Horizontal scrolling color palette for selection
    private var colorPaletteSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<palette.count, id: \.self) { index in
                    Circle()
                        .fill(palette[index])
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == index ? Color.yellow : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedColor = index
                        }
                        .accessibilityLabel(colorName(at: index))
                        .accessibilityHint("Tap to select this color")
                        .accessibilityAddTraits(selectedColor == index ? [.isSelected] : [])
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
    }
    
    /// Grid of pixels that can be tapped to change colors
    private var pixelGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: -(UIScreen.main.bounds.width/1.45)), count: gridSize)
        
        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<pixels.count, id: \.self) { index in
                Rectangle()
                    .fill(palette[pixels[index]])
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        pixels[index] = selectedColor
                        multipeerService.sendPixelArtUpdate(pixels: pixels)
                    }
                    .accessibilityLabel("Pixel at position \(index / gridSize + 1), \(index % gridSize + 1)")
                    .accessibilityHint("Tap to change this pixel to \(colorName(at: selectedColor))")
            }
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("16 by 16 pixel grid")
    }
    
    /// Control buttons for the pixel art editor
    private var controlButtons: some View {
        HStack {
            Button("Reset") {
                pixels = Array(repeating: 0, count: 256)
                multipeerService.sendPixelArtUpdate(pixels: pixels)
            }
            .padding()
            .background(Color.red)
            .cornerRadius(8)
            .accessibilityHint("Clears all pixels to black")
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: Helper Methods
    
    /// Provides a human-readable name for a color at the given index
    /// - Parameter index: Index in the palette array
    /// - Returns: A descriptive name of the color
    private func colorName(at index: Int) -> String {
        let names = ["Black", "White", "Red", "Green",
                     "Blue", "Yellow", "Orange", "Purple",
                     "Pink", "Gray", "Brown", "Cyan",
                     "Mint", "Indigo", "Teal", "Purple"]
        
        return index >= 0 && index < names.count ? names[index] : "Unknown"
    }
}
#endif

// MARK: - tvOS Implementation

#if os(tvOS)
/// View that displays pixel art created on connected iOS devices
struct PixelArtShowcaseView: View {
    // MARK: Properties
    
    /// Service for receiving pixel art from connected devices
    @ObservedObject var service: TVOSMultipeerServiceArt
    
    /// 16-color palette matching the iOS palette
    let palette: [Color] = [
        .black, .white, .red, .green,
        .blue, .yellow, .orange, .purple,
        .pink, .gray, .brown, .cyan,
        .mint, .indigo, .teal, .darkPurple
    ]
    
    let gridSize = 16
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Pixel Art Showcase")
                .font(.system(size: 50))
                .padding(.top, 50)
                .accessibilityAddTraits(.isHeader)
                .focusable(true)
            
            if service.peerPixelArt.isEmpty {
                Text("No connected iOS devices yet.")
                    .accessibilityLabel("Waiting for iOS devices to connect and share pixel art")
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 40) {
                        ForEach(Array(service.peerPixelArt.keys), id: \.self) { peerID in
                            VStack {
                                if let pixelArray = service.peerPixelArt[peerID] {
                                    pixelGridView(pixelArray)
                                        .focusable()
                                }
                                Text(peerID.displayName)
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                    .accessibilityLabel("Pixel art by \(peerID.displayName)")
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
                .accessibilityLabel("Horizontal scroll view of pixel art from connected devices")
            }
            
            Spacer()
        }
        .interactiveArea()
    }
    
    // MARK: Helper Views
    
    /// Creates a grid view visualizing the provided pixel array
    /// - Parameter pixels: Array of color indices representing the pixel art
    /// - Returns: A grid view showing the pixel art
    @ViewBuilder
    func pixelGridView(_ pixels: [Int]) -> some View {
        let columns = Array(repeating: GridItem(.fixed(20), spacing: 0), count: gridSize)
        
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<pixels.count, id: \.self) { idx in
                Rectangle()
                    .fill(palette[safeIndex: pixels[idx]] ?? .black)
                    .frame(width: 20, height: 20)
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("16 by 16 pixel art grid")
    }
}

/// Extension for safely accessing array elements
extension Array {
    /// Safely accesses an array element, returning nil if the index is out of bounds
    /// - Parameter index: The index to access
    /// - Returns: The element at the specified index, or nil if out of bounds
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
#endif

// MARK: - Preview Provider

#Preview {
    ImgView(name: "User")
}
