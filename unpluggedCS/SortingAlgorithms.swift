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
                
            
            HStack(spacing: 10) {
                NavigationLink(destination: selection()) {
                    Text("Selection Sort")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: bubble()) {
                    Text("Bubble Sort")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: quick()) {
                    Text("Quick Sort")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: insertion()) {
                    Text("Insertion Sort")
                        .frame(width: 250)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }.interactiveArea()
            
            AnimatedImage(name: "sorting.gif")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400,height: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundStyle(.white)
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
                        
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .buttonStyle(.plain)
            }
            .onAppear {
                focusedCircleID = circles.first?.id
            }
        }.interactiveArea()
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
        .foregroundStyle(.white)
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
                
            
            toSort(circles:$circles)
            
            Text("What to do: ").font(.title3)
            Text("""
                    \u{2022} Shuffle the list so that they are in random order
                    \u{2022} Choose one element at random, this is your **pivot**.
                    \u{2022} Move everything smaller than it to its left, and 
                                everything bigger to its right
                    \u{2022} Choose one of the groups either side of the pivot
                                and repeat the process
                    \u{2022} Keep repeating until every group only has one element,
                                the list will now be sorted
                """)
            Text("Discuss the following: ").font(.title3)
            Text("""
                    \u{2022} How many comparisons did this take?
                    \u{2022} What is the worst case for this method?
                    \u{2022} How many comparisons would it have taken in the
                                worst case? 
                    \u{2022} How does this scale with having more elements in the list
                    \u{2022} Why is this better than selection sort?
                """)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundStyle(.white)
    }
}

struct insertion: View {
    
    @State private var circles: [CircleItem] = [
        CircleItem(color: Color(.systemRed),    number: 1),
        CircleItem(color: Color(.systemOrange), number: 2),
        CircleItem(color: Color(.systemYellow), number: 3),
        CircleItem(color: Color(.systemGreen),  number: 4),
        CircleItem(color: Color(.systemBlue),   number: 5),
        CircleItem(color: Color(.systemIndigo), number: 6),
        CircleItem(color: Color(.systemPurple), number: 7)
    ]
    
    @State private var selectedCircle: CircleItem? = nil
    
    private func selectCircle(at index: Int) {
        guard selectedCircle == nil else { return }
        selectedCircle = circles.remove(at: index)
    }
    

    private func placeCircle(at index: Int) {
        guard let circle = selectedCircle else { return }
        circles.insert(circle, at: index)
        selectedCircle = nil
    }
        
    private func shuffleCircles() {
        circles.shuffle()
        selectedCircle = nil
    }
        
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Subviews.TitleSection()
                Subviews.InstructionsSection()
                
                VStack{
                    Subviews.InPlaceCirclesView(
                        circles: $circles,
                        selectedCircle: $selectedCircle,
                        selectCircle: selectCircle,
                        placeCircle: placeCircle
                    )
                    
                    Subviews.ActionButtons(
                        shuffleCircles: shuffleCircles
                    )
                }
                .interactiveArea()
                
                Subviews.DiscussionSection()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
    }
}

extension insertion {
    fileprivate enum Subviews {
        
        struct TitleSection: View {
            var body: some View {
                Text("Insertion Sort")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        
        struct InstructionsSection: View {
            var body: some View {
                Text("""
                    **What to do:**
                    1. Insertion sort compares adjacent values in a list from left to right
                    2. Starting from the **second** value, compare this with the value to its right, if they are in the wrong order, swap them
                    3. After swapping a value, compare the value in its new position with the value to its left, swap them if they are in the wrong order
                    4. When doing a comparison, if the values are alraedy in the correct order, move to the right and compare the next values.
                    5. Repeat this process until the list is fully sorted. 
                    """)
            }
        }
        struct InPlaceCirclesView: View {
            @Binding var circles: [CircleItem]
            @Binding var selectedCircle: CircleItem?
            
            var selectCircle: (Int) -> Void
            var placeCircle: (Int) -> Void
            
            var body: some View {
                VStack {
                    HStack(spacing: 20) {
                        
                        ForEach(circles.indices, id: \.self) { index in
                            Button(action: {
                                handleTap(index: index)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(circles[index].color)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    (selectedCircle?.id == circles[index].id) ?
                                                    Color.white : Color.clear,
                                                    lineWidth: 4
                                                )
                                        )
                                    Text("\(circles[index].number)")
                                        .font(.headline)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        if selectedCircle != nil {
                            Button(action: {
                                placeCircle(circles.count)
                            }) {
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .opacity(0.8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            
            private func handleTap(index: Int) {
                if selectedCircle == nil {
                    selectCircle(index)
                } else {
                    placeCircle(index)
                }
            }
        }
        
        struct ActionButtons: View {
            var shuffleCircles: () -> Void
            
            var body: some View {
                HStack {
                    
                    Button(action: shuffleCircles) {
                        Text("Shuffle!")
                            .font(.system(size: 25))
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
        }
        
        struct DiscussionSection: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Discuss the following:")
                        .font(.title3)
                    Text("""
                        • How many comparisons did this take?
                        • What is the worst case for insertion sort?
                        • How many comparisons would it have taken in the worst case?
                        • What is the best case list for insertion sort?
                        • How does this scale with having more elements in the list?
                        """)
                }
                .padding(.top)
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
                
            
            toSort(circles:$circles)
            
            Text("What to do: ").font(.title3)
            Text("""
                    \u{2022} Shuffle the list so that they are in random order
                    \u{2022} Start at the front of the list and go through to the end,
                                swapping any adjacent elements that are in the wrong order.
                    \u{2022} If the list is now sorted, you're done! Otherwise, go back
                                and repeat from the start of the list.
                    \u{2022} Continue to repeat, swapping elements until the list is
                                in order.
                """)
            Text("Discuss the following: ").font(.title3)
            Text("""
                    \u{2022} How many comparisons did this take?
                    \u{2022} What is the worst case for this method?
                    \u{2022} How many comparisons would it have taken in the
                                worst case? 
                    \u{2022} How does this scale with having more elements in the list
                    \u{2022} How does this compare with the other methods?
                """)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
        .foregroundColor(.white)
    }
}

#Preview {
//    SortingView()
//    selection()
//    quick()
    insertion()
//    bubble()
}
