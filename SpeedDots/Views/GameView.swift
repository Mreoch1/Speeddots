import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.opacity(0.9)
                    .edgesIgnoringSafeArea(.all)
                
                switch viewModel.gameState {
                case .menu:
                    MenuView(viewModel: viewModel)
                        .transition(.opacity)
                case .playing:
                    GamePlayView(viewModel: viewModel)
                        .transition(.opacity)
                case .paused:
                    PauseView(viewModel: viewModel)
                        .transition(.opacity)
                case .gameOver:
                    GameOverView(viewModel: viewModel)
                        .transition(.opacity)
                }
            }
            .onAppear {
                viewModel.setScreenBounds(geometry.frame(in: .global))
            }
            .animation(.easeInOut, value: viewModel.gameState)
        }
    }
}

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("SpeedDots")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("High Score: \(viewModel.highScore)")
                .font(.title2)
                .foregroundColor(.white)
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: true)
        }
    }
}

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Game stats overlay
            VStack {
                HStack {
                    Text("Score: \(viewModel.score)")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Level: \(viewModel.level)")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Time: \(viewModel.timeRemaining)")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding()
                
                Spacer()
            }
            
            // Dots
            ForEach(viewModel.dots) { dot in
                Circle()
                    .fill(dot.color)
                    .frame(width: dot.size, height: dot.size)
                    .position(dot.position)
                    .scaleEffect(dot.scale)
                    .opacity(dot.opacity)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dot.scale)
                    .animation(.easeInOut(duration: 0.3), value: dot.opacity)
                    .onTapGesture {
                        viewModel.dotTapped(dot)
                    }
            }
            
            // Tap effect
            if let tapPosition = viewModel.lastTapPosition {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .position(tapPosition)
                    .scaleEffect(2)
                    .opacity(0)
                    .animation(
                        .easeOut(duration: 0.5)
                        .repeatCount(1, autoreverses: false),
                        value: tapPosition
                    )
            }
            
            // Pause button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.pauseGame()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct PauseView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Paused")
                .font(.title)
                .foregroundColor(.white)
            
            Button(action: {
                viewModel.resumeGame()
            }) {
                Text("Resume")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                viewModel.gameState = .menu
            }) {
                Text("Main Menu")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .transition(.scale)
    }
}

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showHighScore = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("Score: \(viewModel.score)")
                .font(.title)
                .foregroundColor(.white)
            
            if viewModel.score == viewModel.highScore {
                Text("New High Score!")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .opacity(showHighScore ? 1 : 0)
                    .scaleEffect(showHighScore ? 1.2 : 0.8)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            showHighScore = true
                        }
                    }
            }
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Play Again")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                viewModel.gameState = .menu
            }) {
                Text("Main Menu")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .transition(.scale)
    }
}

#Preview {
    GameView()
} 