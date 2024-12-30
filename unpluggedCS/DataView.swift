// TODO: Fix tvOS scrolling issue
import SwiftUI

enum DataStructureType {
    case array
    case queue
    case stack
}

struct DataView: View {
    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView {
                VStack {
                    Text("Data Structures")
                        .font(.system(size: 60))
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.white)
                    
                    VStack(spacing: 50) {
                        DataStructureView(
                            type: .array,
                            title: "Array",
                            description1: """
                            In memory, all the elements in
                            an array are stored in contiguous
                            memory locations, meaning they are
                            next to each other in memory. If we
                            initialise an array, its elements
                            will be allocated sequentially in
                            memory, allowing for efficient
                            access and manipulation of elements
                        """,
                            imageName: "arraymem",
                            imageSize: CGSize(width: 300, height: 100),
                            description2: """
                            Let's say we were trying to create a
                            variable to represent the marks for
                            each student in a class. We could use
                            several normal variables, but this
                            becomes difficult to manage if we
                            have many values to track. The idea of
                            an array is to store many instances
                            in one variable.
                        """,
                            scrollProxy: proxy
                        )
                        .id(DataStructureType.array)
                        
                        DataStructureView(
                            type: .queue,
                            title: "Queue",
                            description1: """
                            A queue is a linear data structure
                            that follows the First In First Out
                            principle, so the element inserted
                            first is the first to leave.
                        """,
                            imageName: "queue",
                            imageSize: CGSize(width: 300, height: 100),
                            description2: """
                            We define a queue to be a list in which
                            all additions are made at one end and all
                            deletions are made at the other. A queue,
                            as the name suggests, is like a line of
                            people waiting to buy an item. The first
                            person to enter the queue is the first
                            person to be able to buy it, and the
                            last in the queue is the last to be able
                            to buy it. There are different types of
                            queues in computing science:
                            • Simple Queue
                            • Double ended Queue
                            • Circular Queue
                            • Priority Queue
                        """,
                            scrollProxy: proxy
                        )
                        .id(DataStructureType.queue)
                        
                        DataStructureView(
                            type: .stack,
                            title: "Stack",
                            description1: """
                            A stack is another linear data
                            structure, this time following
                            the Last In First Out principle,
                            meaning the last element inserted
                            is the first element to be removed.
                        """,
                            imageName: "stack",
                            imageSize: CGSize(width: 300, height: 200),
                            description2: """
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
                        """,
                        scrollProxy: proxy
                        )
                        .id(DataStructureType.array)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient)
        }
    }
}

struct DataStructureView: View {
    let type: DataStructureType
    let title: String
    let description1: String
    let imageName: String
    let imageSize: CGSize
    let description2: String
    let scrollProxy: ScrollViewProxy
    
    @State private var arrayElements: [String] = []
    @State private var queueElements: [String] = []
    @State private var stackElements: [String] = []
    
    @State private var elementCount: Int = 0
    
    @FocusState private var isButtonFocused: Bool
    
    private var elementSpacing: CGFloat {
        #if os(tvOS)
        return 5
        #else
        return 10
        #endif
    }
    
    var body: some View {
        content
        #if os(tvOS)
            .focusSection()
        #endif
    }
    
    private var content: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title3)
                .foregroundColor(.white)
            
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(description1)
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                InteractiveView()
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(description2)
                        .font(.body)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding([.leading, .trailing], 10)
        .onChange(of: currentElements()) { newValue in
            if newValue.isEmpty {
                elementCount = 0
            }
        }
    }
    
    @ViewBuilder
    private func InteractiveView() -> some View {
        VStack(spacing: 20) {
            Spacer()
            switch type {
            case .array:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: elementSpacing) {
                        ForEach(arrayElements.indices, id: \.self) { index in
                            Text(arrayElements[index])
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .cornerRadius(8)
                                .transition(.scale)
                        }
                    }
                    .animation(.default, value: arrayElements)
                }
                .frame(height: 50)
                
            case .queue:
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: elementSpacing){
                        ForEach(queueElements, id: \.self) { element in
                            Text(element)
                                .padding()
                                .background(Color.green.opacity(0.7))
                                .cornerRadius(8)
                                .transition(.scale)
                        }
                    }
                    .animation(.default, value: queueElements)
                }
                .frame(height: 50)
                
            case .stack:
                VStack(spacing: elementSpacing) {
                    ForEach(stackElements.reversed(), id: \.self) { element in
                        Text(element)
                            .padding()
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                            .transition(.scale)
                    }
                }
                .animation(.default, value: stackElements)
                .frame(height: 200)
            }
            Spacer()

            HStack(spacing: 20) {
                Button(action: addElement) {
                    Text("Add")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .hoverEffect(.highlight)
                .buttonStyle(.plain)
                .focused($isButtonFocused)
                .onChange(of: isButtonFocused) { focused in
                    if focused {
                        withAnimation {
                            scrollProxy.scrollTo(type, anchor: .center)
                        }
                    }
                }
                Button(action: removeElement) {
                    Text("Remove")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .hoverEffect(.highlight)
                .buttonStyle(.plain)
                .focused($isButtonFocused)
                .onChange(of: isButtonFocused) { focused in
                    if focused {
                        withAnimation {
                            scrollProxy.scrollTo(type, anchor: .center)
                        }
                    }
                }
                
            }
        }
    }
        
    private func addElement() {
        elementCount += 1
        let newElement = "\(type == .array ? "A" : type == .queue ? "Q" : "S")\(elementCount)"
        
        withAnimation {
            switch type {
            case .array:
                arrayElements.append(newElement)
            case .queue:
                queueElements.append(newElement)
            case .stack:
                stackElements.append(newElement)
            }
        }
    }
    
    private func removeElement() {
        withAnimation {
            switch type {
            case .array:
                if !arrayElements.isEmpty {
                    arrayElements.removeLast()
                }
            case .queue:
                if !queueElements.isEmpty {
                    queueElements.removeFirst()
                }
            case .stack:
                if !stackElements.isEmpty {
                    stackElements.removeLast()
                }
            }
        }
    }
    
    private func currentElements() -> [String] {
        switch type {
        case .array:
            return arrayElements
        case .queue:
            return queueElements
        case .stack:
            return stackElements
        }
    }
}


#Preview{
    DataView()
}

