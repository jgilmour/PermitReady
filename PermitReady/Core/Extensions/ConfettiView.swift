import SwiftUI

struct ConfettiView: View {
    let colors: [Color] = [.blue, .green, .yellow, .orange, .red, .purple, .pink]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<100, id: \.self) { index in
                    ConfettiPiece(
                        color: colors.randomElement() ?? .blue,
                        startX: CGFloat.random(in: 0...geometry.size.width),
                        endX: CGFloat.random(in: 0...geometry.size.width),
                        endY: geometry.size.height + 50,
                        delay: Double(index) * 0.005
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

struct ConfettiPiece: View {
    let color: Color
    let startX: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let delay: Double

    @State private var position: CGPoint
    @State private var rotation: Double = 0

    let shapeType = Int.random(in: 0...2)
    let size = CGFloat.random(in: 6...14)

    init(color: Color, startX: CGFloat, endX: CGFloat, endY: CGFloat, delay: Double) {
        self.color = color
        self.startX = startX
        self.endX = endX
        self.endY = endY
        self.delay = delay
        _position = State(initialValue: CGPoint(x: startX, y: -20))
    }

    var body: some View {
        Group {
            if shapeType == 0 {
                Circle()
                    .fill(color)
            } else if shapeType == 1 {
                Rectangle()
                    .fill(color)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
            }
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotation))
        .position(position)
        .onAppear {
            withAnimation(
                .easeIn(duration: Double.random(in: 1.5...3.0))
                .delay(delay)
            ) {
                position = CGPoint(x: endX, y: endY)
                rotation = Double.random(in: 360...1080)
            }
        }
    }
}

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isActive {
                        ConfettiView()
                    }
                }
            )
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    // Auto-dismiss after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isActive = false
                    }
                }
            }
    }
}

extension View {
    func confetti(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive))
    }
}
