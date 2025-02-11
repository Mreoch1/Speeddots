import XCTest
@testable import SpeedDots

final class SpeedDotsTests: XCTestCase {
    var viewModel: GameViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = GameViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Game State Tests
    
    func testInitialGameState() {
        XCTAssertEqual(viewModel.gameState, .menu)
        XCTAssertEqual(viewModel.score, 0)
        XCTAssertEqual(viewModel.level, 1)
        XCTAssertEqual(viewModel.timeRemaining, 60)
        XCTAssertTrue(viewModel.dots.isEmpty)
    }
    
    func testStartGame() {
        viewModel.startGame()
        XCTAssertEqual(viewModel.gameState, .playing)
        XCTAssertEqual(viewModel.score, 0)
        XCTAssertEqual(viewModel.level, 1)
        XCTAssertEqual(viewModel.timeRemaining, 60)
        XCTAssertFalse(viewModel.dots.isEmpty) // Should generate first dot
    }
    
    // MARK: - Dot Generation Tests
    
    func testDotGeneration() {
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 800)
        viewModel.setScreenBounds(bounds)
        viewModel.generateNewDot()
        
        XCTAssertEqual(viewModel.dots.count, 1)
        let dot = viewModel.dots.first!
        
        // Test dot is within bounds
        XCTAssertTrue(dot.position.x >= 40 && dot.position.x <= bounds.width - 40)
        XCTAssertTrue(dot.position.y >= 40 && dot.position.y <= bounds.height - 40)
    }
    
    // MARK: - Scoring Tests
    
    func testScoring() {
        viewModel.startGame()
        guard let dot = viewModel.dots.first else {
            XCTFail("No dot generated")
            return
        }
        
        viewModel.dotTapped(dot)
        XCTAssertEqual(viewModel.score, 100) // Level 1 score = 100
    }
    
    // MARK: - Level Progression Tests
    
    func testLevelProgression() {
        viewModel.startGame()
        
        // Complete level 1
        for _ in 1...1 {
            guard let dot = viewModel.dots.first else {
                XCTFail("No dot generated")
                return
            }
            viewModel.dotTapped(dot)
        }
        
        XCTAssertEqual(viewModel.level, 2)
    }
    
    // MARK: - Timer Tests
    
    func testGameTimer() {
        viewModel.startGame()
        XCTAssertEqual(viewModel.timeRemaining, 60)
        
        // Wait for 1 second
        let expectation = XCTestExpectation(description: "Timer decrements")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertEqual(self.viewModel.timeRemaining, 59)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }
    
    // MARK: - Sound Tests
    
    func testSoundToggle() {
        XCTAssertTrue(viewModel.isSoundEnabled)
        viewModel.toggleSound()
        XCTAssertFalse(viewModel.isSoundEnabled)
        viewModel.toggleSound()
        XCTAssertTrue(viewModel.isSoundEnabled)
    }
    
    // MARK: - High Score Tests
    
    func testHighScore() {
        let initialHighScore = viewModel.highScore
        viewModel.startGame()
        
        // Score some points
        guard let dot = viewModel.dots.first else {
            XCTFail("No dot generated")
            return
        }
        
        viewModel.dotTapped(dot)
        viewModel.endGame()
        
        XCTAssertEqual(viewModel.highScore, max(initialHighScore, 100))
    }
} 