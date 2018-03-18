//
//  EventvodsUITests.swift
//  EventvodsUITests
//
//  Created by Julien Saad on 2018-03-17.
//  Copyright © 2018 Julien Saad. All rights reserved.
//

import XCTest

class EventvodsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.


    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {



        // Use recording to get started writing UI tests.

        let app = XCUIApplication()
        let eventvodsEventsviewNavigationBar = app.navigationBars["Eventvods.EventsView"]
        snapshot("01Home")
        let right1Button = eventvodsEventsviewNavigationBar.buttons["right 1"]
        right1Button.tap()
        snapshot("02Home")
        right1Button.tap()
        snapshot("03Home")

        let left1Button = eventvodsEventsviewNavigationBar.buttons["left 1"]
        left1Button.tap()
        left1Button.tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"Jan 19, 2018 - Mar 17, 2018").staticTexts["LCS Europe 2018"].tap()
        snapshot("04Match")
        tablesQuery.children(matching: .cell).matching(identifier: "MatchTableViewCell").element(boundBy: 2).staticTexts["VS"].tap()
        app.sheets["UOL vs MSF"].buttons["Game Start"].tap()
        snapshot("05Match")
       
    }
    
}
