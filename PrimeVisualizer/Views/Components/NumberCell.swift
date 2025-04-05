import SwiftUI

struct NumberCell: View {
    let number: Int
    let size: CGFloat
    let position: CGPoint
    let colors: [String: Color]
    let isSelected: Bool
    let isHovered: Bool
    let onTap: () -> Void
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
                    .shadow(color: isSelected ? .white.opacity(0.5) : .clear, radius: isSelected ? 4 : 0)
            } else if !isPrime && (isSelected || isHovered) {
                // Show a placeholder for non-prime numbers that are selected or hovered
                Circle()
                    .stroke(isSelected ? Color.white : Color.gray, lineWidth: 1)
                    .frame(width: size, height: size)
            }
        }
        .position(x: position.x + size/2, y: position.y + size/2)
        .onTapGesture {
            onTap()
        }
        .onHover { hovering in
            onHover(hovering)
        }
        // Make the cell slightly larger when hovered for better interaction
        .scaleEffect(isHovered ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        // Make the hit area larger than the visual size
        .contentShape(Circle().size(CGSize(width: max(size, 20), height: max(size, 20))))
    }
    
    // Determine text color based on background color
    private func textColor() -> Color {
        if !isPrime {
            return isSelected ? .white : .gray
        }
        
        if let type = primeType, let color = colors[type.rawValue] {
            // Check if color is light or dark
            let components = color.cgColor?.components ?? [0, 0, 0, 1]
            let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
            
            return brightness > 0.5 ? .black : .white
        }
        
        return .white
    }
}
