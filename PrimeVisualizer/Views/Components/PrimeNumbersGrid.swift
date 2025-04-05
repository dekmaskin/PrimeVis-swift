import SwiftUI

struct PrimeNumbersGrid: View {
    let columns: Int
    let rows: Int
    let effectiveDotSize: CGFloat
    let effectiveSpacing: CGFloat
    let colors: [String: Color]
    @Binding var selectedNumber: Int?
    @Binding var hoveredNumber: Int?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Grid background
            if colorScheme == .dark {
                Color(.black).opacity(0.2)
                    .frame(
                        width: CGFloat(columns) * (effectiveDotSize + effectiveSpacing) - effectiveSpacing,
                        height: CGFloat(rows) * (effectiveDotSize + effectiveSpacing) - effectiveSpacing
                    )
            }
            
            // Numbers grid
            ForEach(1..<(columns * rows), id: \.self) { position in
                let x = (position - 1) % columns
                let y = (position - 1) / columns
                
                let posX = CGFloat(x) * (effectiveDotSize + effectiveSpacing)
                let posY = CGFloat(y) * (effectiveDotSize + effectiveSpacing)
                
                // Only show the cell if it's a prime or selected/hovered
                if isPrime(position) || position == selectedNumber || position == hoveredNumber {
                    NumberCell(
                        number: position,
                        size: effectiveDotSize,
                        position: CGPoint(x: posX, y: posY),
                        colors: colors,
                        isSelected: selectedNumber == position,
                        isHovered: hoveredNumber == position,
                        onTap: {
                            // Toggle selection
                            if selectedNumber == position {
                                selectedNumber = nil
                            } else {
                                selectedNumber = position
                            }
                        },
                        onHover: { isHovered in
                            hoveredNumber = isHovered ? position : nil
                        }
                    )
                }
            }
        }
    }
    
    // Quick prime check
    private func isPrime(_ n: Int) -> Bool {
        if n <= 1 {
            return false
        }
        if n <= 3 {
            return true
        }
        if n % 2 == 0 || n % 3 == 0 {
            return false
        }
        
        var i = 5
        while i * i <= n {
            if n % i == 0 || n % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        
        return true
    }
}
