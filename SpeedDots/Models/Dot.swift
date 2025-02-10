import SwiftUI

struct Dot: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isActive: Bool = true
    var size: CGFloat = 40
    var color: Color = .red
    var createdAt: Date = Date()
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    
    static let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    static func randomPosition(in bounds: CGRect) -> CGPoint {
        let padding: CGFloat = 40
        let x = CGFloat.random(in: padding...(bounds.width - padding))
        let y = CGFloat.random(in: padding...(bounds.height - padding))
        return CGPoint(x: x, y: y)
    }
    
    static func randomColor() -> Color {
        colors.randomElement() ?? .red
    }
    
    mutating func startFadeOut() {
        opacity = 0.0
        scale = 0.1
    }
    
    mutating func startTapAnimation() {
        scale = 1.5
        opacity = 0.0
    }
}
