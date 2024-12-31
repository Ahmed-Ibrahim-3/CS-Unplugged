//
//  HCIView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct HCIView : View {
    
    @State var doors = ["glassDoor",
                        "hingeDoor",
                        "knobDoor",
                        "labeledDoor",
                        "panelDoor",
                        "plainDoor",
                        "pushBarDoor",
                        "slidingDoor"]
    
    let correctAnswers: [String: String] = [
        "glassDoor"   : "Pull Right",
        "hingeDoor"   : "Push Right",
        "knobDoor"    : "Pull Right",
        "labeledDoor" : "Pull Right",
        "panelDoor"   : "Push",
        "plainDoor"   : "Push Left",
        "pushBarDoor" : "Push",
        "slidingDoor" : "Slide Right"
    ]
    
    let possibleChoices = [
            "Push",
            "Push Left",
            "Push Right",
            "Pull",
            "Pull Left",
            "Pull Right",
            "Slide",
            "Slide Left",
            "Slide Right"
        ]
    
    @State private var currentDoorIndex = 0
    @State private var isAnswered = false
    @State private var answerFeedback: String = ""
    @State private var score = 0
    
    let columns = [
        GridItem(.fixed(120)),
        GridItem(.fixed(120)),
        GridItem(.fixed(120))
    ]
    
    var body: some View {
        VStack {
            Text("Human-Computer Interaction")
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
            
            Text("""
            Human Computer interaction is about designing, evaluating, and implementing computer sytems in a way that lets people use them productively and safely. Since computers are so common now, and are everyday tools that everyone uses, as computer scientists we need to pay attention to the human interface of both hardware and software.

            Consider the doors below...
            How might you open them? Which side do they open on? Do they open in or out? how do you know?
            """)
            .padding(.horizontal)
            
            if currentDoorIndex >= doors.count {
                
                Text("Quiz Completed!")
                    .font(.headline)
                    .padding()
                
                Text("Your score: \(score) / \(doors.count)")
                    .font(.title)
                    .padding()
                
            } else {
                HStack {
                    Text("How do you think you open this?")
                        .padding()
                    
                    Spacer()
                    
                    Image(doors[currentDoorIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    Spacer()
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(possibleChoices, id: \.self) { choice in
                            Button {
                                handleAnswer(choice)
                            } label: {
                                Text(choice)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(buttonBackgroundColor(for: choice))
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(isAnswered)
                        }
                    }
                    .frame(maxWidth: 400)
                    .padding()
                }
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                .padding()
                
                if isAnswered {
                    Text(answerFeedback)
                        .font(.headline)
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                nextQuestion()
                            }
                        }
                }
                
                Text("""
                What did you look for to find an answer? Which doors were easiest to get right? We use the same principles in computer science so that users can clearly understand how to use our products without needing much explanation. HCI makes technology more accessible, efficient, and enjoyable to use. Good HCI improves the uesr experience, usability, functionality, and accessibility of systems, and without it.
                """)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
    }
        
    func buttonBackgroundColor(for choice: String) -> Color {
            guard isAnswered else {
                return .blue
            }
            let door = doors[currentDoorIndex]
            let correctAnswer = correctAnswers[door, default: ""]
            return choice == correctAnswer ? .green : .red
        }
    
    func handleAnswer(_ userChoice: String) {
        isAnswered = true
        
        let door = doors[currentDoorIndex]
        let correctAnswer = correctAnswers[door] ?? ""
        
        if userChoice == correctAnswer {
            answerFeedback = "Correct!"
            score += 1
        } else {
            answerFeedback = "Oops! The correct answer is \(correctAnswer)."
        }
    }
    
    func nextQuestion() {
        currentDoorIndex += 1
        isAnswered = false
        answerFeedback = ""
    }
}

#Preview {
    HCIView()
}
