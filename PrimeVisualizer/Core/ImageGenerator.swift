import Foundation
import SwiftUI
import CoreGraphics
import AppKit

// MARK: - VisualizationError
enum VisualizationError: Error {
    case imageGenerationFailed
    case imageWriteFailed
    case directoryCreationFailed
}

// MARK: - ImageGenerator
class ImageGenerator {
    /// Calculate image dimensions based on grid specifications
    /// - Parameters:
    ///   - columns: Number of dots in the x-axis
    ///   - rows: Number of dots in the y-axis
    ///   - dotSize: Size of each dot in pixels
    ///   - spacing: Spacing between dots in pixels
    /// - Returns: Tuple of image width, height, and total positions
    static func calculateDimensions(
        columns: Int,
        rows: Int,
        dotSize: Int,
        spacing: Int
    ) -> (width: Int, height: Int, totalPositions: Int) {
        let imageWidth = columns * (dotSize + spacing) - spacing
        let imageHeight = rows * (dotSize + spacing) - spacing
        let totalPositions = columns * rows
        
        return (imageWidth, imageHeight, totalPositions)
    }
    
    /// Create a grid with prime positions and their classifications
    /// - Parameters:
    ///   - totalPositions: Total number of positions in the grid
    ///   - columns: Number of columns in the grid
    ///   - rows: Number of rows in the grid
    /// - Returns: Array of PrimePoint objects
    static func createPrimeGrid(
        totalPositions: Int,
        columns: Int,
        rows: Int
    ) -> [PrimePoint] {
        // Generate primes up to the total number of positions
        let primesSet = PrimeGenerator.generatePrimesSet(upTo: totalPositions)
        
        // For each position in the grid, check if it's prime
        var primePoints: [PrimePoint] = []
        
        for pos in 1..<totalPositions {  // Start from 1, not 0
            // Convert position to 2D coordinates
            let x = pos % columns
            let y = pos / columns
            
            if primesSet.contains(pos) {
                let primeType = PrimeClassifier.classifyPrime(pos, primesSet: primesSet)
                primePoints.append(PrimePoint(x: x, y: y, type: primeType))
            }
        }
        
        return primePoints
    }
    
    /// Generate a prime number visualization
    /// - Parameters:
    ///   - columns: Number of columns in the grid
    ///   - rows: Number of rows in the grid
    ///   - dotSize: Size of each dot in pixels
    ///   - spacing: Spacing between dots in pixels
    ///   - colors: Color mapping for prime types
    ///   - backgroundColor: Background color
    ///   - outputPath: Path to save the output image
    /// - Returns: Statistics about the visualization
    static func generateVisualization(
        columns: Int,
        rows: Int,
        dotSize: Int,
        spacing: Int,
        colors: [String: Color],
        backgroundColor: Color,
        outputPath: String
    ) throws -> VisualizationStatistics {
        // Use default values if invalid parameters are provided
        let safeColumns = max(10, columns)
        let safeRows = max(10, rows)
        let safeDotSize = max(1, dotSize)
        let safeSpacing = max(0, spacing)
        
        // Calculate dimensions
        let (width, height, totalPositions) = calculateDimensions(
            columns: safeColumns,
            rows: safeRows,
            dotSize: safeDotSize,
            spacing: safeSpacing
        )
        
        print("Generating visualization with dimensions: \(width)×\(height), totalPositions: \(totalPositions)")
        
        // Generate prime positions
        let primePoints = createPrimeGrid(
            totalPositions: totalPositions,
            columns: safeColumns,
            rows: safeRows
        )
        
        print("Generated \(primePoints.count) prime points")
        
        // Ensure we have a valid path
        let resolvedPath = resolveOutputPath(outputPath)
        print("Saving to path: \(resolvedPath)")
        
        // Draw the visualization
        guard let image = drawVisualization(
            primePoints: primePoints,
            columns: safeColumns,
            rows: safeRows,
            dotSize: safeDotSize,
            spacing: safeSpacing,
            colors: colors,
            backgroundColor: backgroundColor,
            width: width,
            height: height
        ) else {
            print("Failed to draw visualization")
            throw VisualizationError.imageGenerationFailed
        }
        
        // Save the image
        try saveImage(image, to: resolvedPath)
        print("Image saved to \(resolvedPath)")
        
        // Generate and return statistics
        return generateStatistics(
            primePoints: primePoints,
            columns: safeColumns,
            rows: safeRows,
            dotSize: safeDotSize,
            spacing: safeSpacing,
            width: width,
            height: height,
            totalPositions: totalPositions
        )
    }
    
    /// Resolves the output path, expanding ~ to home directory if needed
    /// - Parameter path: Original path
    /// - Returns: Resolved path
    private static func resolveOutputPath(_ path: String) -> String {
        if path.starts(with: "~") {
            let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
            return path.replacingOccurrences(of: "~", with: homeDirectory)
        }
        
        // If it's not an absolute path, save to Documents directory
        if !path.starts(with: "/") {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentsURL.appendingPathComponent(path).path
        }
        
        return path
    }
    
    /// Draw the prime visualization to an image
    /// - Parameters:
    ///   - primePoints: Array of PrimePoint objects
    ///   - columns: Number of columns in the grid
    ///   - rows: Number of rows in the grid
    ///   - dotSize: Size of each dot in pixels
    ///   - spacing: Spacing between dots in pixels
    ///   - colors: Color mapping for prime types
    ///   - backgroundColor: Background color
    ///   - width: Image width
    ///   - height: Image height
    /// - Returns: The generated image
    private static func drawVisualization(
        primePoints: [PrimePoint],
        columns: Int,
        rows: Int,
        dotSize: Int,
        spacing: Int,
        colors: [String: Color],
        backgroundColor: Color,
        width: Int,
        height: Int
    ) -> CGImage? {
        // Create a bitmap context
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        // Ensure width and height are valid
        let safeWidth = max(1, width)
        let safeHeight = max(1, height)
        
        guard let context = CGContext(
            data: nil,
            width: safeWidth,
            height: safeHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            print("Could not create graphics context")
            return nil
        }
        
        // Set background color
        let bgNSColor = NSColor(backgroundColor)
        context.setFillColor(bgNSColor.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: safeWidth, height: safeHeight))
        
        // Draw dots
        for point in primePoints {
            // Get color for this prime type
            let colorKey = point.type.rawValue
            let color = colors[colorKey] ?? .black
            let nsColor = NSColor(color)
            
            context.setFillColor(nsColor.cgColor)
            
            // Calculate position
            let x = point.x * (dotSize + spacing)
            // Flip y-coordinate to match traditional coordinate system
            let y = safeHeight - (point.y * (dotSize + spacing)) - dotSize
            
            // Ensure the coordinates are within bounds
            if x >= 0 && x < safeWidth && y >= 0 && y < safeHeight {
                // Draw circle
                let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                context.fillEllipse(in: rect)
            }
        }
        
        // Return the CGImage
        return context.makeImage()
    }
    
    /// Save a CGImage to the specified path
    /// - Parameters:
    ///   - image: The CGImage to save
    ///   - path: Path to save the image to
    /// - Throws: VisualizationError if saving fails
    private static func saveImage(_ image: CGImage, to path: String) throws {
        // Ensure directory exists
        let directoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
                throw VisualizationError.directoryCreationFailed
            }
        }
        
        // Create NSImage from CGImage
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        
        // Convert to png data
        guard let imageData = nsImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: imageData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            print("Failed to create PNG data")
            throw VisualizationError.imageWriteFailed
        }
        
        // Write to file
        do {
            try pngData.write(to: URL(fileURLWithPath: path))
        } catch {
            print("Failed to write image to file: \(error.localizedDescription)")
            throw VisualizationError.imageWriteFailed
        }
    }
    
    /// Generate statistics about the visualization
    /// - Parameters:
    ///   - primePoints: Array of prime points
    ///   - columns: Number of columns in the grid
    ///   - rows: Number of rows in the grid
    ///   - dotSize: Size of each dot in pixels
    ///   - spacing: Spacing between dots in pixels
    ///   - width: Image width
    ///   - height: Image height
    ///   - totalPositions: Total positions in the grid
    /// - Returns: VisualizationStatistics object
    private static func generateStatistics(
        primePoints: [PrimePoint],
        columns: Int,
        rows: Int,
        dotSize: Int,
        spacing: Int,
        width: Int,
        height: Int,
        totalPositions: Int
    ) -> VisualizationStatistics {
        // Count prime types
        var primeTypeCounts: [PrimeType: Int] = [:]
        
        for point in primePoints {
            let count = primeTypeCounts[point.type] ?? 0
            primeTypeCounts[point.type] = count + 1
        }
        
        // Calculate statistics
        let totalPrimes = primePoints.count
        let density = Double(totalPrimes) / Double(totalPositions) * 100.0
        
        return VisualizationStatistics(
            width: width,
            height: height,
            gridColumns: columns,
            gridRows: rows,
            totalPositions: totalPositions,
            totalPrimes: totalPrimes,
            density: density,
            primeTypes: primeTypeCounts
        )
    }
}
