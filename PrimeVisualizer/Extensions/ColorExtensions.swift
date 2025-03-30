import SwiftUI

extension Color {
    /// Creates a lighter version of the color
    /// - Parameter percentage: Percentage to lighten by (0-100)
    /// - Returns: Lightened color
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        let factor = 1.0 + percentage / 100.0
        
        let r = min(components[0] * factor, 1.0)
        let g = min(components[1] * factor, 1.0)
        let b = min(components[2] * factor, 1.0)
        
        return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
    
    /// Creates a darker version of the color
    /// - Parameter percentage: Percentage to darken by (0-100)
    /// - Returns: Darkened color
    func darker(by percentage: CGFloat = 30.0) -> Color {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        let factor = 1.0 - percentage / 100.0
        
        let r = max(components[0] * factor, 0.0)
        let g = max(components[1] * factor, 0.0)
        let b = max(components[2] * factor, 0.0)
        
        return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
    
    /// Returns a color with adjusted opacity
    /// - Parameter alpha: New opacity value (0-1)
    /// - Returns: Color with adjusted opacity
    func withAlpha(_ alpha: CGFloat) -> Color {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        
        return Color(.sRGB,
                   red: components[0],
                   green: components[1],
                   blue: components[2],
                   opacity: alpha)
    }
    
    /// Determines if the color is light or dark
    /// - Returns: True if the color is light
    func isLight() -> Bool {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        
        // Simplified luminance calculation
        let luminance = 0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]
        
        return luminance > 0.5
    }
}
