//
//  IMGView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

struct ImgView: View {
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Button(action: {}) {
                    Text("Image Representation")
                        .font(.system(.largeTitle))
                        .padding()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(spacing: 20) {
                    Text("""
                        Have you ever looked *really* close at a screen and noticed a grid of small squares making up the image you see?
                        We call these **pixels** in computing science, they are what make up anything you can see on a screen, most screens 
                        have millions of pixels to make the resulting image as sharp as possible. 
                    """).foregroundColor(.white)
                    
                    HStack {
                        Text("""
                        Let's start simple...
                        To make a black and white image, we can make each pixel either black or white, so the computer would 
                        need to store which pixels are black and which are white. We can represent this using bits, with ones 
                        representing black pixels and zeroes representing white pixels.
                        
                        Experiment with this for a while, what kind of images can and can't you make with this, what else do we 
                        need?
                    """).foregroundColor(.white)
                        Image("blackwhiteimg")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .aspectRatio(contentMode: .fill)
                            
                    }
                    Spacer()
                    HStack {
                        Text("""
                        If we allow each pixel to use **2** bits this time, we can double the colours we can use, and now have
                        grey. Now, rather than each pixel being 0 or 1, each can be 00, 01, 10, or 11, each representing a 
                        different brightness, and allowing us to make images like this.
                        """).foregroundColor(.white)
                        Image("greyimg")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .aspectRatio(contentMode: .fill)
                    }
                                        
                    HStack {
                        Text("""
                        Let's double the number of bits available to us again, to 4 bits per pixel. This brings us all the way up
                        to **16** different colours, letting us make all sorts of pictures! 
                        """).foregroundColor(.white)
                        Image("colourimg")
                            .resizable()
                            .frame(width: 350, height: 250)
                            .aspectRatio(contentMode: .fill)
                    }
                    
                    Text("""
                        As you might have noticed, every time we double the number of pixels, the number of colours we can represent is **squared**.
                        In other words, when we go from one 1 bit to 2 to 4 to 8, we go from 2 colours to 4 to 16 to 256. Most TVs and monitors use
                        24-bit colour, that's 8 bits just for each colour channel (red, green, and blue) or 16,777,216 in total!
                        Some even have 32-bit color -- Over 4 **billion**!
                    """).foregroundColor(.white)
                        .focusable(true)
                }
                .padding()
                
                #if os(iOS)
                Divider()
                    .background(Color.white)
                    .padding(.vertical, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("4-Bit Color Image Builder")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ColorPixelBuilderView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                }
                .padding()
                #endif
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
        }
    }
}

struct ImgView_Previews: PreviewProvider {
    static var previews: some View {
        ImgView()
    }
}

#if os(iOS)
struct ColorPixelBuilderView: View {
    let palette: [Color] = [
        .black, .white, .red, .green,
        .blue, .yellow, .orange, .purple,
        .pink, .gray, .brown, .cyan,
        .mint, .indigo, .teal, Color("#32CD32")
    ]
    
    let gridSize: Int = 16
    
    @State private var pixels: [Int] = Array(repeating: 0, count: 256)
    
    @State private var selectedColor: Int = 0
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    @State private var ColumnSpacing: CGFloat = UIDevice.current.orientation.isLandscape ? -800 : -450
    
    var body: some View {
        VStack {
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
                ForEach(0..<pixels.count, id: \.self) { index in
                    Rectangle()
                        .fill(palette[pixels[index]])
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            pixels[index] = selectedColor
                        }
                }
            }
            .padding()
            Text(String(ColumnSpacing.description))
            HStack {
                Button(action: resetGrid) {
                    Text("Reset")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    func resetGrid() {
        pixels = Array(repeating: 0, count: 256)
    }
}
#endif
