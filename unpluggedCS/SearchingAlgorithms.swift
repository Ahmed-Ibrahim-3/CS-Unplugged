//
//  SearchView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - View Models

/// ViewModel responsible for generating QR codes for the search algorithm games
class QRCodeViewModel: ObservableObject {
    /// The generated QR code image
    @Published var qrCodeImage: UIImage?
    
    /// Core Image context for rendering
    private let context = CIContext()
    
    /// Generates a QR code from a randomly selected URL in the provided array
    /// - Parameter urls: Array of URL strings to choose from
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

// MARK: - Main View

/// Main view displaying the different search algorithm games available
struct SearchView: View {
    // MARK: Properties
    
    /// ViewModel for QR code generation
    @StateObject private var qrCodeViewModel = QRCodeViewModel()
    
    private let instructionsText = """
    For this you will need : 
      \u{2022} Any mobile device, preferably with the companion app
      \u{2022} Someone to play against
    """
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Text("Searching Algorithms - Battleships!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Spacer().frame(height: 50)
            
            HStack(spacing: 20) {
                NavigationLink(destination: Linear(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 1 - Linear Search")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .accessibilityHint("Navigate to the linear search game")
                }
                
                NavigationLink(destination: Binary(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 2 - Binary Search")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .accessibilityHint("Navigate to the binary search game")
                }
                
                NavigationLink(destination: Hashing(qrCodeViewModel: qrCodeViewModel)) {
                    Text("Game 3 - Hashing")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .accessibilityHint("Navigate to the hashing game")
                }
            }
            .interactiveArea()
            
            Spacer().frame(height: 100)
            
            Text(instructionsText)
                .font(.system(size: 35))
                .accessibilityLabel("Game requirements")
            
            // Illustration
            Image(.search)
                .resizable()
                .frame(width: 300, height: 300, alignment: .bottom)
                .accessibilityLabel("Illustration of searching")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
    }
}

// MARK: - Linear Search Game

/// View for the Linear Search game
struct Linear: View {
    // MARK: Properties
    
    /// Shared QR code view model
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
    
    /// URLs for QR codes on tvOS
    private let tvOSUrls = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/Lsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Linear/LSearch4.png"
    ]
    
    /// Image names for iOS devices
    private let iOSImages = ["L_A", "L_B", "L_C", "L_D"]
    
    /// Currently selected image name
    @State private var selectedImage: String?
    
    // MARK: Content Text
    
    private let tvOSSetupText: LocalizedStringKey = """
    In your pairs, scan the QR code below and keep your card to yourself.
    Next, pick a ship under "My Ships" and circle or memorise it.
    Tell your partner the ***number*** of your ship (not the letter!!)
    """
    
    private let tvOSGameInstructionsText: LocalizedStringKey = """
    Now, in turns, guess the letter where your partner's ship is.
    -- with each guess, one player gives a letter, and the other gives its number.
    \u{2022} Keep count of how many guesses you have taken. At the end, write down the number of guesses you took.
    \u{2022} Once you're finished, discuss amongst yourselves what the minimum
      and maximum scores would have been, and how you could have optimized this.
    """
    
    private let iOSInstructionsText: LocalizedStringKey = """
    In your pairs, scan the QR code below and keep your card to yourself. Next, pick a ship under "My Ships" and circle or memorise it. Tell your partner the ***number*** of your ship (not the letter!!)
    
    In turns, guess the letter where your partners ship is.
        -- with each guess, one player gives a letter, and the other gives its number. Keep count of how many guesses you have taken.
    At the end, write down the number of guesses you took.
    """
    
    private let iOSDiscussionText: LocalizedStringKey = """
    Once you're finished, discuss amongst your pairs what the minimum and maximum scores would have been, and how could you have optimized this?
    """
    
    // MARK: Body
    
    var body: some View {
#if os(tvOS)
        // tvOS implementation
        VStack {
            Text("Linear Search")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Spacer().frame(height: 50)
            
            Text(tvOSSetupText)
                .accessibilityLabel("Setup instructions for linear search game")
            
            Spacer().frame(height: 50)
            
            // QR Code display
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
                .accessibilityLabel("QR code for game board")
                .accessibilityHint("Tap to generate a new QR code")
            } else {
                Text("Generating QR Code...")
                    .onAppear {
                        qrCodeViewModel.generateRandomQRCode(from: tvOSUrls)
                    }
            }
            
            Spacer().frame(height: 50)
            
            Text(tvOSGameInstructionsText)
                .padding()
                .accessibilityLabel("Game instructions and discussion prompts")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
        
#elseif os(iOS)
        // iOS implementation
        VStack {
            Text("Linear Search")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Text(iOSInstructionsText)
                .padding()
                .accessibilityLabel("Game instructions for linear search")
            
            // New ships button
            Button("Get new ships!") {
                selectedImage = iOSImages.randomElement()
            }
            .interactiveArea()
            .accessibilityHint("Generates a new random game board")
            
            // Game board image
            if let img = selectedImage {
                Image(img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
                    .accessibilityLabel("Game board with ships arranged for linear search")
            } else {
                Image(iOSImages.randomElement()!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
                    .accessibilityLabel("Game board with ships arranged for linear search")
                    .onAppear {
                        selectedImage = iOSImages.randomElement()
                    }
            }
            
            Text(iOSDiscussionText)
                .padding()
                .accessibilityLabel("Discussion prompts for after the game")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
        
#endif
    }
}

// MARK: - Binary Search Game

/// View for the Binary Search game
struct Binary: View {
    // MARK: Properties
    
    /// Shared QR code view model
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
    
    /// URLs for QR codes on tvOS
    private let tvOSUrls = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch2.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/Bsearch3.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/Images/Search/Binary/BSearch4.png"
    ]
    
    /// Image names for iOS devices
    private let iOSImages = ["B_A", "B_B", "B_C", "B_D"]
    
    /// Currently selected image name
    @State private var selectedImage: String?
    
    // MARK: Content Text
    
    private let tvOSSetupText: LocalizedStringKey = """
    Again, in your pairs, scan the QR code below and keep your card to yourself.
    Next, pick a ship under "My Ships" and circle or memorise it. 
    Tell your partner the ***number*** of your ship (not the letter!!).
    
    **THIS TIME, ALL SHIPS WILL BE IN ASCENDING ORDER**
    """
    
    private let tvOSGameInstructionsText: LocalizedStringKey = """
    In turns, guess the letter where your partner's ship is.
    -- with each guess, one player gives a letter, and the other gives its number.
    \u{2022} Keep count of how many guesses you have taken. At the end, write down the number.
    \u{2022} Once you're finished, discuss the min and max scores, and how to optimize.
    """
    
    private let iOSSetupText: LocalizedStringKey = """
    Tell your partner the ***number*** of your ship (not the letter!!). **THIS TIME, ALL SHIPS WILL BE IN ASCENDING ORDER**.
    
    In turns, guess the letter where your partner's ship is.
    -- with each guess, one player gives a letter, and the other gives its number.
    Keep count of your guesses. 
    """
    
    private let iOSDiscussionText: LocalizedStringKey = """
    Once you're finished, discuss the min and max scores, and how to optimize. How does it compare to the other methods?
    """
    
    // MARK: Body
    
    var body: some View {
#if os(tvOS)
        // tvOS implementation
        VStack {
            Text("Binary Search Game")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Spacer().frame(height: 50)
            
            VStack(spacing: 50) {
                Text(tvOSSetupText)
                    .accessibilityLabel("Setup instructions for binary search game")
                
                // QR Code display
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
                    .accessibilityLabel("QR code for binary search game board")
                    .accessibilityHint("Tap to generate a new QR code")
                } else {
                    Text("Generating QR Code...")
                        .onAppear {
                            qrCodeViewModel.generateRandomQRCode(from: tvOSUrls)
                        }
                }
                
                // Game instructions
                Text(tvOSGameInstructionsText)
                    .accessibilityLabel("Game instructions and discussion prompts")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
        
#elseif os(iOS)
        // iOS implementation
        VStack {
            Text("Binary Search")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Text(iOSSetupText)
                .padding()
                .accessibilityLabel("Instructions for binary search game")
            
            // New ships button
            Button("Get new ships!") {
                selectedImage = iOSImages.randomElement()
            }
            .interactiveArea()
            .accessibilityHint("Generates a new random game board")
            
            // Game board image
            if let img = selectedImage {
                Image(img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .accessibilityLabel("Game board with ships in ascending order for binary search")
            } else {
                Image(iOSImages.randomElement()!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .accessibilityLabel("Game board with ships in ascending order for binary search")
                    .onAppear {
                        selectedImage = iOSImages.randomElement()
                    }
            }
            
            Text(iOSDiscussionText)
                .padding()
                .accessibilityLabel("Discussion prompts for after the game")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
        
#endif
    }
}

// MARK: - Hashing Game

/// View for the Hashing search game
struct Hashing: View {
    // MARK: Properties
    
    /// Shared QR code view model
    @ObservedObject var qrCodeViewModel: QRCodeViewModel
    
    /// URLs for Player 1 QR codes on tvOS
    private let tvOS_A = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/Images/Search/Hashing/A/hashing1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Hashing/A/hashing2.png"
    ]
    
    /// URLs for Player 2 QR codes on tvOS
    private let tvOS_B = [
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/blob/main/unpluggedCS/Images/Search/Hashing/B/hashing1.png",
        "https://github.com/Ahmed-Ibrahim-3/CS-Unplugged/tree/main/unpluggedCS/images/Search/Hashing/B/hashing2.png"
    ]
    
    /// Image names for Player 1 on iOS
    private let iOS_A = ["A_1", "A_2"]
    
    /// Image names for Player 2 on iOS
    private let iOS_B = ["B_1", "B_2"]
    
    /// Currently selected player (1 or 2)
    @State private var selectedPlayer: Int? = nil
    
    /// Currently selected image name
    @State private var selectedImage: String?
    
    // MARK: Content Text
    
    private let tvOSSetupText: LocalizedStringKey = """
    Each player scans one of the two codes below. Keep the card to yourself.
    Pick a ship under "My Ships" and circle or memorise it. 
    Tell your partner the ***number*** of your ship (not the letter!!).
    
    In this game, you can find out which column (0-9) the ship belongs to 
    by adding the digits of the ship's number, and using the last digit of the sum.
    """
    
    private let tvOSGameInstructionsText: LocalizedStringKey = """
    Play as before, but use the new hashing strategy. 
    \u{2022} Discuss which ships are easiest/hardest to find. 
    \u{2022} Which searching strategy is fastest, and why?
    \u{2022} What are advantages and disadvantages of each one?
    """
    
    private let iOSSetupText: LocalizedStringKey = """
    Decide who will be Player 1 or Player 2. In this game, you can find out which column (0-9) the ship belongs to by adding together the digits of the ship's number, then using the last digit of the sum.
    """
    
    private let iOSDiscussionText: LocalizedStringKey = """
    \u{2022} Play the game as before, but using the hashing strategy. 
    \u{2022} Which ships are easiest/hardest to find? 
    \u{2022} Which strategy is fastest, and why?
    \u{2022} Pros/cons of each approach?
    """
    
    // MARK: Body
    
    var body: some View {
#if os(tvOS)
        // tvOS implementation
        VStack {
            Text("Searching with Hashing")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Spacer().frame(height: 50)
            
            VStack(spacing: 50) {
                Text(tvOSSetupText)
                    .accessibilityLabel("Setup instructions for hashing game")
                
                // QR Codes
                HStack {
                    // Player 1 QR Code
                    VStack {
                        Text("Player 1:")
                            .fontWeight(.bold)
                        
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
                            .accessibilityLabel("QR code for Player 1")
                            .accessibilityHint("Tap to generate a new QR code")
                        } else {
                            Text("Generating QR Code...")
                                .onAppear {
                                    qrCodeViewModel.generateRandomQRCode(from: tvOS_A)
                                }
                        }
                    }
                    
                    // Player 2 QR Code
                    VStack {
                        Text("Player 2:")
                            .fontWeight(.bold)
                        
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
                            .accessibilityLabel("QR code for Player 2")
                            .accessibilityHint("Tap to generate a new QR code")
                        } else {
                            Text("Generating QR Code...")
                                .onAppear {
                                    qrCodeViewModel.generateRandomQRCode(from: tvOS_B)
                                }
                        }
                    }
                }
                
                Text(tvOSGameInstructionsText)
                    .accessibilityLabel("Game instructions and discussion prompts")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
        
#elseif os(iOS)
        // iOS implementation
        VStack {
            Text("Searching with Hashing")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Text(iOSSetupText)
                .padding()
                .accessibilityLabel("Instructions for hashing game")
            
            // Player selection display
            if let selectedPlayer = selectedPlayer, let selectedImage = selectedImage {
                Text("Player \(selectedPlayer)")
                    .font(.title)
                    .fontWeight(.bold)
                
                Image(selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 600, height: 300)
                    .padding()
                    .accessibilityLabel("Game board for Player \(selectedPlayer)")
            } else {
                Image(systemName: "questionmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding()
                    .foregroundColor(.gray)
                    .accessibilityLabel("No player selected yet")
            }
            
            // Player selection buttons
            HStack {
                Button("Player 1") {
                    selectedImage = iOS_A.randomElement()
                    selectedPlayer = 1
                }
                .foregroundStyle(.yellow)
                .padding()
                .accessibilityHint("Select Player 1 game board")
                
                Spacer().frame(width: 50)
                
                Button("Player 2") {
                    selectedImage = iOS_B.randomElement()
                    selectedPlayer = 2
                }
                .foregroundStyle(.green)
                .padding()
                .accessibilityHint("Select Player 2 game board")
            }
            .padding()
            .interactiveArea()
            
            Text(iOSDiscussionText)
                .accessibilityLabel("Discussion prompts for after the game")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appBackgroundGradient)
        .foregroundColor(.white)
        
        #endif
    }
}

// MARK: - Preview Provider

#Preview {
    // For testing, create a preview QRCodeViewModel
    @Previewable @StateObject var qrCodeViewModel = QRCodeViewModel()
    
    // Uncomment the desired preview:
    // Hashing(qrCodeViewModel: qrCodeViewModel) // Swap Hashing out for any of the other algorithm structs
    SearchView()
}
