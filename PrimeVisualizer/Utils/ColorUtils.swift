import SwiftUI

struct ColorUtils {
    /// Generates a color scale from one color to another
    /// - Parameters:
    ///   - from: Starting color
    ///   - to: Ending color
    ///   - steps: Number of colors to generate
    /// - Returns: Array of colors forming a gradient
    static func colorScale(from: Color, to: Color, steps: Int) -> [Color] {
        guard steps > 1 else { return [from] }
        
        var colors: [Color] = []
        
        // Extract components
        let fromComponents = from.cgColor?.components ?? [0, 0, 0, 1]
        let toComponents = to.cgColor?.components ?? [1, 1, 1, 1]
        
        for step in 0..<steps {
            let ratio = Double(step) / Double(steps - 1)
            
            let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * ratio
            let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * ratio
            let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * ratio
            
            colors.append(Color(.sRGB, red: r, green: g, blue: b, opacity: 1))
        }
        
        return colors
    }
    
    /// Generates a color that has good contrast with the given color
    /// - Parameter color: Base color
    /// - Returns: Contrasting color (either black or white)
    static func contrastingColor(for color: Color) -> Color {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        
        // Simplified luminance calculation
        let luminance = 0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]
        
        // Return white for dark colors, black for light colors
        return luminance > 0.5 ? .black : .white
    }
    
    /// Converts a hex string to Color
    /// - Parameter hex: Hex color string (e.g., "#FF5500" or "FF5500")
    /// - Returns: Color object
    static func colorFromHex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
    
    /// Converts a Color to hex string
    /// - Parameter color: Color to convert
    /// - Returns: Hex color string (e.g., "#FF5500")
    static func hexFromColor(_ color: Color) -> String {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    /// Generates an array of visually distinct colors
    /// - Parameter count: Number of colors to generate
    /// - Returns: Array of distinct colors
    static func generateDistinctColors(_ count: Int) -> [Color] {
        var colors: [Color] = []
        
        // Golden ratio conjugate
        let hueIncrement = 0.618033988749895
        var hue: Double = 0
        
        for _ in 0..<count {
            hue += hueIncrement
            hue = hue.truncatingRemainder(dividingBy: 1)
            
            let color = Color(hue: hue, saturation: 0.85, brightness: 0.9)
            colors.append(color)
        }
        
        return colors
    }
}
