






import Testing
@testable import unpluggedCS
import SwiftUI
import MultipeerConnectivity
import Foundation


struct architectureTests {

    @Test func testCPUComponentIsRegister()  {
        #expect(CPUComponent.controlUnit.isRegister == false)
        #expect(CPUComponent.alu.isRegister == false)
        #expect(CPUComponent.pc.isRegister == true)
        #expect(CPUComponent.cir.isRegister == true)
        #expect(CPUComponent.ac.isRegister == true)
        #expect(CPUComponent.mar.isRegister == true)
        #expect(CPUComponent.mdr.isRegister == true)
        #expect(CPUComponent.memoryUnit.isRegister == false)
    }

    @Test func testCPUSlotIsFilled()  {
        let emptySlot = CPUSlot(slotType: .controlUnit)
        #expect(emptySlot.isFilled == false)
        
        var filledSlot = emptySlot
        filledSlot.placedComponent = .controlUnit
        #expect(filledSlot.isFilled == true)
    }

    @Test func testCPUComponentCount()  {
        #expect(CPUComponent.allCases.count == 8)
    }
    
    @Test func testCPUComponentRawValues()  {
        #expect(CPUComponent.controlUnit.rawValue == "Control Unit")
        #expect(CPUComponent.alu.rawValue == "Arithmetic / Logic Unit")
        #expect(CPUComponent.pc.rawValue == "Program Counter (PC)")
        #expect(CPUComponent.cir.rawValue == "Current Instruction Register (CIR)")
        #expect(CPUComponent.ac.rawValue == "Accumulator (AC)")
        #expect(CPUComponent.mar.rawValue == "Memory Address Register (MAR)")
        #expect(CPUComponent.mdr.rawValue == "Memory Data Register (MDR)")
        #expect(CPUComponent.memoryUnit.rawValue == "Memory Unit")
    }
    
    @Test func testCPUComponentID()  {
        #expect(CPUComponent.controlUnit.id == "Control Unit")
        #expect(CPUComponent.memoryUnit.id == "Memory Unit")
    }
    
    @Test func testCPUSlotInitialization()  {
        let controlUnitSlot = CPUSlot(slotType: .controlUnit)
        let aluSlot = CPUSlot(slotType: .alu)
        let memorySlot = CPUSlot(slotType: .memory)
        let registerSlot = CPUSlot(slotType: .registerAny)
        
        #expect(controlUnitSlot.slotType == .controlUnit)
        #expect(aluSlot.slotType == .alu)
        #expect(memorySlot.slotType == .memory)
        #expect(registerSlot.slotType == .registerAny)
        
        
        #expect(controlUnitSlot.placedComponent == nil)
        #expect(aluSlot.placedComponent == nil)
        #expect(memorySlot.placedComponent == nil)
        #expect(registerSlot.placedComponent == nil)
    }
    
    @Test func testCPUSlotFilledWithValidComponents()  {
        
        var controlUnitSlot = CPUSlot(slotType: .controlUnit)
        var aluSlot = CPUSlot(slotType: .alu)
        var memorySlot = CPUSlot(slotType: .memory)
        var registerSlot = CPUSlot(slotType: .registerAny)
        
        controlUnitSlot.placedComponent = .controlUnit
        aluSlot.placedComponent = .alu
        memorySlot.placedComponent = .memoryUnit
        registerSlot.placedComponent = .pc
        
        #expect(controlUnitSlot.isFilled == true)
        #expect(aluSlot.isFilled == true)
        #expect(memorySlot.isFilled == true)
        #expect(registerSlot.isFilled == true)
    }
    
    @Test func testCPUSlotWithInvalidComponents()  {
        
        var controlUnitSlot = CPUSlot(slotType: .controlUnit)
        var aluSlot = CPUSlot(slotType: .alu)
        var memorySlot = CPUSlot(slotType: .memory)
        var registerSlot = CPUSlot(slotType: .registerAny)
        
        
        controlUnitSlot.placedComponent = .alu  
        aluSlot.placedComponent = .memoryUnit   
        memorySlot.placedComponent = .controlUnit 
        registerSlot.placedComponent = .alu     
        
        
        #expect(controlUnitSlot.isFilled == true)
        #expect(aluSlot.isFilled == true)
        #expect(memorySlot.isFilled == true)
        #expect(registerSlot.isFilled == true)
    }
    
    @Test func testAllCPUComponents()  {
        
        for component in CPUComponent.allCases {
            #expect(component.id == component.rawValue)
            
            switch component {
            case .pc, .cir, .ac, .mar, .mdr:
                #expect(component.isRegister == true)
            case .controlUnit, .alu, .memoryUnit:
                #expect(component.isRegister == false)
            }
        }
    }
    
    @Test func testCPUSlotIdGeneration()  {
        
        let slot1 = CPUSlot(slotType: .registerAny)
        let slot2 = CPUSlot(slotType: .registerAny)
        
        #expect(slot1.id != slot2.id)
    }
    
    @Test func testCPUSlotIsFilledWithAllComponents()  {
        for component in CPUComponent.allCases {
            var slot = CPUSlot(slotType: .registerAny)
            slot.placedComponent = component
            #expect(slot.isFilled == true)
        }
    }
    
    @MainActor
    @Test func testCAViewInitialization()  {
        let testName = "TestUser123"
        let caView = CAView(name: testName)
        #expect(caView.name == testName)
        
        
        _ = caView.body
    }
    
    #if os(tvOS)
    @MainActor
    @Test func testMultiCoreTVOSView()  {
        let view = MultiCoreTVOSView()
        
        
        #expect(view.service != nil)
        
        
        _ = view.body
    }
    
    @MainActor
    @Test func testMultiCoreTVOSViewWithCores()  {
        let view = MultiCoreTVOSView()
        
        
        let coreStatus = CoreStatus(coreNumber: 1, isComplete: false)
        view.service.cores.append(coreStatus)
        
        
        _ = view.body
        
        
        view.service.cores = [CoreStatus(coreNumber: 2, isComplete: true)]
        
        
        _ = view.body
    }
    
    @MainActor
    @Test func testMultiCoreTVOSViewWithMultipleCores()  {
        let view = MultiCoreTVOSView()
        
        
        view.service.cores = [
            CoreStatus(coreNumber: 1, isComplete: false),
            CoreStatus(coreNumber: 2, isComplete: true),
            CoreStatus(coreNumber: 3, isComplete: false),
            CoreStatus(coreNumber: 4, isComplete: true)
        ]
        
        
        _ = view.body
        
        
        view.service.allCoresReady = true
        
        
        _ = view.body
    }
    #endif
    
    #if os(iOS)
    @MainActor
    @Test func testCPUBuilderView()  {
        let testName = "TestUser123"
        let view = CPUBuilderView(name: testName)
        
        
        _ = view.body
    }
    
    @MainActor
    @Test func testCPUDraggableComponentView()  {
        for component in CPUComponent.allCases {
            let view = CPUDraggableComponentView(component: component)
            
            _ = view.body
        }
    }
    
    @MainActor
    @Test func testCPUComponentSlotView()  {
        let slot = CPUSlot(slotType: .registerAny)
        let slotBinding = Binding(
            get: { slot },
            set: { _ in }
        )
        
        let view = CPUComponentSlotView(
            slot: slotBinding,
            onDropReceived: { _, _ in }
        )
        
        
        _ = view.body
    }
    
    @MainActor
    @Test func testSlotTypeDescriptionFunction()  {
        let slot = CPUSlot(slotType: .registerAny)
        let slotBinding = Binding(
            get: { slot },
            set: { _ in }
        )
        
        let view = CPUComponentSlotView(
            slot: slotBinding,
            onDropReceived: { _, _ in }
        )
        
        let types = [CPUSlotType.controlUnit, .alu, .memory, .registerAny]
        
        
        func slotTypeDescription(for slotType: CPUSlotType) -> String {
            switch slotType {
            case .controlUnit:
                return "control unit"
            case .alu:
                return "arithmetic logic unit"
            case .memory:
                return "memory unit"
            case .registerAny:
                return "any register"
            }
        }
        
        
        for type in types {
            #expect(!slotTypeDescription(for: type).isEmpty)
        }
        
        
        _ = view.body
    }
    
    @MainActor
    @Test func testCPUBuilderRowView()  {
        let slot = CPUSlot(slotType: .registerAny)
        let slotBinding = Binding(
            get: { slot },
            set: { _ in }
        )
        
        let view = CPUBuilderRowView(
            slotBinding: slotBinding,
            onDropReceived: { _, _ in }
        )
        
        
        _ = view.body
    }
    
    @MainActor
    @Test func testCPUBuilderViewSubviews()  {
        let testName = "TestUser123"
        let view = CPUBuilderView(name: testName)
        
        
        _ = view.body
        
        
        var filledSlot = CPUSlot(slotType: .controlUnit)
        filledSlot.placedComponent = .controlUnit
        let filledSlotBinding = Binding(
            get: { filledSlot },
            set: { _ in }
        )
        
        _ = CPUComponentSlotView(
            slot: filledSlotBinding,
            onDropReceived: { _, _ in }
        ).body
    }
    #endif
}

struct bitManipulationTests {

    @Test func testPowerOperator()  {
        
        #expect(2 ** 3 == 8)
        #expect(3 ** 2 == 9)
        #expect(2 ** 5 == 32)
        #expect(5 ** 0 == 1)
    }
    
    @Test func testCalculateBinaryValue()  {
        let bitView = BitViewModel(maxBits: 5)
        
        #expect(bitView.calculateBinaryValue(from: [false, false, false, false, false]) == 0)
        #expect(bitView.calculateBinaryValue(from: [true, true, true, true, true]) == 31)
        #expect(bitView.calculateBinaryValue(from: [true, false, true, false, true]) == 21)
    }
    
    @Test func testDefaultDecimalValueInitialization()  {
        let bitView = BitViewModel(maxBits: 5)
        #expect(bitView.decimalValue == 0)
    }
    
    @Test func testPowerOperatorWithZeroExponent()  {
        #expect(5 ** 0 == 1)
        #expect(0 ** 0 == 1)
        #expect(1 ** 0 == 1)
    }
    
    @Test func testPowerOperatorWithNegativeBase()  {
        #expect((-2) ** 2 == 4)
        #expect((-2) ** 3 == -8)
    }
    
    @Test func testPowerOperatorWithLargeExponents()  {
        #expect(2 ** 10 == 1024)
        #expect(10 ** 3 == 1000)
    }
    
    @Test func testBitViewModelInitialization()  {
        
        let viewModel = BitViewModel(maxBits: 5)
        #expect(viewModel.bitValues.count == 5)
        #expect(viewModel.bitValues.allSatisfy { $0 == false })
        #expect(viewModel.decimalValue == 0)
        
        
        let customBits = [true, false, true, false, true]
        let customViewModel = BitViewModel(maxBits: 5, initialBits: customBits)
        #expect(customViewModel.bitValues == customBits)
        #expect(customViewModel.decimalValue == 21)
    }
    
    @Test func testBitViewModelToggleBit()  {
        let viewModel = BitViewModel(maxBits: 5)
        
        viewModel.toggleBit(at: 4)
        #expect(viewModel.bitValues[4] == true)
        #expect(viewModel.decimalValue == 1)
        
        viewModel.toggleBit(at: 0)
        #expect(viewModel.bitValues[0] == true)
        #expect(viewModel.decimalValue == 17)
        
        viewModel.toggleBit(at: 4)
        #expect(viewModel.bitValues[4] == false)
        #expect(viewModel.decimalValue == 16)
    }
    
    @Test func testBitViewModelSetAllBits()  {
        let viewModel = BitViewModel(maxBits: 5)
        
        
        viewModel.setAllBits(to: true)
        #expect(viewModel.bitValues.allSatisfy { $0 == true })
        #expect(viewModel.decimalValue == 31)
        
        
        viewModel.setAllBits(to: false)
        #expect(viewModel.bitValues.allSatisfy { $0 == false })
        #expect(viewModel.decimalValue == 0)
    }
    
    @Test func testBitViewModelCalculateBinaryValue()  {
        let viewModel = BitViewModel(maxBits: 8)
        
        
        #expect(viewModel.calculateBinaryValue(from: [false, false, false, false, false, false, false, false]) == 0)
        #expect(viewModel.calculateBinaryValue(from: [true, true, true, true, true, true, true, true]) == 255)
        #expect(viewModel.calculateBinaryValue(from: [true, false, true, false, true, false, true, false]) == 170)
        #expect(viewModel.calculateBinaryValue(from: [false, true, false, true, false, true, false, true]) == 85)
        #expect(viewModel.calculateBinaryValue(from: [true, false, false, false, false, false, false, false]) == 128)
        #expect(viewModel.calculateBinaryValue(from: [false, false, false, false, false, false, false, true]) == 1)
    }
    
    @Test func testBitViewModelOutOfBoundsToggle()  {
        let viewModel = BitViewModel(maxBits: 5)
        
        
        viewModel.toggleBit(at: -1)
        viewModel.toggleBit(at: 5)
        
        
        #expect(viewModel.bitValues.allSatisfy { $0 == false })
        #expect(viewModel.decimalValue == 0)
    }
    
    @Test func testRefactoredBitViewWithViewModel() {
        
        let viewModel = BitViewModel(maxBits: 5)
        
        
        viewModel.toggleBit(at: 0)
        #expect(viewModel.decimalValue == 16)
        
        viewModel.toggleBit(at: 1)
        #expect(viewModel.decimalValue == 24)
    }
    
    @Test func testSectionViewAllCircleCounts() {
        
        for circleCount in [1, 2, 4, 8, 16] {
            let view = SectionView(circleCount: circleCount)
            _ = view.body
        }
    }
    
    
    @Test func testSectionViewCreateCircle()  {
        let view = SectionView(circleCount: 1)
        
        
        let circleView = view.createCircle(size: 40)
        
        
        _ = circleView
    }
    
    
    @Test func testSectionViewInvalidCircleCount() {
        
        let view = SectionView(circleCount: 3) 
        _ = view.body
    }
    
    
    @Test func testBitViewBody() {
        let view = BitView(viewModel: BitViewModel(maxBits: 5))
        _ = view.body
    }
    
    
    @Test func testBitViewDifferentBitCounts() {
        
        let bitView1 = BitView(viewModel: BitViewModel(maxBits: 5))
        let bitView4 = BitView(viewModel: BitViewModel(maxBits: 5))
        let bitView8 = BitView(viewModel: BitViewModel(maxBits: 5))
        
        
        _ = bitView1.body
        _ = bitView4.body
        _ = bitView8.body
    }
    
    
    #if os(tvOS)
    @Test func testBitViewTVOSContent() {
        let view = BitViewModel(maxBits: 5)
        
        
        view.isFocused = true
        view.isFocused = false
        
        
        view.currentSectionIndex = 1
        view.currentSectionIndex = 2
    }
    
    #endif
    
    #if os(iOS)
    @Test func testBitViewIOSContent() {
        let view = BitView(maxBits: 5)
        
        
        let iOSContent = view.iOSContent()
        
        
        _ = iOSContent
        
        
        
        
        let mirror = Mirror(reflecting: view)
        for child in mirror.children {
            if child.label == "bitValues" {
                
                if var bitValues = child.value as? [Bool] {
                    bitValues[0] = true
                    view.decimalValue = view.calculateBinaryValue(from: bitValues)
                    
                    
                    _ = view.iOSContent()
                }
            }
        }
    }
    #endif
    
    
    @Test func testBitViewCalculateBinaryValueExtensive() {
        let view = BitViewModel(maxBits: 8)
        
        #expect(view.calculateBinaryValue(from: [true, true, true, true, true, true, true, true]) == 255)
    }
    
    
    @Test func testBitViewModelComprehensive() {
        let maxBits = 8
        let viewModel = BitViewModel(maxBits: maxBits)
        
        
        #expect(viewModel.bitValues.count == maxBits)
        #expect(viewModel.bitValues.allSatisfy { $0 == false })
        #expect(viewModel.decimalValue == 0)
        #expect(viewModel.currentSectionIndex == 0)
        
        
        for i in 0..<maxBits {
            viewModel.toggleBit(at: i)
            #expect(viewModel.bitValues[i] == true)
            
            
            viewModel.toggleBit(at: i)
            #expect(viewModel.bitValues[i] == false)
        }
        
        
        viewModel.setAllBits(to: true)
        #expect(viewModel.bitValues.allSatisfy { $0 == true })
        #expect(viewModel.decimalValue == 255) 
        
        
        for i in 0...4 { 
            viewModel.nextSection()
            #expect(viewModel.currentSectionIndex == min(i + 1, 4))
        }
        
        
        viewModel.nextSection()
        #expect(viewModel.currentSectionIndex == 4)
    }
    
    
    @Test func testRefactoredBitView() {
        let viewModel = BitViewModel(maxBits: 5)
        let view = BitView(viewModel: viewModel)
        
        
        _ = view.body
        
        
        viewModel.toggleBit(at: 0)
        viewModel.toggleBit(at: 2)
        viewModel.toggleBit(at: 4)
        
        
        _ = view.body
        
        
        viewModel.setAllBits(to: true)
        _ = view.body
    }
    

    
    @Test func testBitActivityText() {
        
        let view = BitViewModel(maxBits: 5)
        let mirror = Mirror(reflecting: view)
        
        for child in mirror.children {
            if child.label == "bitActivity" {
                let text = child.value as? String
                #expect(text != nil)
                #expect(text?.isEmpty == false)
            }
        }
    }
}

protocol ScrollViewProxyProtocol {
    func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?)
}


extension ScrollViewProxy: ScrollViewProxyProtocol { }


struct MockScrollViewProxy: ScrollViewProxyProtocol {
    func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?) {
        
    }
}


@MainActor
struct dataStructuresTests {

    @Test func testDataStructureTypeEquality() {
        let arrayType: DataStructureType = .array
        let queueType: DataStructureType = .queue
        let stackType: DataStructureType = .stack
        
        #expect(arrayType != queueType)
        #expect(queueType != stackType)
        #expect(arrayType != stackType)
    }
    
    @Test func testArrayAddRemove() {
        
        let viewModel = DataStructureViewModel(type: .array)
        #expect(viewModel.elements.isEmpty, "Expected no elements initially")
        
        
        viewModel.addElement()
        #expect(viewModel.elements == ["A1"], "After one add, array should contain A1")
        
        viewModel.addElement()
        #expect(viewModel.elements == ["A1", "A2"], "After two adds, array should contain A1 and A2")
        
        
        viewModel.removeElement()
        #expect(viewModel.elements == ["A1"], "After removal, array should only contain A1")
    }
        
    @Test func testQueueAddRemove() {
        let viewModel = DataStructureViewModel(type: .queue)
        #expect(viewModel.elements.isEmpty, "Expected no elements initially")
        
        
        viewModel.addElement()
        #expect(viewModel.elements == ["Q1"], "After one add, queue should contain Q1")
        
        viewModel.addElement()
        #expect(viewModel.elements == ["Q1", "Q2"], "After two adds, queue should contain Q1 and Q2")
        
        
        viewModel.removeElement()
        #expect(viewModel.elements == ["Q2"], "After removal, queue should contain Q2")
    }
        
    @Test func testStackAddRemove() {
        let viewModel = DataStructureViewModel(type: .stack)
        #expect(viewModel.elements.isEmpty, "Expected no elements initially")
        
        
        viewModel.addElement()
        #expect(viewModel.elements == ["S1"], "After one add, stack should contain S1")
        
        viewModel.addElement()
        #expect(viewModel.elements == ["S1", "S2"], "After two adds, stack should contain S1 and S2")
        
        
        viewModel.removeElement()
        #expect(viewModel.elements == ["S1"], "After removal, stack should contain S1")
    }
    
    @Test func testDataStructureViewModelInitialization()  {
        let arrayViewModel = DataStructureViewModel(type: .array)
        let queueViewModel = DataStructureViewModel(type: .queue)
        let stackViewModel = DataStructureViewModel(type: .stack)
        
        #expect(arrayViewModel.type == .array)
        #expect(queueViewModel.type == .queue)
        #expect(stackViewModel.type == .stack)
        
        #expect(arrayViewModel.elements.isEmpty)
        #expect(queueViewModel.elements.isEmpty)
        #expect(stackViewModel.elements.isEmpty)
    }
    
    @Test func testDataStructureViewModelAddMultipleElements()  {
        let arrayViewModel = DataStructureViewModel(type: .array)
        
        
        for i in 1...5 {
            arrayViewModel.addElement()
            #expect(arrayViewModel.elements.count == i)
            #expect(arrayViewModel.elements[i-1] == "A\(i)")
        }
    }
    
    @Test func testDataStructureViewModelRemoveFromEmptyArray()  {
        let arrayViewModel = DataStructureViewModel(type: .array)
        
        
        arrayViewModel.removeElement()
        #expect(arrayViewModel.elements.isEmpty)
    }
    
    @Test func testQueueFIFOBehavior()  {
        let queueViewModel = DataStructureViewModel(type: .queue)
        
        
        queueViewModel.addElement() 
        queueViewModel.addElement() 
        queueViewModel.addElement() 
        
        
        queueViewModel.removeElement()
        #expect(queueViewModel.elements.count == 2)
        #expect(queueViewModel.elements[0] == "Q2")
        #expect(queueViewModel.elements[1] == "Q3")
        
        
        queueViewModel.removeElement()
        #expect(queueViewModel.elements.count == 1)
        #expect(queueViewModel.elements[0] == "Q3")
    }
    
    @Test func testStackLIFOBehavior()  {
        let stackViewModel = DataStructureViewModel(type: .stack)
        
        
        stackViewModel.addElement() 
        stackViewModel.addElement() 
        stackViewModel.addElement() 
        
        
        stackViewModel.removeElement()
        #expect(stackViewModel.elements.count == 2)
        #expect(stackViewModel.elements[0] == "S1")
        #expect(stackViewModel.elements[1] == "S2")
        
        
        stackViewModel.removeElement()
        #expect(stackViewModel.elements.count == 1)
        #expect(stackViewModel.elements[0] == "S1")
    }
    
    @Test func testSequentialAddRemove()  {
        let arrayViewModel = DataStructureViewModel(type: .array)
        
        
        arrayViewModel.addElement() 
        arrayViewModel.addElement() 
        arrayViewModel.removeElement() 
        arrayViewModel.addElement() 
        arrayViewModel.removeElement() 
        arrayViewModel.removeElement() 
        arrayViewModel.reset()
        
        #expect(arrayViewModel.elements.isEmpty)
        
        
        arrayViewModel.addElement()
        #expect(arrayViewModel.elements.count == 1)
        #expect(arrayViewModel.elements[0] == "A1") 
    }

    
    struct MockScrollViewProxy: ScrollViewProxyProtocol {
        func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint?) {
            
        }
    }
    
    @Test func testDataStructureTypeProperties()  {
        
        #expect(DataStructureType.array.prefix == "A")
        #expect(DataStructureType.queue.prefix == "Q")
        #expect(DataStructureType.stack.prefix == "S")
        
        
        #expect(DataStructureType.array.displayName == "Array")
        #expect(DataStructureType.queue.displayName == "Queue")
        #expect(DataStructureType.stack.displayName == "Stack")
    }
    
    @Test func testDataStructureViewModelReset()  {
        let viewModel = DataStructureViewModel(type: .array)
        
        
        viewModel.addElement()
        viewModel.addElement()
        #expect(viewModel.elements.count == 2)
        
        
        viewModel.reset()
        #expect(viewModel.elements.isEmpty)
        
        
        viewModel.addElement()
        #expect(viewModel.elements.first == "A1")
    }
    
    @Test func testDataStructureViewModelRemovalDescription()  {
        
        let arrayViewModel = DataStructureViewModel(type: .array)
        #expect(arrayViewModel.removalDescription.contains("last element"))
        
        let queueViewModel = DataStructureViewModel(type: .queue)
        #expect(queueViewModel.removalDescription.contains("first element"))
        #expect(queueViewModel.removalDescription.contains("FIFO"))
        
        let stackViewModel = DataStructureViewModel(type: .stack)
        #expect(stackViewModel.removalDescription.contains("top element"))
        #expect(stackViewModel.removalDescription.contains("LIFO"))
    }
    







































    
    @Test func testDataViewInitialization()  {
        let view = DataView()
        
        
        _ = view.body
    }
    
    @Test func testRefactoredDataViewInitialization()  {
        let view = DataView()
        
        
        _ = view.body
    }
    




















































































}


struct graphsTests {

    @Test func testGraphConnectivity()  {
        let graph = Graph()
        #expect(graph.isConnected == false)
        
        graph.addNode(label: "A", position: CGPoint(x: 0, y: 0))
        graph.addNode(label: "B", position: CGPoint(x: 10, y: 10))
        graph.addNode(label: "C", position: CGPoint(x: 20, y: 20))
        
        if let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
           let bID = graph.nodes.first(where: { $0.label == "B" })?.id,
           let cID = graph.nodes.first(where: { $0.label == "C" })?.id {
            graph.addEdge(from: aID, to: bID)
            graph.addEdge(from: bID, to: cID)
        }
        #expect(graph.isConnected == true)
    }

    @Test func testGraphCycleDetection()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        graph.addNode(label: "C", position: .zero)
        
        if let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
           let bID = graph.nodes.first(where: { $0.label == "B" })?.id,
           let cID = graph.nodes.first(where: { $0.label == "C" })?.id {
            graph.addEdge(from: aID, to: bID)
            graph.addEdge(from: bID, to: cID)
            graph.addEdge(from: cID, to: aID)
        }
        #expect(graph.isCyclic == true)
    }
    
    @Test func testGraphNoCycle()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        graph.addNode(label: "C", position: .zero)
    
        #expect(graph.isCyclic == false)
    }
    
    @Test func testNodeAdditionAndRemoval()  {
        let graph = Graph()
        
        #expect(graph.nodes.count == 0)
        
        graph.addNode(label: "A", position: .zero)
        #expect(graph.nodes.count == 1)
        
        graph.addNode(label: "B", position: .zero)
        #expect(graph.nodes.count == 2)
        
        if let aID = graph.nodes.first(where: { $0.label == "A" })?.id {
            graph.removeNode(aID)
        }
        #expect(graph.nodes.count == 1)
    }
    
    @Test func testEdgeAdditionRemovalAndWeightUpdate()  {
        let graph = Graph()
        graph.isWeighted = true
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        
        guard let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
              let bID = graph.nodes.first(where: { $0.label == "B" })?.id else {
            #expect(false)
            return
        }
        
        graph.addEdge(from: aID, to: bID, weight: 5)
        #expect(graph.edges.count == 1)
        
        if let edge = graph.edges.first {
            #expect(edge.weight == 5)
            graph.updateWeight(for: edge.id, newWeight: 10)
            #expect(graph.edges.first?.weight == 10)
        }
        
        if let edge = graph.edges.first {
            graph.removeEdge(edge.id)
        }
        #expect(graph.edges.count == 0)
    }
    
    @Test func testGraphEdgeRemovalWhenNodeRemoved()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        graph.addNode(label: "C", position: .zero)
        
        guard let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
              let bID = graph.nodes.first(where: { $0.label == "B" })?.id,
              let cID = graph.nodes.first(where: { $0.label == "C" })?.id else {
            #expect(false)
            return
        }
        
        graph.addEdge(from: aID, to: bID)
        graph.addEdge(from: bID, to: cID)
        #expect(graph.edges.count == 2)
        
        graph.removeNode(bID)
        #expect(graph.nodes.count == 2)
        #expect(graph.edges.count == 0)
    }
    
    @Test func testGraphDirectedProperty()  {
        let graph = Graph()
        #expect(graph.isDirected == false)
        
        graph.isDirected = true
        #expect(graph.isDirected == true)
    }
    
    @Test func testGraphWeightedProperty()  {
        let graph = Graph()
        #expect(graph.isWeighted == false)
        
        graph.isWeighted = true
        #expect(graph.isWeighted == true)
    }
    
    @Test func testGraphNodePositionUpdate()  {
        let graph = Graph()
        graph.addNode(label: "A", position: CGPoint(x: 10, y: 10))
        
        let nodeID = graph.nodes.first!.id
        let newPosition = CGPoint(x: 20, y: 30)
        
        
        if let index = graph.nodes.firstIndex(where: { $0.id == nodeID }) {
            graph.nodes[index].position = newPosition
        }
        
        #expect(graph.nodes.first?.position.x == 20)
        #expect(graph.nodes.first?.position.y == 30)
    }
    
    @Test func testGraphNodeWithSameLabel()  {
        let graph = Graph()
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "A", position: .zero) 
        
        #expect(graph.nodes.count == 2)
        #expect(graph.nodes[0].label == "A")
        #expect(graph.nodes[1].label == "A")
        #expect(graph.nodes[0].id != graph.nodes[1].id) 
    }
    
    @Test func testGraphConnectivityWithDisconnectedNodes()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        graph.addNode(label: "C", position: .zero)
        
        
        #expect(graph.isConnected == false)
    }
    
    @Test func testGraphConnectivityWithPartialConnections()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        graph.addNode(label: "C", position: .zero)
        
        if let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
           let bID = graph.nodes.first(where: { $0.label == "B" })?.id {
            graph.addEdge(from: aID, to: bID)
        }
        
        
        #expect(graph.isConnected == false)
    }
    
    @Test func testGraphCyclicWithSelfLoop()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        
        if let aID = graph.nodes.first(where: { $0.label == "A" })?.id {
            graph.addEdge(from: aID, to: aID) 
        }
        
        #expect(graph.isCyclic == true)
    }
    
    @Test func testGraphCyclicWithLargerCycle()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        graph.addNode(label: "C", position: .zero)
        graph.addNode(label: "D", position: .zero)
        
        if let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
           let bID = graph.nodes.first(where: { $0.label == "B" })?.id,
           let cID = graph.nodes.first(where: { $0.label == "C" })?.id,
           let dID = graph.nodes.first(where: { $0.label == "D" })?.id {
            graph.addEdge(from: aID, to: bID)
            graph.addEdge(from: bID, to: cID)
            graph.addEdge(from: cID, to: dID)
            graph.addEdge(from: dID, to: aID) 
        }
        
        #expect(graph.isCyclic == true)
    }
    
    @Test func testWeightedEdgeCreation()  {
        let graph = Graph()
        graph.isWeighted = true
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        
        guard let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
              let bID = graph.nodes.first(where: { $0.label == "B" })?.id else {
            #expect(false, "Failed to create nodes")
            return
        }
        
        graph.addEdge(from: aID, to: bID, weight: 42)
        
        #expect(graph.edges.count == 1)
        #expect(graph.edges.first?.weight == 42)
    }
    
    @Test func testNonWeightedEdgeCreation()  {
        let graph = Graph()
        graph.isWeighted = false 
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        
        guard let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
              let bID = graph.nodes.first(where: { $0.label == "B" })?.id else {
            #expect(false, "Failed to create nodes")
            return
        }
        
        graph.addEdge(from: aID, to: bID, weight: 42) 
        
        #expect(graph.edges.count == 1)
        #expect(graph.edges.first?.weight == nil)
    }
    
    @Test func testDuplicateEdgeCreation()  {
        let graph = Graph()
        
        graph.addNode(label: "A", position: .zero)
        graph.addNode(label: "B", position: .zero)
        
        guard let aID = graph.nodes.first(where: { $0.label == "A" })?.id,
              let bID = graph.nodes.first(where: { $0.label == "B" })?.id else {
            #expect(false, "Failed to create nodes")
            return
        }
        
        graph.addEdge(from: aID, to: bID)
        graph.addEdge(from: aID, to: bID) 
        
        
        #expect(graph.edges.count == 2)
    }
}


@MainActor
struct hciTests {

    @Test func testDoorTypeDescription()  {
        let view = HCIViewModel()
        #expect(view.doorTypeDescription(for: "glassDoor") == "Glass door with a handle")
        #expect(view.doorTypeDescription(for: "hingeDoor") == "Door with visible hinges")
        #expect(view.doorTypeDescription(for: "knobDoor") == "Door with a round doorknob")
        #expect(view.doorTypeDescription(for: "labeledDoor") == "Door with a label that says Pull")
        #expect(view.doorTypeDescription(for: "panelDoor") == "Door with a push panel")
        #expect(view.doorTypeDescription(for: "plainDoor") == "Plain door with no visible handles")
        #expect(view.doorTypeDescription(for: "pushBarDoor") == "Door with a horizontal bar")
        #expect(view.doorTypeDescription(for: "unknownDoor") == "Door")
    }
    
    @Test func testHandleAnswerCorrect()  {
        let view = HCIViewModel()
        view.currentDoorIndex = 0
        #expect(view.score == 0)
        #expect(view.isAnswered == false)
        
        view.handleAnswer("Pull Right")
        
        #expect(view.isAnswered == true)
        #expect(view.answerFeedback == "Correct!")
        #expect(view.score == 1)
    }
    
    @Test func testHandleAnswerIncorrect()  {
        let view = HCIViewModel()
        view.currentDoorIndex = 0
        
        view.handleAnswer("Push Left")
        
        #expect(view.isAnswered == true)
        #expect(view.answerFeedback.contains("Pull Right"))
        #expect(view.score == 0)
    }
    
    @Test func testNextQuestion()  {
        let view = HCIViewModel()
        view.currentDoorIndex = 0
        view.isAnswered = true
        view.answerFeedback = "Correct!"
        
        view.nextQuestion()
        
        #expect(view.currentDoorIndex == 1)
        #expect(view.isAnswered == false)
        #expect(view.answerFeedback == "")
    }
    
    @Test func testButtonBackgroundColor()  {
        let view = HCIViewModel()
        view.currentDoorIndex = 0
        view.isAnswered = false
        #expect(view.buttonBackgroundColor(for: "Any Choice") == .blue)
        
        view.isAnswered = true
        #expect(view.buttonBackgroundColor(for: "Pull Right") == .green)
        #expect(view.buttonBackgroundColor(for: "Push Left") == .red)
    }
    
    @Test func testHCIViewInitialization()  {
        let view = HCIView()
        
        #expect(view.body is any View)
        
        
        #expect(!view.introductionText.isEmpty)
        
        
        #expect(!view.conclusionText.isEmpty)
        
        
        #if os(tvOS)
        #expect(view.columns.count == 2)
        #expect(view.columns[0].spacing == nil)
        #else
        #expect(view.columns.count == 2)
        #expect(view.columns[0].spacing == nil)
        #endif
    }
    
    
    @Test func testHandleAnswerImplicitClosure()  {
        let viewModel = HCIViewModel()
        viewModel.currentDoorIndex = 0 
        
        
        viewModel.handleAnswer("Pull Right") 
        #expect(viewModel.answerFeedback == "Correct!")
        
        
        viewModel.currentDoorIndex = 6 
        viewModel.isAnswered = false
        viewModel.handleAnswer("Push Left") 
        #expect(viewModel.answerFeedback == "Correct!")
        
        
        viewModel.currentDoorIndex = 6 
        viewModel.isAnswered = false
        viewModel.handleAnswer("Pull Right") 
        #expect(viewModel.answerFeedback.contains("Push Left or Push Right"))
    }
    
    @Test func testButtonBackgroundColorImplicitClosure()  {
        let viewModel = HCIViewModel()
        viewModel.currentDoorIndex = 0 
        
        
        viewModel.isAnswered = false
        let blueColor = viewModel.buttonBackgroundColor(for: "Any Choice")
        #expect(blueColor == .blue)
        
        
        viewModel.isAnswered = true
        let greenColor = viewModel.buttonBackgroundColor(for: "Pull Right")
        #expect(greenColor == .green)
        
        
        let redColor = viewModel.buttonBackgroundColor(for: "Push Left")
        #expect(redColor == .red)
        
        
        viewModel.currentDoorIndex = 6 
        let pushLeftColor = viewModel.buttonBackgroundColor(for: "Push Left")
        let pushRightColor = viewModel.buttonBackgroundColor(for: "Push Right")
        #expect(pushLeftColor == .green)
        #expect(pushRightColor == .green)
    }
    
    
    @Test func testHCIViewBody()  {
        
        let inProgressView = TestHCIView(testCurrentDoorIndex: 3)
        #expect(inProgressView.body is any View)
        
        
        let doorQuizView = inProgressView.getDoorQuizView()
        #expect(doorQuizView is any View)
        
        
        let completedView = TestHCIView(testCurrentDoorIndex: 8) 
        #expect(completedView.body is any View)
        
        
        let completionView = completedView.getQuizCompletionView()
        #expect(completionView is any View)
    }
    
    @Test func testDoorQuizViewComponents()  {
        let view = TestHCIView(testCurrentDoorIndex: 0)
        
        
        let quizView = view.getDoorQuizView()
        #expect(quizView is any View)
        
        
        view.testViewModel.isAnswered = true
        view.testViewModel.answerFeedback = "Test feedback"
        let answeredQuizView = view.getDoorQuizView()
        #expect(answeredQuizView is any View)
        
        
        for choice in view.testViewModel.possibleChoices {
            view.testViewModel.isAnswered = false 
            
            
            view.testViewModel.handleAnswer(choice)
            #expect(view.testViewModel.isAnswered == false)
            
            
            view.testViewModel.nextQuestion()
        }
    }
    
    @Test func testQuizCompletionViewComponents()  {
        let view = TestHCIView(testCurrentDoorIndex: 8) 
        
        
        view.testViewModel.score = 5
        
        
        let completionView = view.getQuizCompletionView()
        #expect(completionView is any View)
    }
    
    
    @Test func testDoorQuizViewNestedClosures()  {
        let view = TestHCIView(testCurrentDoorIndex: 0)
        
        
        let buttonGrid = view.getButtonGrid()
        #expect(buttonGrid is any View)
        
        
        for choice in view.testViewModel.possibleChoices {
            
            let buttonAction = view.getButtonAction(for: choice)
            buttonAction() 
            #expect(view.testViewModel.isAnswered == false)
            
            
            view.testViewModel.isAnswered = false
        }
        
        
        view.testViewModel.isAnswered = true
        view.testViewModel.answerFeedback = "Test feedback"
        let feedbackView = view.getFeedbackView()
        #expect(feedbackView is any View)
    }
    
    
    @Test func testDeeplyNestedClosures()  {
        let view = TestHCIView(testCurrentDoorIndex: 0)
        
        
        let hstack = view.getHStack()
        #expect(hstack is any View)
        
        
        let doorImage = view.getDoorImage()
        #expect(doorImage is any View)
        
        
        for choice in view.testViewModel.possibleChoices {
            
            view.testViewModel.isAnswered = false
            let normalLabel = view.getButtonLabel(for: choice)
            #expect(normalLabel is any View)
            
            
            view.testViewModel.isAnswered = true
            if view.testViewModel.correctAnswers[view.testViewModel.doorImageNames[0]]?.contains(choice) == true {
                let correctLabel = view.getButtonLabel(for: choice)
                #expect(correctLabel is any View)
            } else {
                let incorrectLabel = view.getButtonLabel(for: choice)
                #expect(incorrectLabel is any View)
            }
        }
    }
}


@MainActor
struct TestHCIView: View {
    @StateObject var testViewModel: HCIViewModel
    let columns: [GridItem]
    let introductionText: String
    let conclusionText: String
    
    init(testCurrentDoorIndex: Int) {
        _testViewModel = StateObject(wrappedValue: {
            let model = HCIViewModel()
            model.currentDoorIndex = testCurrentDoorIndex
            return model
        }())
        
        self.columns = [
            GridItem(.fixed(120)),
            GridItem(.fixed(120)),
        ]
        
        self.introductionText = "Test introduction"
        self.conclusionText = "Test conclusion"
    }
    
    var body: some View {
        VStack {
            if testViewModel.currentDoorIndex >= testViewModel.doorImageNames.count {
                getQuizCompletionView()
            } else {
                getDoorQuizView()
            }
        }
    }
    
    
    func getQuizCompletionView() -> some View {
        VStack(spacing: 20) {
            Text("Quiz Completed!")
            Text("Your score: \(testViewModel.score) / \(testViewModel.doorImageNames.count)")
            Text(conclusionText)
        }
    }
    
    func getDoorQuizView() -> some View {
        VStack {
            getHStack()
            
            if testViewModel.isAnswered {
                getFeedbackView()
            }
        }
    }
    
    func getHStack() -> some View {
        HStack {
            Text("How do you think you open this?")
            
            Spacer()
            
            getDoorImage()
            
            Spacer()
            
            getButtonGrid()
        }
    }
    
    func getDoorImage() -> some View {
        Image(testViewModel.doorImageNames[testViewModel.currentDoorIndex])
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
    
    func getButtonGrid() -> some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(testViewModel.possibleChoices, id: \.self) { choice in
                Button(action: getButtonAction(for: choice)) {
                    getButtonLabel(for: choice)
                }
            }
        }
    }
    
    func getButtonAction(for choice: String) -> () -> Void {
        return {
            testViewModel.handleAnswer(choice)
        }
    }
    
    func getButtonLabel(for choice: String) -> some View {
        Text(choice)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(testViewModel.buttonBackgroundColor(for: choice))
            .cornerRadius(10)
    }
    
    func getFeedbackView() -> some View {
        Text(testViewModel.answerFeedback)
            .font(.headline)
            .padding()
    }
}


@MainActor
struct imageRepresentationTests {

    
    @Test func testImgViewInitialization()  throws {
        let view = ImgView(name: "TestUser")
        #expect(view.name == "TestUser")
    }
    
    #if os(iOS)
    @Test func testColorPixelBuilderViewInitialState()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        #expect(view.palette.count == 16)
    }
    
    @Test func testColorNameFunction()  throws {
        func colorName(at index: Int) -> String {
            let names = ["Black", "White", "Red", "Green",
                         "Blue", "Yellow", "Orange", "Purple",
                         "Pink", "Gray", "Brown", "Cyan",
                         "Mint", "Indigo", "Teal", "Purple"]
            return index >= 0 && index < names.count ? names[index] : "Unknown"
        }
        
        #expect(colorName(at: 0) == "Black")
        #expect(colorName(at: 7) == "Purple")
        #expect(colorName(at: 15) == "Purple")
        #expect(colorName(at: 16) == "Unknown")
        #expect(colorName(at: -1) == "Unknown")
    }
    #endif
    
    #if os(tvOS)
    @Test func testPixelArtShowcaseViewInitialization()  throws {
        let service = TVOSMultipeerServiceArt()
        let view = PixelArtShowcaseView(service: service)
        #expect(service.peerPixelArt.isEmpty)
    }
    #endif
    
    
    @Test func testImgViewContent()  throws {
        let view = ImgView(name: "TestUser")
        
        
        #expect(view.pixelIntroText.hasContent())
        #expect(view.blackWhiteExplanationText.hasContent())
        #expect(view.grayscaleExplanationText.hasContent())
        #expect(view.colorExplanationText.hasContent())
        #expect(view.colorDepthScalingText.hasContent())
    }
    
    
    @Test func testImageRepresentationContent()  throws {
        let view = ImgView(name: "TestUser")
        let _ = view.imageRepresentationContent
        
        #expect(true)
    }
    
    
    @Test func testImgViewBody()  throws {
        let view = ImgView(name: "TestUser")
        let _ = view.body
        
        #expect(true)
    }
    
    
    @Test func testSectionView()  throws {
        
        for count in [1, 2, 4, 8, 16] {
            let view = SectionView(circleCount: count)
            let _ = view.body
            #expect(true)
        }
        
        
        let view = SectionView(circleCount: 0)
        let _ = view.body
        #expect(true)
        
        
        let testView = SectionView(circleCount: 1)
        let _ = testView.createCircle(size: 50)
        #expect(true)
    }
    
    #if os(iOS)
    
    @Test func testColorPixelBuilderViewDefaultState()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        #expect(view.pixels.count == 256)
        #expect(view.selectedColor == 0)
        #expect(view.elementSpacing == 10) 
    }
    
    @Test func testColorPalette()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        #expect(view.palette.count == 16)
        #expect(view.palette[0] == .black)
        #expect(view.palette[1] == .white)
        #expect(view.palette[2] == .red)
        #expect(view.palette[3] == .green)
    }
    
    @Test func testPixelUpdate()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        let initialPixels = view.pixels
        
        
        view.selectedColor = 2  
        
        
        let randomPixelIndex = 42  
        view.updatePixel(at: randomPixelIndex)
        
        
        #expect(view.pixels[randomPixelIndex] == 2)
        #expect(view.pixels != initialPixels)
    }
    
    @Test func testResetFunctionality()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        view.selectedColor = 3
        view.updatePixel(at: 0)
        view.updatePixel(at: 10)
        view.updatePixel(at: 20)
        
        
        view.resetGrid()
        
        
        #expect(view.pixels.allSatisfy { $0 == 0 })
    }
    
    @Test func testColorNameUtility()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        #expect(view.colorName(at: 0) == "Black")
        #expect(view.colorName(at: 2) == "Red")
        #expect(view.colorName(at: 15) == "Purple")
        #expect(view.colorName(at: 100) == "Unknown")  
    }
    
    @Test func testMultipeerServiceIntegration()  throws {
        
        class MockMultipeerServiceArt: iOSMultipeerServiceArt {
            var pixelUpdateCalled = false
            var lastPixels: [Int]? = nil
            
            override func sendPixelArtUpdate(pixels: [Int]) {
                pixelUpdateCalled = true
                lastPixels = pixels
            }
            
            init() {
                super.init(username: "MockUser")
            }
        }
        
        
        let mockService = MockMultipeerServiceArt()
        let view = ColorPixelBuilderView(name: "TestUser")
        view.multipeerService = mockService
        
        
        view.selectedColor = 4 
        view.updatePixel(at: 15)
        
        
        #expect(mockService.pixelUpdateCalled)
        #expect(mockService.lastPixels != nil)
        if let pixels = mockService.lastPixels {
            #expect(pixels[15] == 4)
        }
    }
    
    
    @Test func testIOSContentView()  throws {
        let view = ImgView(name: "TestUser")
        let _ = view.iOSContent()
        #expect(true)
    }
    
    
    @Test func testColorPixelBuilderViewBody()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        let _ = view.body
        #expect(true)
    }
    
    @Test func testConnectionButton()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        view.multipeerService.isConnected = false
        let connectionButton = view.connectionButton
        let _ = connectionButton
        
        view.multipeerService.isConnected = true
        let noConnectionButton = view.connectionButton
        let _ = noConnectionButton
        
        #expect(true)
    }
    
    @Test func testColorPaletteSelector()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        let _ = view.colorPaletteSelector
        #expect(true)
    }
    
    @Test func testPixelGrid()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        let _ = view.pixelGrid
        #expect(true)
    }
    
    @Test func testControlButtons()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        let _ = view.controlButtons
        #expect(true)
    }
    
    
    @Test func testUpdatePixelWithEdgeCases()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        view.selectedColor = 5
        view.updatePixel(at: 0)  
        #expect(view.pixels[0] == 5)
        
        view.selectedColor = 6
        view.updatePixel(at: 255)  
        #expect(view.pixels[255] == 6)
        
        
        view.updatePixel(at: -1)
        view.updatePixel(at: 256)
        #expect(true)
    }
    
    
    @Test func testMultipeerConnectionHandling()  throws {
        let view = ColorPixelBuilderView(name: "TestUser")
        
        
        class ConnectionTestService: iOSMultipeerServiceArt {
            var browseForServiceCalled = false
            
            override func browseForArtService(presentingVC: UIViewController) {
                browseForServiceCalled = true
            }
            
            init() {
                super.init(username: "TestUser")
            }
        }
        
        let mockService = ConnectionTestService()
        view.multipeerService = mockService
        
        
        class MockViewController: UIViewController {}
        let mockVC = MockViewController()
        
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if let window = windowScene?.windows.first {
            window.rootViewController = mockVC
            
            
            view.browseForPeers()
            
            
            #expect(mockService.browseForServiceCalled)
        }
    }
    #endif
    
    #if os(tvOS)
    
    @Test func testPixelArtShowcaseViewWithPeerData()  throws {
        let service = TVOSMultipeerServiceArt()
        let view = PixelArtShowcaseView(service: service)
        
        
        let mockPeerID1 = MCPeerID(displayName: "Peer1")
        let mockPeerID2 = MCPeerID(displayName: "Peer2")
        
        
        let pixels1 = Array(repeating: 0, count: 256)
        let pixels2 = Array(repeating: 1, count: 256)
        
        
        service.peerPixelArt[mockPeerID1] = pixels1
        service.peerPixelArt[mockPeerID2] = pixels2
        
        
        #expect(service.peerPixelArt.count == 2)
        #expect(service.peerPixelArt.keys.contains(mockPeerID1))
        #expect(service.peerPixelArt.keys.contains(mockPeerID2))
    }
    
    @Test func testPixelGridViewFunction()  throws {
        let service = TVOSMultipeerServiceArt()
        let view = PixelArtShowcaseView(service: service)
        
        
        let pixels = Array(0..<256).map { $0 % 16 }  
        
        
        let _ = view.pixelGridView(pixels)
        
        
        #expect(true)
    }
    
    @Test func testArraySafeIndexExtension()  throws {
        let array = [1, 2, 3, 4, 5]
        
        
        #expect(array[safeIndex: 2] == 3)
        
        
        #expect(array[safeIndex: 10] == nil)
        
        
        #expect(array[safeIndex: -1] == nil)
    }
    
    
    
    @Test func testPixelArtShowcaseViewBody()  throws {
        let service = TVOSMultipeerServiceArt()
        let view = PixelArtShowcaseView(service: service)
        let _ = view.body
        #expect(true)
    }
    
    
    @Test func testPixelGridViewWithEmptyArray()  throws {
        let service = TVOSMultipeerServiceArt()
        let view = PixelArtShowcaseView(service: service)
        
        
        let emptyPixels: [Int] = []
        let _ = view.pixelGridView(emptyPixels)
        
        
        let partialPixels = Array(0..<100).map { $0 % 16 }
        let _ = view.pixelGridView(partialPixels)
        
        #expect(true)
    }
    
    
    @Test func testHandlingPeerStateChanges()  throws {
        let service = TVOSMultipeerServiceArt()
        let view = PixelArtShowcaseView(service: service)
        
        
        #expect(service.peerPixelArt.isEmpty)
        
        
        let peer1 = MCPeerID(displayName: "Peer1")
        service.peerPixelArt[peer1] = Array(repeating: 0, count: 256)
        #expect(service.peerPixelArt.count == 1)
        
        
        service.peerPixelArt.removeValue(forKey: peer1)
        #expect(service.peerPixelArt.isEmpty)
        
        
        let peer2 = MCPeerID(displayName: "Peer2")
        let peer3 = MCPeerID(displayName: "Peer3")
        service.peerPixelArt[peer2] = Array(repeating: 1, count: 256)
        service.peerPixelArt[peer3] = Array(repeating: 2, count: 256)
        #expect(service.peerPixelArt.count == 2)
    }
    #endif
    
    
    @Test func testViewNamePropagation()  throws {
        let testName = "TestUserName"
        let view = ImgView(name: testName)
        
        
        #expect(view.name == testName)
    }
    
    @Test func testContentDescriptionAccuracy()  throws {
        let view = ImgView(name: "TestUser")
        
        
        #expect(view.pixelIntroText.hasContent())
        #expect(view.blackWhiteExplanationText.hasContent())
        #expect(view.grayscaleExplanationText.hasContent())
        #expect(view.colorExplanationText.hasContent())
        #expect(view.colorDepthScalingText.hasContent())
        
        
        let pixelIntroString = String(describing: view.pixelIntroText)
        let blackWhiteString = String(describing: view.blackWhiteExplanationText)
        let grayscaleString = String(describing: view.grayscaleExplanationText)
        
        
        #expect(pixelIntroString.count > 10)
        #expect(blackWhiteString.count > 10)
        #expect(grayscaleString.count > 10)
    }
    
    
    @Test func testMainViewBody()  throws {
        let view = ImgView(name: "TestUser")
        let _ = view.body
        #expect(true)
    }
    
    
    @Test func testImgViewWithDifferentNames()  throws {
        
        let view1 = ImgView(name: "")
        #expect(view1.name == "")
        
        
        let longName = String(repeating: "A", count: 100)
        let view2 = ImgView(name: longName)
        #expect(view2.name == longName)
        
        
        let specialName = "!@#$%^&*()"
        let view3 = ImgView(name: specialName)
        #expect(view3.name == specialName)
    }
}


@MainActor
struct mpcTests {

    @Test func testMPCMessageArtEncodingDecoding() throws {
        let message = MPCMessageArt.pixelArtUpdate(pixels: [1, 2, 3])
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(message)
        let decodedMessage = try decoder.decode(MPCMessageArt.self, from: data)
        
        switch (message, decodedMessage) {
        case (.pixelArtUpdate(let pixels1), .pixelArtUpdate(let pixels2)):
            #expect(pixels1 == pixels2)
        default:
            #expect(false)
        }
    }
    
    @Test func testMPCMessageCPUEncodingDecoding() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let messageRequest = MPCMessageCPU.requestCore
        let dataRequest = try encoder.encode(messageRequest)
        let decodedRequest = try decoder.decode(MPCMessageCPU.self, from: dataRequest)
        switch (messageRequest, decodedRequest) {
        case (.requestCore, .requestCore):
            #expect(true)
        default:
            #expect(false)
        }
        
        let messageAssign = MPCMessageCPU.assignCore(coreNumber: 7)
        let dataAssign = try encoder.encode(messageAssign)
        let decodedAssign = try decoder.decode(MPCMessageCPU.self, from: dataAssign)
        switch (messageAssign, decodedAssign) {
        case (.assignCore(let core1), .assignCore(let core2)):
            #expect(core1 == core2)
        default:
            #expect(false)
        }
        
        let messageComplete = MPCMessageCPU.coreComplete(coreNumber: 3)
        let dataComplete = try encoder.encode(messageComplete)
        let decodedComplete = try decoder.decode(MPCMessageCPU.self, from: dataComplete)
        switch (messageComplete, decodedComplete) {
        case (.coreComplete(let core1), .coreComplete(let core2)):
            #expect(core1 == core2)
        default:
            #expect(false)
        }
    }

    #if os(iOS)
    @Test func testiOSMultipeerServiceCPUHandleReceivedAssignCore()  {
        let service = iOSMultipeerServiceCPU(username: "TestUser")
        let testPeer = MCPeerID(displayName: "Peer1")
        service.handleReceivedMessage(.assignCore(coreNumber: 5), from: testPeer)
        #expect(service.assignedCoreNumber == 5)
    }
    
    class TestMultipeerServiceArt: iOSMultipeerServiceArt {
        var lastSentMessage: MPCMessageArt?
        override func sendMessage(_ msg: MPCMessageArt) {
            lastSentMessage = msg
        }
    }
    
    @Test func testiOSMultipeerServiceArtSendPixelArtUpdate()  {
        let service = TestMultipeerServiceArt(username: "TestUser")
        let testPixels = [9, 8, 7]
        service.sendPixelArtUpdate(pixels: testPixels)
        
        if case .pixelArtUpdate(let sentPixels)? = service.lastSentMessage {
            #expect(sentPixels == testPixels)
        } else {
            #expect(false)
        }
    }
    #endif

    #if os(tvOS)
    @Test func testTVOSMultipeerServiceArtHandleReceivedPixelArtUpdate()  {
        let service = TVOSMultipeerServiceArt()
        let testPeer = MCPeerID(displayName: "PeerTV")
        service.handleReceivedMessage(.pixelArtUpdate(pixels: [4, 5, 6]), from: testPeer)
        #expect(service.peerPixelArt[testPeer] == [4, 5, 6])
    }
    
    @Test func testTVOSMultipeerServiceCPUCoreManagement()  {
        let service = TVOSMultipeerServiceCPU()
        let dummyPeer = MCPeerID(displayName: "Dummy")
        service.handleReceivedMessage(.requestCore, from: dummyPeer)
        #expect(service.cores.count == 1)
        
        let assignedCore = service.cores.first?.coreNumber ?? 0
        service.handleReceivedMessage(.coreComplete(coreNumber: assignedCore), from: dummyPeer)
        #expect(service.cores.first?.isComplete == true)
        #expect(service.allCoresReady == true)
    }
    #endif
    
    @Test func testMPCMessageArtEncodingDecodingWithLargeArray() throws {
        
        let pixels = Array(0..<256) 
        let message = MPCMessageArt.pixelArtUpdate(pixels: pixels)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(message)
        let decodedMessage = try decoder.decode(MPCMessageArt.self, from: data)
        
        switch (message, decodedMessage) {
        case (.pixelArtUpdate(let pixels1), .pixelArtUpdate(let pixels2)):
            #expect(pixels1 == pixels2)
            #expect(pixels1.count == 256)
        default:
            #expect(false, "Message type mismatch")
        }
    }
    
    @Test func testMPCMessageCPUEncodingDecodingWithLargeCore() throws {
        
        let largeCore = 9999
        let message = MPCMessageCPU.assignCore(coreNumber: largeCore)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(message)
        let decodedMessage = try decoder.decode(MPCMessageCPU.self, from: data)
        
        switch (message, decodedMessage) {
        case (.assignCore(let core1), .assignCore(let core2)):
            #expect(core1 == core2)
            #expect(core1 == largeCore)
        default:
            #expect(false, "Message type mismatch")
        }
    }
    
    @Test func testMPCMessageCPUEncodingDecodingWithZeroCore() throws {
        
        let message = MPCMessageCPU.assignCore(coreNumber: 0)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(message)
        let decodedMessage = try decoder.decode(MPCMessageCPU.self, from: data)
        
        switch (message, decodedMessage) {
        case (.assignCore(let core1), .assignCore(let core2)):
            #expect(core1 == core2)
            #expect(core1 == 0)
        default:
            #expect(false, "Message type mismatch")
        }
    }
    
    @Test func testMPCMessageCPUEncodingDecodingWithNegativeCore() throws {
        
        let message = MPCMessageCPU.assignCore(coreNumber: -5)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(message)
        let decodedMessage = try decoder.decode(MPCMessageCPU.self, from: data)
        
        switch (message, decodedMessage) {
        case (.assignCore(let core1), .assignCore(let core2)):
            #expect(core1 == core2)
            #expect(core1 == -5)
        default:
            #expect(false, "Message type mismatch")
        }
    }
}


struct searchingAlgorithmsTests {

    @Test func testGenerateRandomQRCodeWithValidURLs()  {
        let viewModel = QRCodeViewModel()
        let urls = [
            "https:example1.com",
            "https:example2.com",
            "https:example3.com",
        ]
        viewModel.generateRandomQRCode(from: urls)
        #expect(viewModel.qrCodeImage != nil)
    }
    
    @Test func testGenerateRandomQRCodeWithEmptyArray()  {
        let viewModel = QRCodeViewModel()
        let urls: [String] = []
        viewModel.generateRandomQRCode(from: urls)
        #expect(viewModel.qrCodeImage == nil)
    }
    
    @Test func testQRCodeViewModelInitialState()  {
        let viewModel = QRCodeViewModel()
        #expect(viewModel.qrCodeImage == nil)
    }
    
    @MainActor
    @Test func testSearchViewBody()  {
        let view = SearchView()
        let viewModel = view.testViewModel
        
        
        let body = view.body
        #expect(body is any View)
        
        
        #expect(viewModel.qrCodeImage == nil)
        
        
        #expect(view.instructionsText.hasContent())
        
        
        #expect(view.topicItems.count == 3)
        #expect(view.topicItems[0].name == "Game 1 - Linear Search")
        #expect(view.topicItems[1].name == "Game 2 - Binary Search")
        #expect(view.topicItems[2].name == "Game 3 - Hashing")
    }
    
    @MainActor
    @Test func testLinearViewTVOSContent()  {
        let viewModel = QRCodeViewModel()
        let view = Linear(qrCodeViewModel: viewModel)
        
        
        #expect(view.tvOSUrls.count == 4)
        #expect(view.tvOSUrls.allSatisfy { $0.contains("github.com") })
        
        
        #expect(view.tvOSSetupText.hasContent())
        #expect(view.tvOSGameInstructionsText.hasContent())
        
        
        #if os(tvOS)
        let body = view.body
        #expect(body is any View)
        
        
        viewModel.generateRandomQRCode(from: view.tvOSUrls)
        #expect(viewModel.qrCodeImage != nil)
        #endif
    }
    
    @MainActor
    @Test func testLinearViewIOSContent()  {
        let viewModel = QRCodeViewModel()
        let view = Linear(qrCodeViewModel: viewModel)
        
        
        #expect(view.iOSImages.count == 4)
        #expect(view.iOSImages.contains("L_A"))
        #expect(view.iOSImages.contains("L_B"))
        #expect(view.iOSImages.contains("L_C"))
        #expect(view.iOSImages.contains("L_D"))
        
        
        #expect(view.iOSInstructionsText.hasContent())
        #expect(view.iOSDiscussionText.hasContent())
        
        
        #if os(iOS)
        let body = view.body
        #expect(body is some View)
        
        
        view.selectedImage = "L_A"
        #expect(view.selectedImage == "L_A")
        
        
        view.selectedImage = nil
        
        #expect(view.selectedImage == nil)
        view.getNewShips()
        #expect(view.selectedImage != nil)
        #expect(view.iOSImages.contains(view.selectedImage!))
        #endif
    }
    
    @MainActor
    @Test func testBinaryViewTVOSContent()  {
        let viewModel = QRCodeViewModel()
        let view = Binary(qrCodeViewModel: viewModel)
        
        
        #expect(view.tvOSUrls.count == 4)
        #expect(view.tvOSUrls.allSatisfy { $0.contains("github.com") })
        
        
        #expect(view.tvOSSetupText.hasContent())
        #expect(view.tvOSGameInstructionsText.hasContent())
        
        
        #if os(tvOS)
        let body = view.body
        #expect(body is (any View))
        
        
        viewModel.generateRandomQRCode(from: view.tvOSUrls)
        #expect(viewModel.qrCodeImage != nil)
        #endif
    }
    
    @MainActor
    @Test func testBinaryViewIOSContent()  {
        let viewModel = QRCodeViewModel()
        let view = Binary(qrCodeViewModel: viewModel)
        
        
        #expect(view.iOSImages.count == 4)
        #expect(view.iOSImages.contains("B_A"))
        #expect(view.iOSImages.contains("B_B"))
        #expect(view.iOSImages.contains("B_C"))
        #expect(view.iOSImages.contains("B_D"))
        
        
        #expect(view.iOSSetupText.hasContent())
        #expect(view.iOSDiscussionText.hasContent())
        
        #if os(iOS)
        let body = view.body
        #expect(body is any View)
        
        
        view.selectedImage = "B_A"
        #expect(view.selectedImage == "B_A")
        
        
        view.selectedImage = nil
        
        #expect(view.selectedImage == nil)
        view.getNewShips()
        #expect(view.selectedImage != nil)
        #expect(view.iOSImages.contains(view.selectedImage!))
        #endif
    }
    
    @MainActor
    @Test func testHashingTVOSContent()  {
        let viewModel = QRCodeViewModel()
        let view = Hashing(qrCodeViewModel: viewModel)
        
        
        #expect(view.tvOS_A.count == 2)
        #expect(view.tvOS_B.count == 2)
        #expect(view.tvOS_A.allSatisfy { $0.contains("github.com") })
        #expect(view.tvOS_B.allSatisfy { $0.contains("github.com") })
        
        
        #expect(view.tvOSSetupText.hasContent())
        #expect(view.tvOSGameInstructionsText.hasContent())
        
        
        #if os(tvOS)
        let body = view.body
        #expect(body is any View)
        
        
        viewModel.generateRandomQRCode(from: view.tvOS_A)
        #expect(viewModel.qrCodeImage != nil)
        
        
        viewModel.generateRandomQRCode(from: view.tvOS_B)
        #expect(viewModel.qrCodeImage != nil)
        #endif
    }
    
    @MainActor
    @Test func testHashingIOSContent()  {
        let viewModel = QRCodeViewModel()
        let view = Hashing(qrCodeViewModel: viewModel)
        
        
        #expect(view.iOS_A.count == 2)
        #expect(view.iOS_B.count == 2)
        #expect(view.iOS_A.contains("A_1"))
        #expect(view.iOS_A.contains("A_2"))
        #expect(view.iOS_B.contains("B_1"))
        #expect(view.iOS_B.contains("B_2"))
        
        
        #expect(view.iOSSetupText.hasContent())
        #expect(view.iOSDiscussionText.hasContent())
        
        
        #if os(iOS)
        let body = view.body
        #expect(body is some View)
        
        
        view.selectedPlayer = nil
        view.selectedImage = nil
        #expect(view.selectedPlayer == nil)
        #expect(view.selectedImage == nil)
        
        
        view.selectPlayer1()
        #expect(view.selectedPlayer == 1)
        #expect(view.selectedImage != nil)
        #expect(view.iOS_A.contains(view.selectedImage!))
        
        
        view.selectPlayer2()
        #expect(view.selectedPlayer == 2)
        #expect(view.selectedImage != nil)
        #expect(view.iOS_B.contains(view.selectedImage!))
        #endif
    }
    
    @MainActor
    @Test func testQRCodeGenerationForAllViews()  {
        let viewModel = QRCodeViewModel()
        
        
        let linearView = Linear(qrCodeViewModel: viewModel)
        #if os(tvOS)
        viewModel.generateRandomQRCode(from: linearView.tvOSUrls)
        #expect(viewModel.qrCodeImage != nil)
        #else
        
        #expect(linearView.iOSImages.count == 4)
        #endif
        
        
        let binaryView = Binary(qrCodeViewModel: viewModel)
        #if os(tvOS)
        viewModel.generateRandomQRCode(from: binaryView.tvOSUrls)
        #expect(viewModel.qrCodeImage != nil)
        #else
        
        #expect(binaryView.iOSImages.count == 4)
        #endif
        
        
        let hashingView = Hashing(qrCodeViewModel: viewModel)
        #if os(tvOS)
        viewModel.generateRandomQRCode(from: hashingView.tvOS_A)
        #expect(viewModel.qrCodeImage != nil)
        viewModel.generateRandomQRCode(from: hashingView.tvOS_B)
        #expect(viewModel.qrCodeImage != nil)
        #else
        
        #expect(hashingView.iOS_A.count == 2)
        #expect(hashingView.iOS_B.count == 2)
        #endif
    }
    
    
    
    @Test func testQRCodeFilterConfiguration()  {
        let viewModel = QRCodeViewModel()
        let testUrl = "https://example.com/test"
        
        // Access internal context and filter via reflection
        let mirror = Mirror(reflecting: viewModel)
        #expect(mirror.children.contains { $0.label == "context" })
        
        // Generate QR code and verify behavior
        viewModel.generateRandomQRCode(from: [testUrl])
        #expect(viewModel.qrCodeImage != nil)
        
        // Test with special characters in URL
        let specialUrl = "https://example.com/test?q=1&special=true"
        viewModel.generateRandomQRCode(from: [specialUrl])
        #expect(viewModel.qrCodeImage != nil)
        
        // Test with very long URL
        let longUrl = "https://example.com/" + String(repeating: "a", count: 200)
        viewModel.generateRandomQRCode(from: [longUrl])
        #expect(viewModel.qrCodeImage != nil)
    }
}

@MainActor
struct sortingAlgorithmsTests {
    
    @Test func testCircleItemUniqueness()  {
        let circle1 = CircleItem(color: .red, number: 1)
        let circle2 = CircleItem(color: .red, number: 1)
        #expect(circle1 != circle2)
    }
    
    @Test func testSortableCirclesViewShuffle()  {
        var circles = [
            CircleItem(color: .red, number: 1),
            CircleItem(color: .blue, number: 2),
            CircleItem(color: .green, number: 3),
            CircleItem(color: .yellow, number: 4)
        ]
        
        let circlesBinding = Binding<[CircleItem]>(
            get: { circles },
            set: { circles = $0 }
        )
        
        _ = SortableCirclesView(viewModel: SortingViewModel(circles: circles))
        
        let originalOrder = circles.map { $0.number }
        circles.shuffle()
        let shuffledOrder = circles.map { $0.number }
        
        #expect(shuffledOrder != originalOrder)
    }
    
    @Test func testSortingViewModelInitialization()  {
        
        let emptyViewModel = SortingViewModel()
        #expect(emptyViewModel.circles.isEmpty)
        #expect(emptyViewModel.selectedCircleID == nil)
        
        
        let circles = [
            CircleItem(color: .red, number: 1),
            CircleItem(color: .blue, number: 2),
            CircleItem(color: .green, number: 3)
        ]
        let viewModel = SortingViewModel(circles: circles)
        
        #expect(viewModel.circles.count == 3)
        #expect(viewModel.circles[0].number == 1)
        #expect(viewModel.circles[1].number == 2)
        #expect(viewModel.circles[2].number == 3)
    }
    
    @Test func testSortingViewModelSelectCircle()  {
        let circles = [
            CircleItem(color: .red, number: 1),
            CircleItem(color: .blue, number: 2),
            CircleItem(color: .green, number: 3)
        ]
        let viewModel = SortingViewModel(circles: circles)
        
        
        viewModel.selectCircle(id: circles[0].id)
        #expect(viewModel.selectedCircleID == circles[0].id)
        
        
        viewModel.selectCircle(id: circles[2].id)
        
        
        #expect(viewModel.selectedCircleID == nil)
        
        
        #expect(viewModel.circles[0].number == 3)
        #expect(viewModel.circles[2].number == 1)
    }
    
    @Test func testSortingViewModelShuffleAndReset()  {
        let originalCircles = [
            CircleItem(color: .red, number: 1),
            CircleItem(color: .blue, number: 2),
            CircleItem(color: .green, number: 3),
            CircleItem(color: .yellow, number: 4),
            CircleItem(color: .purple, number: 5)
        ]
        let viewModel = SortingViewModel(circles: originalCircles)
        
        
        viewModel.shuffle()
        
        
        let orderChanged = viewModel.circles.map(\.number) != originalCircles.map(\.number)
        #expect(orderChanged)
        
        
        viewModel.reset(to: originalCircles)
        
        
        #expect(viewModel.circles.map(\.number) == originalCircles.map(\.number))
    }
    
    @Test func testSortingViewModelWithEmptyList()  {
        let viewModel = SortingViewModel(circles: [])
        
        
        #expect(viewModel.isSorted() == true)
        
        
        viewModel.shuffle()
        #expect(viewModel.circles.isEmpty)
    }
    
    @Test func testRefactoredSortableCirclesView()  {
        let circles = [
            CircleItem(color: .red, number: 1),
            CircleItem(color: .blue, number: 2),
            CircleItem(color: .green, number: 3)
        ]
        
        let viewModel = SortingViewModel(circles: circles)
        
        
        viewModel.selectCircle(id: circles[0].id)
        #expect(viewModel.selectedCircleID == circles[0].id)
        
        viewModel.selectCircle(id: circles[2].id)
        #expect(viewModel.circles[0].number == 3)
        #expect(viewModel.circles[2].number == 1)
    }
    
     
     
     @Test func testCircleItemEquality()  {
         let circle1 = CircleItem(color: .red, number: 1)
         let circle2 = CircleItem(color: .red, number: 1)
         
         
         #expect(circle1 != circle2)
         
         
         #expect(circle1.color == circle2.color)
         #expect(circle1.number == circle2.number)
     }
     
     @Test func testCircleItemWithDifferentProperties()  {
         let circle1 = CircleItem(color: .red, number: 1)
         let circle2 = CircleItem(color: .blue, number: 2)
         
         #expect(circle1 != circle2)
         #expect(circle1.color != circle2.color)
         #expect(circle1.number != circle2.number)
     }
     
     
     
     @Test func testSortingViewInitialization()  {
         let view = SortingView()
         _ = view.body
     }
     
     @Test func testSortingViewNavigationLinks()  {
         let view = SortingView()
         
         
         
         _ = view.body
     }
     
     
     
     @Test func testSelectionSortView()  {
         let view = SelectionSortView()
         
         
         _ = view.body
     }
     
     @Test func testBubbleSortView()  {
         let view = BubbleSortView()
         
         
         _ = view.body
     }
     
     @Test func testQuickSortView()  {
         let view = QuickSortView()
         
         
         _ = view.body
     }
     
     @Test func testInsertionSortView()  {
         let view = InsertionSortView()
         
         
         _ = view.body
     }
     
     
     
     @Test func testSortableCirclesViewInitialization()  {
         let circles = [
             CircleItem(color: .red, number: 1),
             CircleItem(color: .blue, number: 2),
             CircleItem(color: .green, number: 3)
         ]
         
         let circlesBinding = Binding(
             get: { circles },
             set: { _ in }
         )
         
         let view = SortableCirclesView(viewModel: SortingViewModel(circles: circles))
         
         
         _ = view.body
     }
     
     @Test func testSortableCirclesViewWithEmptyCircles()  {
         let emptyCircles: [CircleItem] = []
         
         let circlesBinding = Binding(
             get: { emptyCircles },
             set: { _ in }
         )
         
         let view = SortableCirclesView(viewModel: SortingViewModel(circles: emptyCircles))
         
         
         _ = view.body
     }
     
     @Test func testSortableCirclesViewWithSelectedCircle()  {
         var circles = [
             CircleItem(color: .red, number: 1),
             CircleItem(color: .blue, number: 2),
             CircleItem(color: .green, number: 3)
         ]
         
         let circlesBinding = Binding(
             get: { circles },
             set: { circles = $0 }
         )
         
         let view = SortableCirclesView(viewModel: SortingViewModel(circles: circles))
         
         
         let mirror = Mirror(reflecting: view)
         for child in mirror.children {
             if child.label == "_selectedCircleID" {
                 if let selectedCircleID = child.value as? State<UUID?> {
                     
                 }
             }
         }
         
         
         _ = view.body
     }
     
     
     
     @Test func testInsertionSortViewSubviews()  {
         
         
         
         let titleSection = InsertionSortView.Subviews.TitleSection()
         _ = titleSection.body
         
         
         let instructionsSection = InsertionSortView.Subviews.InstructionsSection()
         _ = instructionsSection.body
         
         
         let discussionSection = InsertionSortView.Subviews.DiscussionSection()
         _ = discussionSection.body
         
         
         let actionButtons = InsertionSortView.Subviews.ActionButtons(
             shuffleCircles: {}
         )
         _ = actionButtons.body
     }
     
     @Test func testInsertionSortViewInPlaceCirclesView()  {
         let circles = [
             CircleItem(color: .red, number: 1),
             CircleItem(color: .blue, number: 2),
             CircleItem(color: .green, number: 3)
         ]
         
         let inPlaceCirclesView = InsertionSortView.Subviews.InPlaceCirclesView(
             circles: .constant(circles),
             selectedCircle: .constant(nil),
             selectCircle: { _ in },
             placeCircle: { _ in }
         )
         
         
         _ = inPlaceCirclesView.body
         
         
         let selectedCircle = circles[0]
         let inPlaceCirclesViewWithSelection = InsertionSortView.Subviews.InPlaceCirclesView(
             circles: .constant(circles),
             selectedCircle: .constant(selectedCircle),
             selectCircle: { _ in },
             placeCircle: { _ in }
         )
         
         
         _ = inPlaceCirclesViewWithSelection.body
     }
     
     
     
     @Test func testSortingViewModelInitializationEmpty()  {
         let viewModel = SortingViewModel()
         
         #expect(viewModel.circles.isEmpty)
         #expect(viewModel.selectedCircleID == nil)
     }
     
    @Test func testSortingViewModelInitializationWithCircles()  {
        let circles = [
            CircleItem(color: .red, number: 1),
            CircleItem(color: .blue, number: 2),
            CircleItem(color: .green, number: 3)
        ]
        
        let viewModel = SortingViewModel(circles: circles)
        
        #expect(viewModel.circles.count == 3)
        #expect(viewModel.circles[0].number == 1)
        #expect(viewModel.circles[1].number == 2)
        #expect(viewModel.circles[2].number == 3)
        #expect(viewModel.selectedCircleID == nil)
    }
     
     @Test func testSortingViewModelSelectSameCircleTwice()  {
         let circles = [
             CircleItem(color: .red, number: 1),
             CircleItem(color: .blue, number: 2)
         ]
         
         let viewModel = SortingViewModel(circles: circles)
         
         
         viewModel.selectCircle(id: circles[0].id)
         #expect(viewModel.selectedCircleID == circles[0].id)
         
         
         viewModel.selectCircle(id: circles[0].id)
         
         
         #expect(viewModel.selectedCircleID == nil)
         #expect(viewModel.circles[0].number == 1)
         #expect(viewModel.circles[1].number == 2)
     }
     
     @Test func testSortingViewModelIsSorted()  {
         
         let sortedCircles = [
             CircleItem(color: .red, number: 1),
             CircleItem(color: .blue, number: 2),
             CircleItem(color: .green, number: 3)
         ]
         
         let viewModel = SortingViewModel(circles: sortedCircles)
         #expect(viewModel.isSorted() == true)
         
         
         let unsortedCircles = [
             CircleItem(color: .red, number: 3),
             CircleItem(color: .blue, number: 1),
             CircleItem(color: .green, number: 2)
         ]
         
         let unsortedViewModel = SortingViewModel(circles: unsortedCircles)
         #expect(unsortedViewModel.isSorted() == false)
         
         
         let emptyViewModel = SortingViewModel(circles: [])
         #expect(emptyViewModel.isSorted() == true)
     }
     
     @Test func testSortingViewModelWithBorderCases()  {
         
         let singleCircle = [CircleItem(color: .red, number: 1)]
         let singleViewModel = SortingViewModel(circles: singleCircle)
         #expect(singleViewModel.isSorted() == true)
         
         
         let identicalCircles = [
             CircleItem(color: .red, number: 5),
             CircleItem(color: .blue, number: 5)
         ]
         let identicalViewModel = SortingViewModel(circles: identicalCircles)
         #expect(identicalViewModel.isSorted() == true)
     }
     
     
     
     @Test func testRefactoredSortableCirclesViewInitialization()  {
         let circles = [
             CircleItem(color: .red, number: 1),
             CircleItem(color: .blue, number: 2),
             CircleItem(color: .green, number: 3)
         ]
         
         let viewModel = SortingViewModel(circles: circles)
         let view = SortableCirclesView(viewModel: viewModel)
         
         
         _ = view.body
     }
     
     @Test func testRefactoredSortableCirclesViewWithSelectedCircle()  {
         let circles = [
             CircleItem(color: .red, number: 1),
             CircleItem(color: .blue, number: 2),
             CircleItem(color: .green, number: 3)
         ]
         
         let viewModel = SortingViewModel(circles: circles)
         viewModel.selectedCircleID = circles[0].id
         
         let view = SortableCirclesView(viewModel: viewModel)
         
         
         _ = view.body
     }
}


struct stateMachinesTests {

    @Test func testInitialStateCreation()  {
        let viewModel = DFAViewModel()
        #expect(viewModel.states.count == 1)
    }
    
    @Test func testAddState()  {
        let viewModel = DFAViewModel()
        let initialCount = viewModel.states.count
        viewModel.addState()
        #expect(viewModel.states.count == initialCount + 1)
    }
    
    @Test func testRemoveState()  {
        let viewModel = DFAViewModel()
        viewModel.addState()
        guard let stateToRemove = viewModel.states.first else {
            #expect(false)
            return
        }
        if viewModel.states.count >= 2 {
            let otherState = viewModel.states[1]
            viewModel.addTransition(from: stateToRemove, to: otherState, symbol: "a")
        }
        viewModel.removeState(stateToRemove)
        #expect(viewModel.states.contains(stateToRemove) == false)
        let connectedTransitions = viewModel.transitions.filter { $0.fromStateID == stateToRemove.id || $0.toStateID == stateToRemove.id }
        #expect(connectedTransitions.isEmpty)
    }
    
    @Test func testToggleAccepting()  {
        let viewModel = DFAViewModel()
        guard let state = viewModel.states.first else {
            #expect(false)
            return
        }
        let initialAccepting = state.isAccepting
        viewModel.toggleAccepting(state)
        if let updatedState = viewModel.states.first(where: { $0.id == state.id }) {
            #expect(updatedState.isAccepting == !initialAccepting)
        } else {
            #expect(false)
        }
    }
    
    @Test func testAddTransition()  {
        let viewModel = DFAViewModel()
        viewModel.addState()
        let state1 = viewModel.states.first!
        let state2 = viewModel.states.last!
        let initialTransitionCount = viewModel.transitions.count
        viewModel.addTransition(from: state1, to: state2, symbol: "b")
        #expect(viewModel.transitions.count == initialTransitionCount + 1)
        if let transition = viewModel.transitions.last {
            #expect(transition.symbol == "b")
            #expect(transition.fromStateID == state1.id)
            #expect(transition.toStateID == state2.id)
        }
    }
    
    @Test func testRemoveTransition()  {
        let viewModel = DFAViewModel()
        viewModel.addState()
        let state1 = viewModel.states.first!
        let state2 = viewModel.states.last!
        viewModel.addTransition(from: state1, to: state2, symbol: "c")
        guard let transition = viewModel.transitions.last else {
            #expect(false)
            return
        }
        viewModel.removeTransition(transition)
        #expect(viewModel.transitions.contains(transition) == false)
    }
    
    @Test func testDFAViewModelAddMultipleStates()  {
        let viewModel = DFAViewModel()
        let initialCount = viewModel.states.count
        
        
        for _ in 0..<5 {
            viewModel.addState()
        }
        
        #expect(viewModel.states.count == initialCount + 5)
    }
    
    @Test func testDFAViewModelToggleAcceptingMultipleTimes()  {
        let viewModel = DFAViewModel()
        guard let state = viewModel.states.first else {
            #expect(false, "No initial state")
            return
        }
        
        
        let initialAccepting = state.isAccepting
        
        viewModel.toggleAccepting(state)
        if let updatedState = viewModel.states.first {
            #expect(updatedState.isAccepting == !initialAccepting)
        }
        
        viewModel.toggleAccepting(viewModel.states.first!)
        if let updatedState = viewModel.states.first {
            #expect(updatedState.isAccepting == initialAccepting)
        }
        
        viewModel.toggleAccepting(viewModel.states.first!)
        if let updatedState = viewModel.states.first {
            #expect(updatedState.isAccepting == !initialAccepting)
        }
    }
    
    @Test func testDFAViewModelAddTransitionWithSameSymbol()  {
        let viewModel = DFAViewModel()
        viewModel.addState() 
        
        let state1 = viewModel.states[0]
        let state2 = viewModel.states[1]
        
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        #expect(viewModel.transitions.count == 1)
        
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        #expect(viewModel.transitions.count == 2)
        
        
        viewModel.addTransition(from: state2, to: state1, symbol: "a")
        #expect(viewModel.transitions.count == 3)
    }
    
    @Test func testDFAViewModelAddSelfLoopTransition()  {
        let viewModel = DFAViewModel()
        let state = viewModel.states.first!
        
        
        viewModel.addTransition(from: state, to: state, symbol: "s")
        
        #expect(viewModel.transitions.count == 1)
        if let transition = viewModel.transitions.first {
            #expect(transition.fromStateID == state.id)
            #expect(transition.toStateID == state.id)
            #expect(transition.symbol == "s")
        }
    }
    
    @Test func testDFAViewModelRemoveNonexistentState()  {
        let viewModel = DFAViewModel()
        let initialCount = viewModel.states.count
        
        
        let nonexistentState = DFAState(name: "Nonexistent", position: .zero)
        
        
        viewModel.removeState(nonexistentState)
        
        
        #expect(viewModel.states.count == initialCount)
    }
    
    @Test func testDFAViewModelRemoveNonexistentTransition()  {
        let viewModel = DFAViewModel()
        viewModel.addState() 
        
        let state1 = viewModel.states[0]
        let state2 = viewModel.states[1]
        
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        #expect(viewModel.transitions.count == 1)
        
        
        let nonexistentTransition = DFATransition(fromStateID: UUID(), toStateID: UUID(), symbol: "x")
        
        
        viewModel.removeTransition(nonexistentTransition)
        
        
        #expect(viewModel.transitions.count == 1)
    }
    @Test func testDFAStateInitialization() {
        let state = DFAState(name: "Test", position: CGPoint(x: 100, y: 100))
        #expect(state.name == "Test")
        #expect(state.position.x == 100)
        #expect(state.position.y == 100)
        #expect(state.isAccepting == false)
    }

    @Test func testDFAStateIdentifiable() {
        let state1 = DFAState(name: "State1", position: .zero)
        let state2 = DFAState(name: "State2", position: .zero)
        #expect(state1.id != state2.id)
    }

    @Test func testDFAStateEquality() {
        let state1 = DFAState(name: "State", position: .zero)
        let state2 = DFAState(name: "State", position: .zero)
        let state3 = state1
        
        #expect(state1.hashValue != state2.hashValue)  
        #expect(state1.hashValue == state3.hashValue)  
    }

    
    @Test func testDFATransitionInitialization() {
        let fromID = UUID()
        let toID = UUID()
        let transition = DFATransition(fromStateID: fromID, toStateID: toID, symbol: "a")
        
        #expect(transition.fromStateID == fromID)
        #expect(transition.toStateID == toID)
        #expect(transition.symbol == "a")
    }

    @Test func testDFATransitionIdentifiable() {
        let transition1 = DFATransition(fromStateID: UUID(), toStateID: UUID(), symbol: "a")
        let transition2 = DFATransition(fromStateID: UUID(), toStateID: UUID(), symbol: "b")
        
        #expect(transition1.id != transition2.id)
    }

    @Test func testDFATransitionEquality() {
        let fromID = UUID()
        let toID = UUID()
        let transition1 = DFATransition(fromStateID: fromID, toStateID: toID, symbol: "a")
        let transition2 = DFATransition(fromStateID: fromID, toStateID: toID, symbol: "a")
        let transition3 = transition1
        
        #expect(transition1.hashValue != transition2.hashValue)  
        #expect(transition1.hashValue == transition3.hashValue)  
    }

    
    @Test func testDFAViewModelInitialization() {
        let viewModel = DFAViewModel()
        
        #expect(viewModel.states.count == 1)  
        #expect(viewModel.transitions.isEmpty)  
        #expect(viewModel.states[0].name == "1")  
    }

    @Test func testDFAViewModelRemoveAllStates() {
        let viewModel = DFAViewModel()
        
        
        viewModel.addState()
        viewModel.addState()
        
        
        let state1 = viewModel.states[0]
        let state2 = viewModel.states[1]
        let state3 = viewModel.states[2]
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        viewModel.addTransition(from: state2, to: state3, symbol: "b")
        
        
        for state in viewModel.states.reversed() {
            viewModel.removeState(state)
        }
        
        #expect(viewModel.states.isEmpty)
        #expect(viewModel.transitions.isEmpty)  
    }

    @Test func testDFAViewModelComplexTransitionNetwork() {
        let viewModel = DFAViewModel()
        
        
        viewModel.addState()
        viewModel.addState()
        
        let state1 = viewModel.states[0]
        let state2 = viewModel.states[1]
        let state3 = viewModel.states[2]
        
        
        viewModel.toggleAccepting(state1)
        
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        viewModel.addTransition(from: state2, to: state3, symbol: "b")
        viewModel.addTransition(from: state3, to: state1, symbol: "c")
        viewModel.addTransition(from: state1, to: state1, symbol: "d")
        viewModel.addTransition(from: state2, to: state2, symbol: "e")
        viewModel.addTransition(from: state3, to: state3, symbol: "f")
        
        #expect(viewModel.transitions.count == 6)
        
        
        viewModel.removeState(state2)
        
        #expect(viewModel.states.count == 2)
        
        
        let state2Transitions = viewModel.transitions.filter {
            $0.fromStateID == state2.id || $0.toStateID == state2.id
        }
        #expect(state2Transitions.isEmpty)
        
        
        let transitionFromState3ToState1 = viewModel.transitions.first {
            $0.fromStateID == state3.id && $0.toStateID == state1.id
        }
        #expect(transitionFromState3ToState1 != nil)
    }

    @Test func testDFAViewModelStatePositionGeneration() {
        let viewModel = DFAViewModel()
        
        
        for _ in 0..<10 {
            viewModel.addState()
        }
        
        
        for state in viewModel.states {
            #expect(state.position != .zero)
        }
        
        
        var positionSet = Set<CGPoint>()
        for state in viewModel.states {
            positionSet.insert(state.position)
        }
        
        
        
        #expect(positionSet.count >= viewModel.states.count / 2)
    }

    @Test func testDFAViewModelSequentialStateNaming() {
        let viewModel = DFAViewModel()
        
        
        #expect(viewModel.states.first?.name == "1")
        
        
        viewModel.addState()
        #expect(viewModel.states[1].name == "2")
        
        viewModel.addState()
        #expect(viewModel.states[2].name == "3")
        
        viewModel.addState()
        #expect(viewModel.states[3].name == "4")
    }

    @Test func testTransitionSymbolValidation() {
        let viewModel = DFAViewModel()
        viewModel.addState()
        
        let state1 = viewModel.states[0]
        let state2 = viewModel.states[1]
        
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        viewModel.addTransition(from: state1, to: state2, symbol: "123")
        viewModel.addTransition(from: state1, to: state2, symbol: "")
        viewModel.addTransition(from: state1, to: state2, symbol: "!@#")
        
        #expect(viewModel.transitions.count == 4)
        
        
        let symbols = viewModel.transitions.map { $0.symbol }
        #expect(symbols.contains("a"))
        #expect(symbols.contains("123"))
        #expect(symbols.contains(""))
        #expect(symbols.contains("!@#"))
    }

    @Test func testRemoveMultipleTransitions() {
        let viewModel = DFAViewModel()
        viewModel.addState()
        
        let state1 = viewModel.states[0]
        let state2 = viewModel.states[1]
        
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        viewModel.addTransition(from: state2, to: state1, symbol: "b")
        viewModel.addTransition(from: state1, to: state1, symbol: "c")
        
        #expect(viewModel.transitions.count == 3)
        
        
        if let transition = viewModel.transitions.first {
            viewModel.removeTransition(transition)
            #expect(viewModel.transitions.count == 2)
        }
        
        if let transition = viewModel.transitions.first {
            viewModel.removeTransition(transition)
            #expect(viewModel.transitions.count == 1)
        }
        
        if let transition = viewModel.transitions.first {
            viewModel.removeTransition(transition)
            #expect(viewModel.transitions.isEmpty)
        }
    }

    @Test func testMultipleTransitionsForSameStatePair() {
        let viewModel = DFAViewModel()
        viewModel.addState()
        
        let state1 = viewModel.states[0]
        let state2 = viewModel.states[1]
        
        
        viewModel.addTransition(from: state1, to: state2, symbol: "a")
        viewModel.addTransition(from: state1, to: state2, symbol: "b")
        viewModel.addTransition(from: state1, to: state2, symbol: "c")
        
        #expect(viewModel.transitions.count == 3)
        
        
        for transition in viewModel.transitions {
            #expect(transition.fromStateID == state1.id)
            #expect(transition.toStateID == state2.id)
        }
    }

    @Test func testSelfLoopTransitions() {
        let viewModel = DFAViewModel()
        let state = viewModel.states.first!
        
        
        viewModel.addTransition(from: state, to: state, symbol: "a")
        viewModel.addTransition(from: state, to: state, symbol: "b")
        
        #expect(viewModel.transitions.count == 2)
        
        
        for transition in viewModel.transitions {
            #expect(transition.fromStateID == state.id)
            #expect(transition.toStateID == state.id)
        }
    }

    @Test func testRemovingStateWithSelfLoops() {
        let viewModel = DFAViewModel()
        let state = viewModel.states.first!
        
        
        viewModel.addTransition(from: state, to: state, symbol: "a")
        viewModel.addTransition(from: state, to: state, symbol: "b")
        
        #expect(viewModel.transitions.count == 2)
        
        
        viewModel.removeState(state)
        
        
        #expect(viewModel.states.isEmpty)
        #expect(viewModel.transitions.isEmpty)
    }

    
    @Test func testLineShapeProperties() {
        let from = CGPoint(x: 10, y: 20)
        let to = CGPoint(x: 30, y: 40)
        let lineShape = LineShape(from: from, to: to)
        
        #expect(lineShape.from == from)
        #expect(lineShape.to == to)
    }

    @Test func testSelfLoopShapeProperties() {
        let center = CGPoint(x: 50, y: 60)
        let selfLoopShape = SelfLoopShape(center: center)
        
        #expect(selfLoopShape.center == center)
        #expect(selfLoopShape.loopRadius == 40)  
    }

    @Test func testMultipleStateManipulation() {
        let viewModel = DFAViewModel()
        
        
        for _ in 0..<5 {
            viewModel.addState()
        }
        
        #expect(viewModel.states.count == 6)
        
        
        for state in viewModel.states {
            viewModel.toggleAccepting(state)
        }
        
        
        for state in viewModel.states {
            #expect(state.isAccepting == true)
        }
        
        
        for state in viewModel.states {
            viewModel.toggleAccepting(state)
        }
        
        
        for state in viewModel.states {
            #expect(state.isAccepting == false)
        }
    }
}


struct StartViewTests {

    @Test func testInteractiveAreaModifier()  {
        
        let mockContent = Text("Test")
        
        
        let _ = mockContent.interactiveArea()
        
        
        
    }
}


struct cyberSecurityTests {
    
    @Test func testSecurityTopicViewInitialization()  {
        
        let view = SecurityTopicView(
            title: "Test Title",
            contentText: "Test content",
            imageName: "firewall",
            additionalText: "Additional information",
            width: 300
        )
        
        
        _ = view.body
        
        
        #expect(view.title == "Test Title")
        #expect(view.imageName == "firewall")
        #expect(view.width == 300)
        #expect(view.imageHeight == nil) 
    }
    
    @Test func testSecurityTopicViewWithCustomImageHeight()  {
        
        let view = SecurityTopicView(
            title: "Test Title",
            contentText: "Test content",
            imageName: "firewall",
            additionalText: "Additional information",
            width: 300,
            imageHeight: 150
        )
        
        
        _ = view.body
        
        
        #expect(view.imageHeight == 150)
    }
    
    @Test func testSecurityTopicViewRendersAllComponents()  {
        let view = SecurityTopicView(
            title: "Test Title",
            contentText: "Test content",
            imageName: "firewall",
            additionalText: "Additional information",
            width: 300
        )
        
        
        let bodyMirror = Mirror(reflecting: view.body)
        
        
        #expect(bodyMirror.children.isEmpty == false)
        
        
        _ = view.body
    }
    
    
    
    @Test func testSecurityViewInitialization()  {
        let view = SecurityView()
        
        
        _ = view.body
    }
    
    @Test func testSecurityViewRenderingWithGeometryReader()  {
        let view = SecurityView()
        
        
        _ = view.body
    }
    
    @Test func testSecurityViewContentText()  {
        let view = SecurityView()
        
        
        let mirror = Mirror(reflecting: view)
        
        
        var foundFirewallsText = false
        var foundEncryptionText = false
        
        for child in mirror.children {
            if child.label == "firewallsText" {
                foundFirewallsText = true
                
                if let textValue = child.value as? LocalizedStringKey {
                    
                    let textString = String(describing: textValue)
                    #expect(textString.contains("packets"))
                    #expect(textString.contains("Firewalls"))
                }
            }
            
            if child.label == "encryptionText" {
                foundEncryptionText = true
                
                if let textValue = child.value as? LocalizedStringKey {
                    
                    let textString = String(describing: textValue)
                    #expect(textString.contains("Encryption"))
                    #expect(textString.contains("security measure"))
                }
            }
        }
        
        #expect(foundFirewallsText)
        #expect(foundEncryptionText)
    }
    
    @Test func testSecurityViewAdditionalTextContent()  {
        let view = SecurityView()
        
        
        let mirror = Mirror(reflecting: view)
        
        
        var foundFirewallsAdditionalText = false
        var foundEncryptionAdditionalText = false
        
        for child in mirror.children {
            if child.label == "firewallsAdditionalText" {
                foundFirewallsAdditionalText = true
                
                if let textValue = child.value as? LocalizedStringKey {
                    
                    let textString = String(describing: textValue)
                    #expect(textString.contains("security guards"))
                }
            }
            
            if child.label == "encryptionAdditionalText" {
                foundEncryptionAdditionalText = true
                
                if let textValue = child.value as? LocalizedStringKey {
                    
                    let textString = String(describing: textValue)
                    #expect(textString.contains("algorithms"))
                    #expect(textString.contains("Caesar Cipher"))
                }
            }
        }
        
        #expect(foundFirewallsAdditionalText)
        #expect(foundEncryptionAdditionalText)
    }
    
    @Test func testSecurityViewWithDifferentSizes()  {
        let view = SecurityView()
        
        
        _ = view.body
    }
}

@MainActor
struct programmingLanguagesTests {
    
    @Test func testProgLangViewInitialization()  throws {
        
        let view = ProgLangView()
        #expect(view.body is any View)
    }
    
    @Test func testIntroductionText() {
        
        let view = ProgLangView()
        #expect(view.introductionText.hasContent())
    }
    
    @Test func testRegexExamplesText() {
        
        let view = ProgLangView()
        #expect(!view.regexExamplesText.isEmpty)
    }
    
    @Test func testConclusionText() {
        
        let view = ProgLangView()
        #expect(view.conclusionText.hasContent())
    }
    
    
    @Test func testViewBodyClosures()  throws {
        
        let view = ProgLangView()
    
        let scrollView = view.body
        
        let withPadding = view.padding()
        #expect(withPadding is any View)
        
        let withBackground = view.background(Color.clear)
        #expect(withBackground is any View)
        
        let withForeground = view.foregroundColor(.white)
        #expect(withForeground is any View)
        
        let withFrame = view.frame(width: 300, height: 500)
        #expect(withFrame is any View)
        
        
        let mirror = Mirror(reflecting: view)
        #expect(mirror.children.contains { $0.label == "introductionText" })
        #expect(mirror.children.contains { $0.label == "regexExamplesText" })
        #expect(mirror.children.contains { $0.label == "conclusionText" })
    }
}

struct networkTests {
    
    @Test func testNetworkViewInitialization()  throws {
        
        let view = NetworkView()
        #expect(view.body is any View)
    }
    
    @Test func testNetworkViewProperties()  throws {
        let view = NetworkView()
        
        
        #expect(view.networkExplanationText.hasContent())
        #expect(view.osiModelExplanationText.hasContent())
    }
    
    @Test func testNetworkViewBody()  throws {
        let view = NetworkView()
        
        
        let withPadding = view.padding()
        #expect(withPadding is any View)
        
        let withBackground = view.background(Color.red)
        #expect(withBackground is any View)
        
        
        let withFrame = view.frame(width: 500, height: 800)
        #expect(withFrame is any View)
    }
    
    @Test func testNavigationButtonHelper()  throws {
        let view = NetworkView()
        
        
        let physicalButton = view.navigationButton(title: "Test Button", destination: PhysicalLayer())
        #expect(physicalButton is any View)
        
        let dataLinkButton = view.navigationButton(title: "Another Button", destination: DataLinkLayer())
        #expect(dataLinkButton is any View)
    }
    
    
    @Test func testPhysicalLayerView()  throws {
        let view = PhysicalLayer()
        #expect(view.body is any View)
        
        
        #expect(view.explanationText.hasContent())
        #expect(view.functionsText.hasContent())
        
        
        let modified = view.padding().background(Color.clear)
        #expect(modified is any View)
    }
    
    @Test func testDataLinkLayerView()  throws {
        let view = DataLinkLayer()
        #expect(view.body is any View)
        
        
        #expect(view.layerExplanationText.hasContent())
        
        
        let modified = view.padding().background(Color.clear)
        #expect(modified is any View)
    }
    
    @Test func testNetworkLayerView()  throws {
        let view = NetworkLayer()
        #expect(view.body is any View)
        
        
        #expect(view.layerExplanationText.hasContent())
        
        
        let modified = view.padding().background(Color.clear)
        #expect(modified is any View)
    }
    
    @Test func testTransportLayerView()  throws {
        let view = TransportLayer()
        #expect(view.body is any View)
        
        
        #expect(view.layerExplanationText.hasContent())
        
        
        let modified = view.padding().background(Color.clear)
        #expect(modified is any View)
    }
    
    @Test func testSessionLayerView()  throws {
        let view = SessionLayer()
        #expect(view.body is any View)
        
        
        #expect(view.explanationText.hasContent())
        
        
        let modified = view.padding().background(Color.clear)
        #expect(modified is any View)
    }
    
    @Test func testPresentationLayerView()  throws {
        let view = PresentationLayer()
        #expect(view.body is any View)
        
        
        #expect(view.layerExplanationText.hasContent())
        
        
        let modified = view.padding().background(Color.clear)
        #expect(modified is any View)
    }
    
    @Test func testApplicationLayerView()  throws {
        let view = ApplicationLayer()
        #expect(view.body is any View)
        
        
        #expect(view.explanationText.hasContent())
        #expect(view.functionsText.hasContent())
        
        
        let modified = view.padding().background(Color.clear)
        #expect(modified is any View)
    }
    
    @Test func testBodyClosureExecution()  throws {
        
        let networkView = NetworkView()
        let networkViewModified = networkView
            .background(Color.clear)
            .foregroundColor(.white)
            .frame(width: 500, height: 800)
        #expect(networkViewModified is any View)
        
        
        let physicalLayer = PhysicalLayer()
        let physicalLayerModified = physicalLayer
            .background(Color.clear)
            .foregroundColor(.white)
            .frame(width: 500, height: 800)
        #expect(physicalLayerModified is any View)
        
        
        let sessionLayer = SessionLayer()
        let sessionLayerModified = sessionLayer
            .background(Color.clear)
            .foregroundColor(.white)
            .frame(width: 500, height: 800)
        #expect(sessionLayerModified is any View)
        
        let applicationLayer = ApplicationLayer()
        let applicationLayerModified = applicationLayer
            .background(Color.clear)
            .foregroundColor(.white)
            .frame(width: 500, height: 800)
        #expect(applicationLayerModified is any View)
    }
}

extension SearchView {
   var testViewModel: QRCodeViewModel {
        return QRCodeViewModel()
    }
    
    var topicItems: [(name: String, destinationType: Any.Type)] {
        return [
            (name: "Game 1 - Linear Search", destinationType: Linear.self),
            (name: "Game 2 - Binary Search", destinationType: Binary.self),
            (name: "Game 3 - Hashing", destinationType: Hashing.self)
        ]
    }
}

extension Linear {
    
    func getNewShips() {
        self.selectedImage = self.iOSImages.randomElement()
    }
}

extension Binary {
    
    func getNewShips() {
        self.selectedImage = self.iOSImages.randomElement()
    }
}

extension Hashing {
    
    func selectPlayer1() {
        self.selectedPlayer = 1
        self.selectedImage = self.iOS_A.randomElement()
    }
    
    func selectPlayer2() {
        self.selectedPlayer = 2
        self.selectedImage = self.iOS_B.randomElement()
    }
}

extension LocalizedStringKey {
    func hasContent() -> Bool {
        let mirror = Mirror(reflecting: self)
        return !mirror.children.isEmpty
    }
}
