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
                .foregroundColor(.white)
            
            Spacer().frame(height: 50)
#if os(tvOS)
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
                    Text("Game 3- Hashing")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
#elseif os(iOS)
            HStack(spacing: 20) {
                NavigationLink(destination: iOSLinear()) {
                    Text("Game 1 - Linear Search")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .foregroundColor(.white)
                }
                
                NavigationLink(destination: iOSBinary()) {
                    Text("Game 2 - Binary Search")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .foregroundColor(.white)
                }
                
                NavigationLink(destination: iOSHashing()) {
                    Text("Game 3 - Hashing")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .foregroundColor(.white)
                }
            }
#endif
            Spacer().frame(height: 100)
            
            Text("""
                 For this you will need : 
                   \u{2022} Any mobile device, preferably with the companion app
                   \u{2022} Someone to play against
                """)
            .foregroundColor(.white)
            .font(.system(size: 35))
            Image(.search)
                .resizable()
                .frame(width: 300, height: 300, alignment: .bottom)
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
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
        VStack{
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}
struct iOSLinear : View{
    @State private var img: String?
    private let images = ["L_A", "L_B", "L_C", "L_D"]

    var body : some View{
        VStack{
            Text("Linear Search")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            Spacer()
                .frame(width: 100 , height:  70)
            Text("""
                Tell your partner the ***number*** of your ship (not the letter!!)
                
                In turns, guess the letter where your partners ship is.
                    -- with each guess, one player gives a letter, and the other gives its number
                Keep count of how many guesses you have taken at the end, write down \n the number of guesses you took
                """)
            .padding()
            .foregroundColor(.white)
            Button("get new ships!") {
                img = images.randomElement()
            }
            .foregroundStyle(.red)
            if let img = img {
                Image(img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
            } else {
                Image(images.randomElement()!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
            }
            Text("""
                Once youre finished, discuss amongst your pairs what the minimum 
                and maximum scores would have been? and how could you have optimised this 
                """)
            .foregroundColor(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
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
        VStack{
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}
struct iOSBinary : View{
    @State private var img: String?
    private let images = ["B_A", "B_B", "B_C", "B_D"]

    var body : some View{
        VStack{
            Text("Binary Search")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            Spacer()
                .frame(width: 100 , height:  50)
            Text("""
                Tell your partner the ***number*** of your ship (not the letter!!)
                **THIS TIME, ALL SHIPS WILL BE IN ASCENDING ORDER**
                
                
                In turns, guess the letter where your partners ship is.
                    -- with each guess, one player gives a letter, and the other gives its number
                Keep count of how many guesses you have taken at the end, write down \n the number of guesses you took
                """)
            .foregroundColor(Color.white)
            .padding()
            Button("get new ships!") {
                img = images.randomElement()
            }
            .foregroundStyle(.red)
            if let img = img {
                Image(img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
            } else {
                Image(images.randomElement()!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
            }
            Text("""
                Once youre finished, discuss amongst your pairs what the minimum 
                and maximum scores would have been? and how could you have optimised this? 
                How does it compare to the other method(s)?
                """)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
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
        VStack{
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}
struct iOSHashing: View {
    @State private var img: String?
    @State private var selectedPlayer: Int? = nil // Track the selected player

    private let Aimages = ["A_1", "A_2"]
    private let Bimages = ["B_1", "B_2"]

    var body: some View {
        VStack {
            Text("Searching with Hashing")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)

            Spacer()
                .frame(height: 50)

            Text("""
                Tell your partner the ***number*** of your ship (not the letter!!). Decide who will be player 1 and player 2 now before moving forward.
                
                In this game, you can find out which column (0-9) the ship belongs to. Add together
                the digits of the ship's number, and the last digit is the column. For example,
                to find 2345, do 2+3+4+5, giving 14. The last digit is 4, so the ship must be
                in column 4. 
                
                Press the player number you were given, and **not** the other (the game will not work otherwise).
                In turns, guess the letter where your partner's ship is.
                    -- with each guess, one player gives a letter, and the other gives its number.
                Keep count of how many guesses you have taken at the end, write down 
                the number of guesses you took.
                """)
            .foregroundColor(.white)
            .padding()

            if let img = img, let selectedPlayer = selectedPlayer {
                VStack {
                    Text("Player \(selectedPlayer)")
                        .font(.title)
                        .foregroundColor(.white)
                    Image(img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 600, height: 300)
                        .padding()
                }
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
                    img = Aimages.randomElement()
                    selectedPlayer = 1
                }
                .foregroundStyle(.yellow)

                Button("Player 2") {
                    img = Bimages.randomElement()
                    selectedPlayer = 2
                }
                .foregroundStyle(.green)
            }
            .padding()

            Text("""
                Play the game as before, but this time using the new searching strategy. 
                
                Once you're finished, discuss amongst your pairs what ships are easiest/hardest to find? Which of the searching strategies is fastest? And why?
                
                What are the advantages and disadvantages of each one? What might speed up or slow down each one?
                """)
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}


#Preview {
    @Previewable @StateObject var qrCodeViewModel = QRCodeViewModel()
    //Linear(qrCodeViewModel: qrCodeViewModel)
    //iOSLinear()
    SearchView()
}
