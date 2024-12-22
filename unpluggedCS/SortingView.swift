//
//  SortingView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct SortingView : View {
    var body : some View{
        VStack{
            Text("Sorting Algorithms")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            
            HStack(spacing: 10) {
                NavigationLink(destination: selection()) {
                    Text("Selection Sort")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: quick()) {
                    Text("Quick Sort")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: insertion()) {
                    Text("Insertion Sort")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: bubble()) {
                    Text("Bubble Sort")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: merge()) {
                    Text("Merge Sort")
                        .foregroundColor(.white)
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            AnimatedImage(name: "sorting.gif")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400,height: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}

struct CircleItem: Identifiable,Equatable {
    let id = UUID()
    let color: Color
    let number: Int
}

struct toSort: View {
    @Binding var circles: [CircleItem]
    @State private var selectedCircleID: UUID? = nil
    @FocusState private var focusedCircleID: UUID?

    var body: some View {
        VStack{
            VStack(spacing: 50) {
                HStack(spacing: 25) {
                    ForEach(circles) { circle in
                        Button(action: {
                            handleCircleTap(id: circle.id)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(circle.color)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedCircleID == circle.id ? Color.gray : Color.clear, lineWidth: 4)
                                    )
                                
                                Text("\(circle.number)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        .focused($focusedCircleID, equals: circle.id)
                    }
                }
                
                Button(action: {
                    circles.shuffle()
                    selectedCircleID = nil
                }) {
                    Text("Shuffle!")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .buttonStyle(.plain)
            }
            .onAppear {
                focusedCircleID = circles.first?.id
            }
        }
    }
    
    private func handleCircleTap(id: UUID) {
        if let firstSelectedID = selectedCircleID,
           let firstIndex = circles.firstIndex(where: { $0.id == firstSelectedID }),
           let secondIndex = circles.firstIndex(where: { $0.id == id }) {
            circles.swapAt(firstIndex, secondIndex)
            selectedCircleID = nil
        } else {
            selectedCircleID = id
        }
    }
}

struct selection : View {
    @State private var circles: [CircleItem] = [
        CircleItem(color: Color(.systemRed), number: 1),
        CircleItem(color: Color(.systemOrange), number: 2),
        CircleItem(color: Color(.systemYellow), number: 3),
        CircleItem(color: Color(.systemGreen), number: 4),
        CircleItem(color: Color(.systemBlue), number: 5),
        CircleItem(color: Color(.systemIndigo), number: 6),
        CircleItem(color: Color(.systemPurple), number: 7)
    ]
    

    var body: some View {
        VStack{
            Text("Selection Sort")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
            
            toSort(circles: $circles)
            
            Text("What to do: ").font(.title3)
            Text("""
                \u{2022} Shuffle the list so that they are in random order
                \u{2022} Find the smallest value, and move it to the front.
                \u{2022} Find the next smallest value, and move that to the
                            right of the smallest value. 
                \u{2022} Continue until the list is sorted (numbers are 1 to 7,
                            colours are in a rainbow)
                \u{2022} When you're finished, double check to make sure the
                            order is correct.
            """)
            Text("Discuss the following: ").font(.title3)
            Text("""
                \u{2022} How many comparisons did this take?
                \u{2022} What is the worst case list for this method?
                \u{2022} How many comparisons would it have taken in the
                            worst case? 
                \u{2022} What is the best case list for this method?
                \u{2022} How does this scale with having more elements in the list
            """)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}
    
struct quick : View {
    @State private var circles: [CircleItem] = [
        CircleItem(color: Color(.systemRed), number: 1),
        CircleItem(color: Color(.systemOrange), number: 2),
        CircleItem(color: Color(.systemYellow), number: 3),
        CircleItem(color: Color(.systemGreen), number: 4),
        CircleItem(color: Color(.systemBlue), number: 5),
        CircleItem(color: Color(.systemIndigo), number: 6),
        CircleItem(color: Color(.systemPurple), number: 7)
    ]
    
    var body: some View {
        VStack {
            Text("Quick Sort")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            
            toSort(circles:$circles)
            
            Text("What to do: ").font(.title3).foregroundColor(.white)
            Text("""
                    \u{2022} Shuffle the list so that they are in random order
                    \u{2022} Choose one element at random, this is your **pivot**.
                    \u{2022} Move everything smaller than it to its left, and 
                                everything bigger to its right
                    \u{2022} Choose one of the groups either side of the pivot
                                and repeat the process
                    \u{2022} Keep repeating until every group only has one element,
                                the list will now be sorted
                """).foregroundColor(.white)
            Text("Discuss the following: ").font(.title3).foregroundColor(.white)
            Text("""
                    \u{2022} How many comparisons did this take?
                    \u{2022} What is the worst case for this method?
                    \u{2022} How many comparisons would it have taken in the
                                worst case? 
                    \u{2022} How does this scale with having more elements in the list
                    \u{2022} Why is this better than selection sort?
                """).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}

struct insertion: View {
    @State private var availableCircles: [CircleItem] = [
        CircleItem(color: Color(.systemRed), number: 1),
        CircleItem(color: Color(.systemOrange), number: 2),
        CircleItem(color: Color(.systemYellow), number: 3),
        CircleItem(color: Color(.systemGreen), number: 4),
        CircleItem(color: Color(.systemBlue), number: 5),
        CircleItem(color: Color(.systemIndigo), number: 6),
        CircleItem(color: Color(.systemPurple), number: 7)
    ]

    @State private var selectedCircles: [CircleItem?] = Array(repeating: nil, count: 7)
    @State private var selectedCircle: CircleItem? = nil

    private func selectCircleToMove(circle: CircleItem) {
        if selectedCircle == nil {
            selectedCircle = circle
            availableCircles.removeAll { $0.id == circle.id }
        }
    }

    private func placeCircle(at index: Int) {
        if let circle = selectedCircle, selectedCircles[index] == nil {
            selectedCircles[index] = circle
            selectedCircle = nil
        }
    }

    private func clearSelectedCircles() {
        if let circle = selectedCircle {
            availableCircles.append(circle)
            selectedCircle = nil
        }
        availableCircles.append(contentsOf: selectedCircles.compactMap { $0 })
        selectedCircles = Array(repeating: nil, count: 7)
    }

    private func shuffleAvailableCircles() {
        availableCircles.shuffle()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Subviews.TitleSection()
                Subviews.InstructionsSection()
                Subviews.SortedCirclesView(
                    selectedCircles: $selectedCircles,
                    selectedCircle: $selectedCircle,
                    placeCircle: placeCircle
                )
                Subviews.UnsortedCirclesView(
                    availableCircles: availableCircles,
                    selectedCircle: $selectedCircle,
                    selectCircleToMove: selectCircleToMove
                )
                Subviews.ActionButtons(
                    clearSelectedCircles: clearSelectedCircles,
                    shuffleAvailableCircles: shuffleAvailableCircles
                )
#if os(tvOS)
                Spacer().frame(height: 200)
#endif
                Subviews.DiscussionSection()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }

    fileprivate enum Subviews {
        struct TitleSection: View {
            var body: some View {
                Text("Insertion Sort")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.white)
            }
        }

        struct InstructionsSection: View {
            var body: some View {
                Text("""
                    **What to do:**
                        \u{2022} Select one element from the unsorted group.
                        \u{2022} Place it into its correct position in the sorted group.
                        \u{2022} Repeat until all elements have been moved to the sorted group, and are all in order.
                    """)
                .foregroundColor(.white)
            }
        }

        struct SortedCirclesView: View {
            @Binding var selectedCircles: [CircleItem?]
            @Binding var selectedCircle: CircleItem?
            var placeCircle: (Int) -> Void

            var body: some View {
                VStack {
                    Text("Sorted")
                        .font(.title3)
                        .foregroundColor(.white)
                    HStack(spacing: 20) {
                        ForEach(selectedCircles.indices, id: \.self) { index in
                            Button(action: {
                                placeCircle(index)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(selectedCircles[index]?.color ?? Color.gray.opacity(0.4))
                                        .frame(width: 50, height: 50)
                                    if let circle = selectedCircles[index] {
                                        Text("\(circle.number)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .background(selectedCircle != nil && selectedCircles[index] == nil ? Color.blue.opacity(0.3) : Color.clear)
                        }
                    }
                }
            }
        }

        struct UnsortedCirclesView: View {
            var availableCircles: [CircleItem]
            @Binding var selectedCircle: CircleItem?
            var selectCircleToMove: (CircleItem) -> Void

            var body: some View {
                VStack {
                    Text("Unsorted")
                        .font(.title3)
                        .foregroundColor(.white)
                    HStack(spacing: 20) {
                        ForEach(availableCircles) { circle in
                            Button(action: {
                                selectCircleToMove(circle)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(circle.color)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedCircle == circle ? Color.white : Color.clear, lineWidth: 4)
                                        )
                                    Text("\(circle.number)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }

        struct ActionButtons: View {
            var clearSelectedCircles: () -> Void
            var shuffleAvailableCircles: () -> Void

            var body: some View {
                HStack {
                    Button(action: {
                        clearSelectedCircles()
                    }) {
                        Text("Clear Sorted")
                            .font(.system(size: 40))
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(width: 350)
                    }
                    Button(action: {
                        shuffleAvailableCircles()
                    }) {
                        Text("Shuffle Unsorted")
                            .font(.system(size: 40))
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(width: 350)
                    }
                }
            }
        }

        struct DiscussionSection: View {
            var body: some View {
                VStack {
                    Text("Discuss the following: ")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("""
                        \u{2022} How many comparisons did this take?
                        \u{2022} What is the worst case for this method?
                        \u{2022} How many comparisons would it have taken in the worst case? 
                        \u{2022} What is the best case list for this method?
                        \u{2022} How does this scale with having more elements in the list
                        """)
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct bubble : View {
    @State private var circles: [CircleItem] = [
        CircleItem(color: Color(.systemRed), number: 1),
        CircleItem(color: Color(.systemOrange), number: 2),
        CircleItem(color: Color(.systemYellow), number: 3),
        CircleItem(color: Color(.systemGreen), number: 4),
        CircleItem(color: Color(.systemBlue), number: 5),
        CircleItem(color: Color(.systemIndigo), number: 6),
        CircleItem(color: Color(.systemPurple), number: 7)
    ]
    var body: some View {
        VStack{
            Text("Bubble Sort")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            
            toSort(circles:$circles)
            
            Text("What to do: ").font(.title3).foregroundColor(.white)
            Text("""
                    \u{2022} Shuffle the list so that they are in random order
                    \u{2022} Start at the front of the list and go through to the end,
                                swapping any adjacent elements that are in the wrong order.
                    \u{2022} If the list is now sorted, you're done! Otherwise, go back
                                and repeat from the start of the list.
                    \u{2022} Continue to repeat, swapping elements until the list is
                                in order.
                """).foregroundColor(.white)
            Text("Discuss the following: ").font(.title3).foregroundColor(.white)
            Text("""
                    \u{2022} How many comparisons did this take?
                    \u{2022} What is the worst case for this method?
                    \u{2022} How many comparisons would it have taken in the
                                worst case? 
                    \u{2022} How does this scale with having more elements in the list
                    \u{2022} How does this compare with the other methods?
                """).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}

struct merge : View {
    var body: some View {
        Text("placeholder")
    }
}

#Preview {
    SortingView()
    //selection()
    //quick()
    //insertion()
    //bubble()
    //merge()
}
