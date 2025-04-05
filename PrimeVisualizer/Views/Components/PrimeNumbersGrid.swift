import SwiftUI

struct PrimeNumbersGrid: View {
    let columns: Int
    let rows: Int
    let effectiveDotSize: CGFloat
    let effectiveSpacing: CGFloat
    let colors: [String: Color]
    @Binding var selectedNumber: Int?
    @Binding var hoveredNumber: Int?
    
    var body: some View {
        ZStack {
            // Numbers grid
            ForEach(1..<(columns * rows), id: \.self) { position in
                let x = (position - 1) % columns
                let y = (position - 1) / columns
                
                let posX = CGFloat(x) * (effectiveDotSize + effectiveSpacing)
                let posY = CGFloat(y) * (effectiveDotSize + effectiveSpacing)
                
                NumberCell(
                    number: position,
                    size: effectiveDotSize,
                    position: CGPoint(x: posX, y: posY),
                    colors: colors,
                    isSelected: selectedNumber == position,
                    isHovered: hoveredNumber == position,
                    onClick: {
                        selectedNumber = position
                    },
                    onHover: { isHovered in
                        hoveredNumber = isHovered ? position : nil
                    }
                )
            }
        }
    }
}
