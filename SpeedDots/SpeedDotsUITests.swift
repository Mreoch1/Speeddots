import XCTest

final class SpeedDotsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    // MARK: - Menu Tests
    
    func testMenuInitialState() {
        // Verify menu elements are present
        XCTAssertTrue(app.staticTexts["SpeedDots"].exists)
        XCTAssertTrue(app.buttons["Start Game"].exists)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'High Score'")).firstMatch.exists)
    }
    
    func testStartGameButton() {
        app.buttons["Start Game"].tap()
        
        // Verify game started
        XCTAssertTrue(app.staticTexts["Score: 0"].exists)
        XCTAssertTrue(app.staticTexts["Level: 1"].exists)
        XCTAssertTrue(app.staticTexts["Time: 60"].exists)
    }
    
    // MARK: - Game Play Tests
    
    func testGamePlayElements() {
        // Start game
        app.buttons["Start Game"].tap()
        
        // Verify HUD elements
        XCTAssertTrue(app.staticTexts["Score: 0"].exists)
        XCTAssertTrue(app.staticTexts["Level: 1"].exists)
        XCTAssertTrue(app.staticTexts["Time: 60"].exists)
        
        // Verify pause button exists
        XCTAssertTrue(app.buttons["pause.circle.fill"].exists)
    }
    
    func testPauseAndResume() {
        // Start game
        app.buttons["Start Game"].tap()
        
        // Pause game
        app.buttons["pause.circle.fill"].tap()
        
        // Verify pause menu
        XCTAssertTrue(app.staticTexts["Game Paused"].exists)
        XCTAssertTrue(app.buttons["Resume"].exists)
        XCTAssertTrue(app.buttons["Main Menu"].exists)
        
        // Resume game
        app.buttons["Resume"].tap()
        
        // Verify back in game
        XCTAssertTrue(app.staticTexts["Score: 0"].exists)
    }
    
    func testGameOver() {
        // Start game and wait for time to run out
        app.buttons["Start Game"].tap()
        
        // Wait for game over (this is a long wait, consider mocking time in real tests)
        let gameOverText = app.staticTexts["Game Over!"]
        XCTAssertTrue(gameOverText.waitForExistence(timeout: 61))
        
        // Verify game over elements
        XCTAssertTrue(app.buttons["Play Again"].exists)
        XCTAssertTrue(app.buttons["Main Menu"].exists)
    }
    
    // MARK: - Sound Toggle Tests
    
    func testSoundToggle() {
        // Verify initial state
        let soundButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Sound'")).firstMatch
        XCTAssertTrue(soundButton.exists)
        
        // Toggle sound
        soundButton.tap()
        
        // Toggle back
        soundButton.tap()
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
} 