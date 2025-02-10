import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var dots: [Dot] = []
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore")
    @Published var gameState: GameState = .menu
    @Published var timeRemaining: Int = 60
    @Published var lastTapPosition: CGPoint?
    @Published var isSoundEnabled: Bool = true {
        didSet {
            SoundManager.shared.soundEnabled = isSoundEnabled
        }
    }
    
    private var screenBounds: CGRect = .zero
    private var dotsToGenerate: Int = 1
    private var timer: Timer?
    private var gameTimer: Timer?
    
    init() {
        loadSoundEffects()
    }
    
    private func loadSoundEffects() {
        SoundManager.shared.loadSound(name: "tap", type: "mp3")
        SoundManager.shared.loadSound(name: "miss", type: "mp3")
        SoundManager.shared.loadSound(name: "levelUp", type: "mp3")
        SoundManager.shared.loadSound(name: "gameOver", type: "mp3")
        SoundManager.shared.loadSound(name: "bonus", type: "mp3")
    }
    
    func startGame() {
        score = 0
        level = 1
        dots = []
        timeRemaining = 60
        gameState = .playing
        dotsToGenerate = 1
        startGameTimer()
        generateNewDot()
    }
    
    func pauseGame() {
        gameState = .paused
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    func resumeGame() {
        gameState = .playing
        startGameTimer()
    }
    
    func endGame() {
        gameState = .gameOver
        gameTimer?.invalidate()
        gameTimer = nil
        updateHighScore()
        SoundManager.shared.playSound("gameOver")
    }
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
    }
    
    func setScreenBounds(_ bounds: CGRect) {
        screenBounds = bounds
    }
    
    func generateNewDot() {
        guard dots.count < level else { return }
        var newDot = Dot(position: Dot.randomPosition(in: screenBounds))
        newDot.color = Dot.randomColor()
        newDot.opacity = 0
        newDot.scale = 0.1
        dots.append(newDot)
        
        // Animate dot appearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let index = self.dots.firstIndex(where: { $0.id == newDot.id }) {
                self.dots[index].opacity = 1.0
                self.dots[index].scale = 1.0
            }
        }
        
        // Set up timer to remove dot if not tapped
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if let index = self.dots.firstIndex(where: { $0.id == newDot.id }) {
                // Play miss sound
                SoundManager.shared.playSound("miss")
                
                // Animate dot disappearance
                self.dots[index].startFadeOut()
                
                // Remove dot after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    self.dots.removeAll(where: { $0.id == newDot.id })
                    self.generateNewDot()
                }
            }
        }
    }
    
    func dotTapped(_ dot: Dot) {
        if let index = dots.firstIndex(where: { $0.id == dot.id }) {
            lastTapPosition = dot.position
            
            // Play tap sound
            SoundManager.shared.playSound("tap")
            
            // Animate successful tap
            dots[index].startTapAnimation()
            
            // Remove dot after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.dots.removeAll(where: { $0.id == dot.id })
                self.score += 100 * self.level
                
                if self.dots.isEmpty {
                    if self.dotsToGenerate >= self.level {
                        self.level += 1
                        self.dotsToGenerate = 1
                        // Play level up sound
                        SoundManager.shared.playSound("levelUp")
                    } else {
                        self.dotsToGenerate += 1
                    }
                    self.generateNewDot()
                }
                
                // Add bonus time for successful tap
                let previousTime = self.timeRemaining
                self.timeRemaining = min(self.timeRemaining + 2, 60)
                if self.timeRemaining > previousTime {
                    SoundManager.shared.playSound("bonus")
                }
                
                self.updateHighScore()
                
                // Clear tap position after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.lastTapPosition = nil
                }
            }
        }
    }
    
    private func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "HighScore")
        }
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    deinit {
        timer?.invalidate()
        gameTimer?.invalidate()
    }
}
