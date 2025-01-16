//
//  ImgView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import MultipeerConnectivity

struct ImgView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button(action: {}) {
                    Text("Image Representation")
                        .font(.system(.largeTitle))
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(spacing: 20) {
                    Text("""
                   Have you ever looked *really* close at a screen and noticed a grid of small squares making up the image you see? We call these **pixels** in computing science, they are what make up anything you can see on a screen, most screens have millions of pixels to make the resulting image as sharp as possible. 
                   """)
                    
                    HStack {
                        Text("""
                   Let's start simple...
                       
                   To make a black and white image, we can make each pixel either black or white, so the computer would need to store which pixels are black and which are white. We can represent this using bits, with ones representing black pixels and zeroes representing white pixels. Experiment with this for a while, what kind of images can and can't you make with this, what else do we need?
                   """)
                        Image("blackwhiteimg")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .aspectRatio(contentMode: .fill)
                        
                    }
                    Spacer()
                    HStack {
                        Text("""
                       If we allow each pixel to use **2** bits this time, we can double the colours we can use, and now have grey. Now, rather than each pixel being 0 or 1, each can be 00, 01, 10, or 11, each representing a  different brightness, and allowing us to make images like this.
                       """)
                        Image("greyimg")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .aspectRatio(contentMode: .fill)
                    }
                    
                    HStack {
                        Text("""
                       Let's double the number of bits available to us again, to 4 bits per pixel. This brings us all the way up to **16** different colours, letting us make all sorts of pictures! 
                       """)
                        Image("colourimg")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .aspectRatio(contentMode: .fill)
                    }
                    
                    Text("""
                       As you might have noticed, every time we double the number of pixels, the number of colours we can represent is **squared**. In other words, when we go from one 1 bit to 2 to 4 to 8, we go from 2 colours to 4 to 16 to 256. Most TVs and monitors use 24-bit colour, that's 8 bits just for each colour channel (red, green, and blue) or 16,777,216 in total! Some even have 32-bit color -- Over 4 **billion**!
                   """)
                        .focusable(true)
                }
                .padding()
            }
#if os(iOS)
            Divider()
                .background(Color.white)
                .padding(.vertical, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("4-Bit Color Image Builder")
                    .font(.headline)
                
                ColorPixelBuilderView()
                    .interactiveArea()
            }
            .padding()
#elseif os(tvOS)
            Divider()
                .background(Color.white)
                .padding(.vertical, 20)
            PixelArtShowcaseView(service: TVOSMultipeerService())
                .edgesIgnoringSafeArea(.all)
#else
            Text("Not implemented on this platform.")
#endif
        }
        .background(backgroundGradient)
        .foregroundColor(.white)
    }
}

#if os(iOS)
struct ColorPixelBuilderView: View {
    let palette: [Color] = [
        .black, .white, .red, .green,
        .blue, .yellow, .orange, .purple,
        .pink, .gray, .brown, .cyan,
        .mint, .indigo, .teal, Color("32CD32")
    ]
    
    let gridSize = 16
    @State private var pixels: [Int] = Array(repeating: 0, count: 256)
    
    @State private var selectedColor: Int = 0
    @State private var ColumnSpacing: CGFloat = -800
    
    @StateObject private var mpService = iOSMultipeerService()
    
    var body: some View {
        VStack {
            if !mpService.isConnected {
                Button("Connect / Browse") {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        mpService.startBrowsing(presentingVC: rootVC)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
            
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
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 10)
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: ColumnSpacing), count: gridSize)
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(0..<pixels.count, id: \.self) { idx in
                    Rectangle()
                        .fill(palette[pixels[idx]])
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            pixels[idx] = selectedColor
                            mpService.sendPixelArtUpdate(pixels: pixels)
                        }
                }
            }
            .padding()
            
            HStack {
                Button("Reset") {
                    pixels = Array(repeating: 0, count: 256)
                    mpService.sendPixelArtUpdate(pixels: pixels)
                }
                .padding()
                .background(Color.red)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding(.horizontal)
        }
//        .background(Color.black.opacity(0.7))
//        .cornerRadius(10)
//        .padding()
    }
}
#endif

#if os(tvOS)
struct PixelArtShowcaseView: View {
    @ObservedObject var service: TVOSMultipeerService
    
    let palette: [Color] = [
        .black, .white, .red, .green,
        .blue, .yellow, .orange, .purple,
        .pink, .gray, .brown, .cyan,
        .mint, .indigo, .teal, Color("32CD32")
    ]
    let gridSize = 16
    
    var body: some View {
        VStack {
            Text("Pixel Art Showcase")
                .font(.system(size: 50))
                .padding(.top, 50)
            
            if service.peerPixelArt.isEmpty {
                Text("No connected iOS devices yet.")
            } else {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 40) {
                        ForEach(Array(service.peerPixelArt.keys), id: \.self) { peerID in
                            VStack {
                                Text(peerID.displayName)
                                    .font(.title3)
                                    .padding(.bottom, 20)
                                
                                if let pixelArray = service.peerPixelArt[peerID] {
                                    pixelGridView(pixelArray)
                                        .focusable()
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .interactiveArea()
    }
    
    @ViewBuilder
    private func pixelGridView(_ pixels: [Int]) -> some View {
        let columns = Array(repeating: GridItem(.fixed(20), spacing: -1), count: gridSize)
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(0..<pixels.count, id: \.self) { idx in
                Rectangle()
                    .fill(palette[safeIndex: pixels[idx]] ?? .black)
                    .frame(width: 20, height: 20)
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
}

extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
#endif

#Preview {
    ImgView()
}
