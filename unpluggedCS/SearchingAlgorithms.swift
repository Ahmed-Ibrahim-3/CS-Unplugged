//
//  SearchView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class QRCodeViewModel: ObservableObject {
    @Published var qrCodeImage : UIImage?
    private let context = CIContext()
    
    func generateRandomQRCode(from urls: [String]) {
        guard let randomUrl = urls.randomElement() else { return }
        let data = Data(randomUrl.utf8)
        
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let scaleX = 200 / outputImage.extent.size.width
            let scaleY = 200 / outputImage.extent.size.height
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
                qrCodeImage = UIImage(cgImage: cgImage)
            }
        }
    }
}

struct SearchView: View {
    
    @StateObject private var qrCodeViewModel = QRCodeViewModel()
    
    var body: some View {
        VStack {
            Text("Searching Algorithms - Battleships!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                
            
            Spacer().frame(height: 50)
            HStack(spacing: 20) {
                NavigationLink(destination: Linear(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 1 - Linear Search")
                        
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: Binary(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 2 - Binary Search")
                        
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: Hashing(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 3- Hashing")
                        
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .interactiveArea()
            Spacer().frame(height: 100)
                
            
            Text("""
                 For this you will need : 
                   \u{2022} Any mobile device, preferably with the companion app
                   \u{2022} Someone to play against
                """)
            
            .font(.system(size: 35))
            Image(.search)
                .resizable()
                .frame(width: 300, height: 300, alignment: .bottom)
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
    }
}

struct Linear: View {
    
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
    
    private let tvOSUrls = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/LSearch4.png"
    ]
    
    private let iOSImages = ["L_A", "L_B", "L_C", "L_D"]
    
    @State private var selectedImage: String?
    
    var body: some View {
        #if os(tvOS)
        
        VStack {
            Text("Linear Search")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer().frame(height: 50)
            Text("""
                 In your pairs, scan the QR code below and keep your card to yourself.
                 Next, pick a ship under "My Ships" and circle or memorise it.
                 Tell your partner the ***number*** of your ship (not the letter!!)
                 """)
            Spacer().frame(height: 50)
            
            if let qrCodeImage = qrCodeViewModel.qrCodeImage {
                Button(action: {
                    qrCodeViewModel.generateRandomQRCode(from: tvOSUrls)
                }) {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 200, height: 200)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Tap to generate a new QR code")
            } else {
                Text("Generating QR Code...")
                    .onAppear {
                        qrCodeViewModel.generateRandomQRCode(from: tvOSUrls)
                    }
            }
            
            Spacer().frame(height: 50)
            Text("""
                 Now, in turns, guess the letter where your partner's ship is.
                 -- with each guess, one player gives a letter, and the other gives its number.
                 \u{2022} Keep count of how many guesses you have taken. At the end, write down the number of guesses you took.
                 \u{2022} Once you're finished, discuss amongst yourselves what the minimum
                   and maximum scores would have been, and how you could have optimized this.
                 """)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
        
        #elseif os(iOS)
        
        VStack {
            Text("Linear Search")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("""
                 In your pairs, scan the QR code below and keep your card to yourself. Next, pick a ship under "My Ships" and circle or memorise it. Tell your partner the ***number*** of your ship (not the letter!!)
                 
                 In turns, guess the letter where your partners ship is.
                     -- with each guess, one player gives a letter, and the other gives its number. Keep count of how many guesses you have taken.
                 At the end, write down the number of guesses you took.
                 """)
            .padding()
            Button("get new ships!") {
                selectedImage = iOSImages.randomElement()
            }
            .interactiveArea()
            
            if let img = selectedImage {
                Image(img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
            } else {
                Image(iOSImages.randomElement()!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
            }
            
            Text("""
                 Once you're finished, discuss amongst your pairs what the minimum and maximum scores would have been, and how could you have optimized this?
                 """)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
        
        #endif
    }
}

struct Binary: View {
    
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
    
    private let tvOSUrls = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/BSearch4.png"
    ]
    
    private let iOSImages = ["B_A", "B_B", "B_C", "B_D"]
    @State private var selectedImage: String?
    
    var body: some View {
        #if os(tvOS)
        VStack {
            Text("Binary Search Game")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer().frame(height: 50)
            
            VStack(spacing: 50) {
                Text("""
                     Again, in your pairs, scan the QR code below and keep your card to yourself.
                     Next, pick a ship under "My Ships" and circle or memorise it. 
                     Tell your partner the ***number*** of your ship (not the letter!!).
                     
                     **THIS TIME, ALL SHIPS WILL BE IN ASCENDING ORDER**
                     """)
                
                if let qrCodeImage = qrCodeViewModel.qrCodeImage {
                    Button(action: {
                        qrCodeViewModel.generateRandomQRCode(from: tvOSUrls)
                    }) {
                        Image(uiImage: qrCodeImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 200,height: 200)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text("Generating QR Code...")
                        .onAppear {
                            qrCodeViewModel.generateRandomQRCode(from: tvOSUrls)
                        }
                }
                
                Text("""
                     In turns, guess the letter where your partner's ship is.
                     -- with each guess, one player gives a letter, and the other gives its number.
                     \u{2022} Keep count of how many guesses you have taken. At the end, write down the number.
                     \u{2022} Once you're finished, discuss the min and max scores, and how to optimize.
                     """)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
        
        #elseif os(iOS)
        VStack {
            Text("Binary Search")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                        
            Text("""
                 Tell your partner the ***number*** of your ship (not the letter!!). **THIS TIME, ALL SHIPS WILL BE IN ASCENDING ORDER**.
                 
                 In turns, guess the letter where your partner's ship is.
                 -- with each guess, one player gives a letter, and the other gives its number.
                 Keep count of your guesses. 
                 """)
            .padding()
            
            Button("get new ships!") {
                selectedImage = iOSImages.randomElement()
            }
            .interactiveArea()
            
            if let img = selectedImage {
                Image(img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
            } else {
                Image(iOSImages.randomElement()!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
            }
            
            Text("""
                 Once you're finished, discuss the min and max scores, and how to optimize. How does it compare to the other methods?
                 """).padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
        
        #endif
    }
}

struct Hashing: View {
    
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
    
    private let tvOS_A = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/Images/Search/Hashing/A/hashing1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Hashing/A/hashing2.png"
    ]
    private let tvOS_B = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/Images/Search/Hashing/B/hashing1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Hashing/B/hashing2.png"
    ]
    
    private let iOS_A = ["A_1", "A_2"]
    private let iOS_B = ["B_1", "B_2"]
    
    @State private var selectedPlayer: Int? = nil
    @State private var selectedImage: String?
    
    var body: some View {
        #if os(tvOS)
        
        VStack {
            Text("Searching with Hashing")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer().frame(height: 50)
            
            VStack(spacing: 50) {
                Text("""
                     Each player scans one of the two codes below. Keep the card to yourself.
                     Pick a ship under "My Ships" and circle or memorise it. 
                     Tell your partner the ***number*** of your ship (not the letter!!).
                     
                     In this game, you can find out which column (0-9) the ship belongs to 
                     by adding the digits of the ship's number, and using the last digit of the sum.
                     """)
                HStack {
                    VStack {
                        Text("Player 1:")
                        if let qrCodeImage = qrCodeViewModel.qrCodeImage {
                            Button(action: {
                                qrCodeViewModel.generateRandomQRCode(from: tvOS_A)
                            }) {
                                Image(uiImage: qrCodeImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .frame(width: 200, height: 200)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Text("Generating QR Code...")
                                .onAppear {
                                    qrCodeViewModel.generateRandomQRCode(from: tvOS_A)
                                }
                        }
                    }
                    
                    VStack {
                        Text("Player 2:")
                        if let qrCodeImage = qrCodeViewModel.qrCodeImage {
                            Button(action: {
                                qrCodeViewModel.generateRandomQRCode(from: tvOS_B)
                            }) {
                                Image(uiImage: qrCodeImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .frame(width: 200, height: 200)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Text("Generating QR Code...")
                                .onAppear {
                                    qrCodeViewModel.generateRandomQRCode(from: tvOS_B)
                                }
                        }
                    }
                }
                
                Text("""
                     Play as before, but use the new hashing strategy. 
                     \u{2022} Discuss which ships are easiest/hardest to find. 
                     \u{2022} Which searching strategy is fastest, and why?
                     \u{2022} What are advantages and disadvantages of each one?
                     """)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
        
        #elseif os(iOS)

        VStack {
            Text("Searching with Hashing")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                        
            Text("""
                 Decide who will be Player 1 or Player 2. In this game, you can find out which column (0-9) the ship belongs to by adding together the digits of the ship's number,  then using the last digit of the sum.
                 """)
            .padding()
            
            if let selectedPlayer = selectedPlayer, let selectedImage = selectedImage {
                Text("Player \(selectedPlayer)")
                    .font(.title)
                Image(selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
            } else {
                Image(systemName: "questionmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding()
                    .foregroundColor(.gray)
            }
            
            HStack {
                Button("Player 1") {
                    selectedImage = iOS_A.randomElement()
                    selectedPlayer = 1
                }
                .foregroundStyle(.yellow)
                .padding()
                Spacer().frame(width: 50)
                Button("Player 2") {
                    selectedImage = iOS_B.randomElement()
                    selectedPlayer = 2
                }
                .foregroundStyle(.green)
            }
            .padding()
            .interactiveArea()
            Text("""
                 \u{2022} Play the game as before, but using the hashing strategy. 
                 \u{2022} Which ships are easiest/hardest to find? 
                 \u{2022} Which strategy is fastest, and why?
                 \u{2022} Pros/cons of each approach?
                 """)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
        
        #endif
    }
}

#Preview {
    @Previewable @StateObject var qrCodeViewModel = QRCodeViewModel()
//    Hashing(qrCodeViewModel: qrCodeViewModel)
    SearchView()
}
