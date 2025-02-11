import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var timeRemaining: Int = 60
    @Published var dots: [Dot] = []
    @Published var isSoundEnabled: Bool = true
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore")
    
    private var timer: Timer?
    private var screenBounds: CGRect = .zero
    
    func startGame() {
        gameState = .playing
        score = 0
        level = 1
        timeRemaining = 60
        dots.removeAll()
        generateNewDot()
        startTimer()
    }
    
    func setScreenBounds(_ bounds: CGRect) {
        screenBounds = bounds
    }
    
    func generateNewDot() {
        let padding: CGFloat = 40
        let x = CGFloat.random(in: padding...(screenBounds.width - padding))
        let y = CGFloat.random(in: padding...(screenBounds.height - padding))
        let dot = Dot(position: CGPoint(x: x, y: y))
        dots = [dot]
    }
    
    func dotTapped(_ dot: Dot) {
        score += 100 * level
        if score >= level * 1000 {
            level += 1
        }
        generateNewDot()
        if isSoundEnabled {
            playTapSound()
        }
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func endGame() {
        gameState = .gameOver
        timer?.invalidate()
        timer = nil
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "HighScore")
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
    }
    
    private func playTapSound() {
        // Sound implementation would go here
    }
}

struct Dot: Identifiable {
    let id = UUID()
    let position: CGPoint
}
