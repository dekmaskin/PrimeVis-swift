import Foundation
import SwiftUI
import Combine

class VisualizationController: ObservableObject {
    @Published var isGenerating = false
    @Published var currentImage: NSImage?
    @Published var statistics: VisualizationStatistics?
    @Published var errorMessage: String?
    @Published var zoomLevel: Double = 1.0
    
    private let configController: ConfigurationController
    private var cancellables = Set<AnyCancellable>()
    
    init(configController: ConfigurationController) {
        self.configController = configController
    }
    
    // MARK: - Public Methods
    
    /// Generate a prime visualization based on current settings
    func generateVisualization() {
        guard !isGenerating else { return }
        
        isGenerating = true
        errorMessage = nil
        
        // Get configuration settings
        let config = configController.configuration
        
        // Create a background task for generation
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                print("Starting visualization generation...")
                // Generate the visualization
                let stats = try ImageGenerator.generateVisualization(
                    columns: config.grid.columns,
                    rows: config.grid.rows,
                    dotSize: config.grid.dotSize,
                    spacing: config.grid.spacing,
                    colors: config.colors,
                    backgroundColor: config.grid.backgroundColor,
                    outputPath: self.resolveOutputPath(config.application.defaultOutputFile)
                )
                
                print("Generation completed, loading image...")
                
                // Load the generated image
                let outputPath = self.resolveOutputPath(config.application.defaultOutputFile)
                let image = NSImage(contentsOfFile: outputPath)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    if let image = image {
                        self.currentImage = image
                        self.statistics = stats
                        // Start with zoom = 1, will be adjusted by autoFitImage
                        self.zoomLevel = 1.0
                    } else {
                        self.errorMessage = "Failed to load the generated image"
                    }
                    self.isGenerating = false
                }
            } catch {
                // Handle errors
                print("Error generating visualization: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isGenerating = false
                }
            }
        }
    }
    
    /// Save the current image to a file
    /// - Parameter path: Path to save the image
    /// - Returns: True if successful, false otherwise
    func saveImage(to path: String) -> Bool {
        guard let image = currentImage else {
            errorMessage = "No image to save"
            return false
        }
        
        let resolvedPath = resolveOutputPath(path)
        
        // Ensure directory exists
        let directoryURL = URL(fileURLWithPath: resolvedPath).deletingLastPathComponent()
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                errorMessage = "Failed to create directory: \(error.localizedDescription)"
                return false
            }
        }
        
        // Convert to PNG data
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            errorMessage = "Failed to convert image to PNG format"
            return false
        }
        
        // Write to file
        do {
            try pngData.write(to: URL(fileURLWithPath: resolvedPath))
            return true
        } catch {
            errorMessage = "Failed to write image to file: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Apply zoom to the current image
    /// - Parameter factor: Zoom factor
    func zoom(by factor: Double) {
        zoomLevel *= factor
        
        // Limit zoom range
        zoomLevel = min(max(zoomLevel, 0.1), 5.0)
    }
    
    /// Reset zoom to 100%
    func resetZoom() {
        zoomLevel = 1.0
    }
    
    /// Resolves the output path, expanding ~ to home directory if needed
    /// - Parameter path: Original path
    /// - Returns: Resolved path
    private func resolveOutputPath(_ path: String) -> String {
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
}
