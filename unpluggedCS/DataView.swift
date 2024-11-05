//
//  DataView.swift
//  unpluggedCS
//
//  Created by Ahmed Ibrahim on 17/10/2024.
//
import SwiftUI

struct DataView : View {
    var body : some View{
        Text("Data Structures")
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
            .padding()
        HStack(spacing:30){
            VStack{
                Text("Array").font(.title3)
                
                Text("""
                        In memory, all the elements in
                        in an array are stored in contiguous
                        memory locations, meaning they are 
                        next to each other in memory. If we
                        initialise an array, its elements 
                        will be allocated sequentially in 
                        memory, allowing for efficient
                        access and manipulation of elements
                    """)
                .scaledToFill()
                
                Image("arraymem")
                    .resizable()
                    .frame(width: 500,height: 100)
                
                Text("""
                        Lets say we were trying to create a
                        variable to represent the marks for
                        each student in a class. We could use
                        several normal variables, but this
                        becomes difficult to manage if we 
                        have many values to track. The idea of 
                        an arry is to store many instances
                        in one variable. 
                    """)
                .scaledToFill()
            }
            
            
            VStack(spacing: 10){
                Text("Queue").font(.title3)
                Text("""
                        A queue is a linear data structure
                        that follows the First In First Out
                        principle, so the element inserted 
                        first is the first to leave. 
                    """)
                .scaledToFill()
                
                Image("queue")
                    .resizable()
                    .frame(width: 500,height: 100)
                
                Text("""
                     We define a queue to be a list in which
                    all additions are made at one end and all
                    deletions are made at the other. A queue, 
                    as the name suggestsm is like a line of
                    people waiting to buy an item. The first
                    person to enter the queue is the first 
                    person to be able to buy it, and the 
                    last in the  queue is the last to be able
                    to buy it. There are different types of
                    queue in computing science:
                    \u{2022} Simple Queue
                    \u{2022} Double ended Queue
                    \u{2022} Circular Queue
                    \u{2022} Priority Queue                    
                """
                )
                .scaledToFill()
            }
            
            VStack{
                Text("Stack").font(.title3)
                Text("""
                    A stack is another linear data
                    structure, this time following
                    the Last In First Out principle,
                    meaning the last element inserted
                    is the first element to be removed
                    """)
                .scaledToFill()
                
                Image("stack")
                    .resizable()
                    .frame(width: 300,height: 200)
                Text("""
                    Imagine a pile of plates kept on top of
                    each other. The plate which was put on 
                    last is the only one we can (safely) access
                    and remove. Since we can only remove the
                    plate that is at the top, we can say that
                    the plate that was put last comes out first.
                    A stack can be fixed size or dynamic. A fixed
                    size stack cannot grow or shrink, and if it 
                    gets full, no more can be added to it. A 
                    dynamic stack on the other hand changes 
                    size when elements are added.
                    
                    """)
                .scaledToFill()
            }
            
        }
    }
}


