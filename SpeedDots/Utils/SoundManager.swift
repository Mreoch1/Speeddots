import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var isSoundEnabled: Bool = true
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func loadSound(name: String, type: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: type) else {
            print("Failed to find sound file: \(name).\(type)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[name] = player
        } catch {
            print("Failed to load sound: \(error)")
        }
    }
    
    func playSound(_ name: String) {
        guard isSoundEnabled, let player = audioPlayers[name] else { return }
        
        if player.isPlaying {
            player.currentTime = 0
        }
        player.play()
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    var soundEnabled: Bool {
        get { isSoundEnabled }
        set { isSoundEnabled = newValue }
    }
} 