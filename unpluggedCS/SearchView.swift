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
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer().frame(height: 50)
            
            HStack(spacing: 20) {
                NavigationLink(destination: Linear(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 1 - Linear Search")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: Binary(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 2 - Binary Search")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: Hashing(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 3 - Hashing")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            
            Spacer().frame(height: 100)
            
            Text("""
                 For this you will need : 
                   \u{2022} Any device with a camera (tablet, phone, etc...)
                   \u{2022} Someone to play against
                """)
            .font(.system(size: 35))
            //let searchimage = Image("unpluggedCS/images/search/search.png")
            Image(.search)
                .resizable()
                .frame(width: 300, height: 300, alignment: .bottom)
            
        }
        .padding()
    }
}

struct Linear: View {
    
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
   
    private let Limages = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/LSearch4.png"
    ]
    var body: some View {
        Text("Linear Search")
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
            .padding()
        
        Spacer().frame(height: 50)
        Text("""
                In your pairs, scan the QR code below and keep your card to yourself
                Next, pick a ship under "My Ships" and circle or memorise it
                Tell your partner the ***number*** of your ship (not the letter!!)
            """)
        Spacer().frame(height: 50)
        
        if let qrCodeImage = qrCodeViewModel.qrCodeImage {
            Button(action: {
                qrCodeViewModel.generateRandomQRCode(from: Limages)
            }) {
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 200,height: 200)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Tap to generate a new QR code")
        } else {
            Text("Generating QR Code...")
                .onAppear{
                    qrCodeViewModel.generateRandomQRCode(from: Limages)
                }
        }
        
        Spacer().frame(height: 50)
        Text("""
                Now, in turns, guess the letter where your partners ship is.
                    -- with each guess, one player gives a letter, and the
                        other gives its number
                Keep count of how many guesses you have taken at the end, write down \n the number of guesses you took
                Once youre finished, discuss amongst your pairs what the minimum 
                and maximum scores would have been? and how could you have optimised
                this 
             """)
    }
}

struct Binary: View {

    @ObservedObject var qrCodeViewModel: QRCodeViewModel

    var Bimages = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/BSearch4.png"
    ]
    var body: some View {
        
        Text("Binary Search Game")
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
            .padding()
        
        Spacer().frame(height: 50)
        
        VStack(spacing: 50){
            Text("""
                    Again, In your pairs, scan the QR code below and keep your card to yourself
                    Next, pick a ship under "My Ships" and circle or memorise it
                    Tell your partner the ***number*** of your ship (not the letter!!)
                
                      **THIS TIME, ALL SHIPS WILL BE IN ASCENDING ORDER**
                """)
            
            if let qrCodeImage = qrCodeViewModel.qrCodeImage {
                Button(action: {
                    qrCodeViewModel.generateRandomQRCode(from: Bimages)
                }) {
                    Image(uiImage: qrCodeImage)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 200,height: 200)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Tap to generate a new QR code")
            } else {
                Text("Generating QR Code...")
                    .onAppear{
                        qrCodeViewModel.generateRandomQRCode(from: Bimages)
                    }
            }
            
            Text("""
                    Now, in turns, guess the letter where your partners ship is.
                        -- with each guess, one player gives a letter, and the
                            other gives its number
                    Keep count of how many guesses you have taken at the end, write down \n the number of guesses you took
                    Once youre finished, discuss amongst your pairs what the minimum 
                    and maximum scores would have been? and how could you have optimised
                    this 
                 """)
        }
    }
}

struct Hashing: View {
    
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
    
    var images_A = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/Images/Search/Hashing/A/hashing1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Hashing/A/hashing2.png"
    ]
    
    var images_B = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/Images/Search/Hashing/B/hashing1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Hashing/B/hashing2.png"
    ]
    
    var body: some View {
        
        Text("Searching with Hashing")
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
            .padding()
        
        Spacer().frame(height: 50)
        
        VStack(spacing: 50){
            Text("""
                    This time, each player scans one of the two codes below, again,keep the card to
                    yourself. pick a ship under "My Ships" and 
                    circle or memorise it. Tell your partner the ***number*** of your ship
                        (not the letter!!)
                
                    In this game, you can find out which column (0-9) the ship belongs to. Add together
                    the digits of the ships number, and the last digit is the column. For example,
                    to find 2345, do 2+3+4+5, giving 14. The lastdigit is 4, so the ship must be
                    in column 4. 
                """)
            HStack{
                Text("Player 1: ")
                if let qrCodeImage = qrCodeViewModel.qrCodeImage {
                    Button(action: {
                        qrCodeViewModel.generateRandomQRCode(from: images_A)
                    }) {
                        Image(uiImage: qrCodeImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 200,height: 200)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Tap to generate a new QR code")
                } else {
                    Text("Generating QR Code...")
                        .onAppear{
                            qrCodeViewModel.generateRandomQRCode(from: images_B)
                        }
                }
                Text("Player 2: ")
                if let qrCodeImage = qrCodeViewModel.qrCodeImage {
                    Button(action: {
                        qrCodeViewModel.generateRandomQRCode(from: images_A)
                    }) {
                        Image(uiImage: qrCodeImage)
                            .resizable()
                            .interpolation(.none)
                            .frame(width: 200,height: 200)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Tap to generate a new QR code")
                } else {
                    Text("Generating QR Code...")
                        .onAppear{
                            qrCodeViewModel.generateRandomQRCode(from: images_B)
                        }
                }
            }
            
            
            Text("""
                    Play the game as before, but this time using the new searching strategy. 
                    Once youre finished, discuss amongst your pairs what ships are easiest/hardest
                    to find? which of the searching strategies is fastest? and why?
                    What are the advantages and disadvantages of each one? What might speed up or 
                    slow down each one?
                 """)
        }
    }
}

#Preview {
    @StateObject var qrCodeViewModel = QRCodeViewModel()
    Hashing(qrCodeViewModel: qrCodeViewModel) //(name:"test")
}
