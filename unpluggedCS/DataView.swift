import SwiftUI

struct DataView : View {
    var body : some View {
        VStack {
            Text("Data Structures")
                .font(.system(size: 60))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
            HStack(spacing: 30) {
                DataStructureView(
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
                    imageSize: CGSize(width: 350, height: 100),
                    description2: """
                        Let's say we were trying to create a
                        variable to represent the marks for
                        each student in a class. We could use
                        several normal variables, but this
                        becomes difficult to manage if we
                        have many values to track. The idea of
                        an array is to store many instances
                        in one variable.
                    """
                ).foregroundColor(.white)

                DataStructureView(
                    title: "Queue",
                    description1: """
                        A queue is a linear data structure
                        that follows the First In First Out
                        principle, so the element inserted
                        first is the first to leave.
                    """,
                    imageName: "queue",
                    imageSize: CGSize(width: 325, height: 100),
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
                    """
                ).foregroundColor(.white)

                DataStructureView(
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
                    """
                ).foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }
}

struct DataStructureView: View {
    let title: String
    let description1: String
    let imageName: String
    let imageSize: CGSize
    let description2: String

    var body: some View {
        VStack(spacing: 10) {
            Text(title).font(.title3)
            Text(description1).scaledToFill()
            Image(imageName)
                .resizable()
                .frame(width: imageSize.width, height: imageSize.height)
            Text(description2).scaledToFill()
        }
        //TODO: Interactive visualisations of each data structure
    }
}

#Preview {
    DataView()
}
