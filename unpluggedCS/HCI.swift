//
//  HCIView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI

// MARK: - View Model

/// ViewModel managing the state and logic for the HCI door quiz
@MainActor
class HCIViewModel: ObservableObject {
    /// List of door image names to be displayed in the quiz
    let doorImageNames = [
        "glassDoor",
        "hingeDoor",
        "knobDoor",
        "labeledDoor",
        "panelDoor",
        "plainDoor",
        "pushBarDoor",
        "slidingDoor"
    ]
    
    /// Mapping of door image names to their correct opening methods
    let correctAnswers: [String: [String]] = [
        "glassDoor"   : ["Pull Right"],
        "hingeDoor"   : ["Push Right"],
        "knobDoor"    : ["Pull Right"],
        "labeledDoor" : ["Pull Right"],
        "panelDoor"   : ["Push Right"],
        "plainDoor"   : ["Push Left"],
        "pushBarDoor" : ["Push Left", "Push Right"],
        "slidingDoor" : ["Slide Right"]
    ]
    
    /// All possible door opening choices presented to the user
    let possibleChoices = [
        "Push Left",
        "Push Right",
        "Pull Left",
        "Pull Right",
        "Slide Left",
        "Slide Right"
    ]
    
    @Published var currentDoorIndex = 0
    
    /// Whether the current question has been answered
    @Published var isAnswered = false
    
    /// Feedback text shown after answering a question
    @Published var answerFeedback: String = ""
    
    @Published var score = 0
    
    /// Provides a human-readable description of the door type for accessibility
    /// - Parameter doorImageName: The image name of the door
    /// - Returns: A descriptive string about the door type
    func doorTypeDescription(for doorImageName: String) -> String {
        switch doorImageName {
        case "glassDoor":
            return "Glass door with a handle"
        case "hingeDoor":
            return "Door with visible hinges"
        case "knobDoor":
            return "Door with a round doorknob"
        case "labeledDoor":
            return "Door with a label that says Pull"
        case "panelDoor":
            return "Door with a push panel"
        case "plainDoor":
            return "Plain door with no visible handles"
        case "pushBarDoor":
            return "Door with a horizontal bar"
        default:
            return "Door"
        }
    }
    
    /// Handles user selection of an answer
    /// - Parameter userChoice: The user's selected answer
    func handleAnswer(_ userChoice: String) {
        isAnswered = true
        
        let door = doorImageNames[currentDoorIndex]
        let correct = correctAnswers[door] ?? []
        
        if correct.contains(userChoice) {
            answerFeedback = "Correct!"
            score += 1
        } else {
            let joinedAnswers = correct.joined(separator: " or ")
            answerFeedback = "Oops! The correct answer is \(joinedAnswers)."
        }
    }
    
    /// Advances to the next question or completes the quiz
    func nextQuestion() {
        currentDoorIndex += 1
        isAnswered = false
        answerFeedback = ""
    }
    
    /// Determines the background color for an answer button based on whether it's correct
    /// - Parameter choice: The answer choice text
    /// - Returns: The appropriate color for the button background
    func buttonBackgroundColor(for choice: String) -> Color {
        guard isAnswered else { return .blue }
        
        let door = doorImageNames[currentDoorIndex]
        let correct = correctAnswers[door, default: []]
        return correct.contains(choice) ? .green : .red
    }
}

// MARK: - Main View

/// View that demonstrates Human-Computer Interaction principles through an interactive door quiz
struct HCIView: View {
    // MARK: Properties
    
    /// ViewModel controlling the quiz state and logic
    @StateObject private var viewModel = HCIViewModel()
    
    /// Grid layout for answer buttons
    let columns: [GridItem] = {
#if os(tvOS)
        return [
            GridItem(.fixed(250)),
            GridItem(.fixed(250)),
        ]
#else
        return [
            GridItem(.fixed(120)),
            GridItem(.fixed(120)),
        ]
#endif
    }()
    
    // MARK: Introduction Content
    
    /// Text explaining the concept of HCI and the purpose of the door quiz
    let introductionText = """
    Human Computer Interaction is about designing, evaluating, and implementing computer systems in a way that lets people use them productively and safely. Since computers are so common now, and are everyday tools that everyone uses, as computer scientists we need to pay attention to the human interface of both hardware and software.
    
    Consider the doors below...
    How might you open them? Which side do they open on? Do they open in or out? How do you know?
    """
    
    /// Text displayed after completing the quiz, explaining the significance of the exercise
    let conclusionText = """
    What did you look for to find an answer? Which doors were easiest to get right? 
    We use the same principles in computer science so that users can clearly 
    understand how to use our products without needing much explanation. HCI makes 
    technology more accessible, efficient, and enjoyable to use. Good HCI improves 
    the user experience, usability, functionality, and accessibility of systems.
    """
    
    // MARK: Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Human-Computer Interaction")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(introductionText)
                    .padding(.horizontal)
                
                // Show either quiz completion view or the current door question
                if viewModel.currentDoorIndex >= viewModel.doorImageNames.count {
                    quizCompletionView
                } else {
                    doorQuizView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(appBackgroundGradient)
            .foregroundColor(.white)
        }
    }
    
    // MARK: Subviews
    
    /// View displayed when the quiz is completed
    private var quizCompletionView: some View {
        VStack(spacing: 20) {
            Text("Quiz Completed!")
                .font(.headline)
                .padding()
                .accessibilityAddTraits(.isHeader)
            
            Text("Your score: \(viewModel.score) / \(viewModel.doorImageNames.count)")
                .font(.title)
                .padding()
                .accessibilityLabel("Your final score is \(viewModel.score) out of \(viewModel.doorImageNames.count)")
            
            Text(conclusionText)
                .padding()
        }
    }
    
    /// View displaying the current door question
    private var doorQuizView: some View {
        VStack {
            HStack {
                Text("How do you think you open this?")
                    .padding()
                
                Spacer()
                
                // Current door image
                Image(viewModel.doorImageNames[viewModel.currentDoorIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .accessibilityLabel("Door image: \(viewModel.doorTypeDescription(for: viewModel.doorImageNames[viewModel.currentDoorIndex]))")
                
                Spacer()
                
                // Answer choices grid
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.possibleChoices, id: \.self) { choice in
                        Button {
                            viewModel.handleAnswer(choice)
                        } label: {
                            Text(choice)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(viewModel.buttonBackgroundColor(for: choice))
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.isAnswered)
                        .accessibilityLabel(choice)
                        .accessibilityHint("Select if you think this is how to open the door")
                        #if os(tvOS)
                        .frame(width: 250)
                        .padding()
                        .buttonStyle(PlainButtonStyle())
                        #endif
                    }
                }
                .padding()
            }
            .interactiveArea()
            
            // Feedback after answering
            if viewModel.isAnswered {
                Text(viewModel.answerFeedback)
                    .font(.headline)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            viewModel.nextQuestion()
                        }
                    }
            }
        }
    }
}

// MARK: - Preview Provider

#Preview {
    HCIView()
}
