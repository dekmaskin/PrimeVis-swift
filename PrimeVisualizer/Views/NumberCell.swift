import SwiftUI

struct NumberCell: View {
    let number: Int
    let size: CGFloat
    let position: CGPoint
    let colors: [String: Color]
    let isSelected: Bool
    let isHovered: Bool
    let onClick: () -> Void
    let onHover: (Bool) -> Void
    
    // Cache prime status
    private var isPrime: Bool {
        PrimeGenerator.isPrime(number)
    }
    
    // Cache prime type
    private var primeType: PrimeType? {
        if isPrime {
            return PrimeClassifier.classifyPrime(number, primesSet: PrimeGenerator.generatePrimesSet(upTo: number + 10))
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            if isPrime, let type = primeType {
                Circle()
                    .fill(colors[type.rawValue] ?? .black)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: isSelected ? 2 : 0)
                    )
                    .overlay(
                        Circle()
                            .stroke(isHovered ? Color.yellow : Color.clear, lineWidth: isHovered ? 1 : 0)
                    )
            }
            
            // Show number if zoomed in enough
            if size >= 16 {
                Text("\(number)")
                    .font(.system(size: min(size * 0.5, 12)))
                    .foregroundColor(isPrime ? (colors[primeType?.rawValue ?? ""] ?? .black).isLight() ? .black : .white : .clear)
                    .opacity(size >= 20 ? 1 : 0)
            }
        }
        .position(x: position.x + size/2, y: position.y + size/2)
        .onTapGesture {
            onClick()
        }
        .onHover { hovering in
            onHover(hovering)
        }
    }
}