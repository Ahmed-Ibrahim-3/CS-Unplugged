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
    
    let Bimages = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search4.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search5.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search6.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search7.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/images/Search/search8.png"
    ]
    
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
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Linear/Lsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Linear/Lsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Linear/Lsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Linear/LSearch4.png"
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

    var Limages = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Binary/Bsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Binary/Bsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Binary/Bsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Binary/BSearch4.png"
    ]
    var body: some View {
        Text("Binary Search Game")
    }
}

struct Hashing: View {
    
    @ObservedObject var qrCodeViewModel: QRCodeViewModel

    var body: some View {
        Text("Hashing Game")
    }
}
#Preview {
    SearchView() //(name:"test")
}
