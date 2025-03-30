import SwiftUI

struct GridSettings: Codable {
    var columns: Int
    var rows: Int
    var dotSize: Int
    var spacing: Int
    var backgroundColor: Color
    
    init(columns: Int = 100, rows: Int = 100, dotSize: Int = 8, spacing: Int = 2, backgroundColor: Color = .white) {
        self.columns = columns
        self.rows = rows
        self.dotSize = dotSize
        self.spacing = spacing
        self.backgroundColor = backgroundColor
    }
    
    enum CodingKeys: String, CodingKey {
        case columns, rows
        case dotSize = "dot_size"
        case spacing
        case backgroundColor = "background_color"
    }
}
