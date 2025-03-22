//
//  unpluggedCSUITests.swift
//  unpluggedCSUITests
//
//  Created by Ahmed Ibrahim on 15/10/2024.
//

import XCTest

final class unpluggedCSUITests: XCTestCase {

    override func setUpWithError() throws {
        // Stop immediately when a failure occurs.
        continueAfterFailure = false
        // Set any initial state required for tests here.
    }

    override func tearDownWithError() throws {
        // Cleanup code here.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        let startLabel = app.staticTexts["Start"]
        XCTAssertTrue(startLabel.waitForExistence(timeout: 5), "Start view did not appear.")

        #if os(iOS)
        let nameTextField = app.textFields["Enter name"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 5), "Name text field not found on Start view.")
        nameTextField.tap()
        nameTextField.typeText("TestUser")

        let goButton = app.buttons["Go!"]
        XCTAssertTrue(goButton.waitForExistence(timeout: 5), "Go button not found on Start view.")
        goButton.tap()

        let homeGreeting = app.staticTexts["Hello, TestUser"]
        XCTAssertTrue(homeGreeting.waitForExistence(timeout: 5), "Home view did not appear with the correct greeting.")

        let topicLabel = app.staticTexts["Bit Manipulation"]
        XCTAssertTrue(topicLabel.waitForExistence(timeout: 5), "Expected topic 'Bit Manipulation' not found on Home view.")

        #elseif os(tvOS)
        
        let goButton = app.buttons["Go!"]
        XCTAssertTrue(goButton.waitForExistence(timeout: 5), "Go button not found on Start view (tvOS).")
        XCUIRemote.shared.press(.right)
        XCUIRemote.shared.press(.select)
        
        let greetingPredicate = NSPredicate(format: "label BEGINSWITH 'Hello,'")
        let greetingElement = app.staticTexts.element(matching: greetingPredicate)
        XCTAssertTrue(greetingElement.waitForExistence(timeout: 5), "Home view did not appear with a greeting on tvOS.")
        
        let topicLabel = app.staticTexts["Bit Manipulation"]
        XCTAssertTrue(topicLabel.waitForExistence(timeout: 5), "Expected topic 'Bit Manipulation' not found on Home view (tvOS).")
        #endif
    }
    
    func testAccessibility() throws {
        let app = XCUIApplication()
        app.launch()
        try app.performAccessibilityAudit()
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
