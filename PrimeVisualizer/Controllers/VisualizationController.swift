import Foundation
import SwiftUI
import Combine
import AppKit

class VisualizationController: ObservableObject {
    @Published var isGenerating = false
    @Published var currentImage: NSImage?
    @Published var statistics: VisualizationStatistics?
    @Published var errorMessage: String?
    @Published var zoomLevel: Double = 1.0
    @Published var visualizationMode: VisualizationMode = .interactive
    @Published var selectedNumber: Int? = nil
    
    // For interactive mode
    @Published var primePoints: [PrimePoint] = []
    @Published var gridColumns: Int = 100
    @Published var gridRows: Int = 100
    
    private let configController: ConfigurationController
    private var cancellables = Set<AnyCancellable>()
    
    init(configController: ConfigurationController) {
        self.configController = configController
        
        // Update grid settings when configuration changes
        configController.$configuration
            .sink { [weak self] config in
                self?.gridColumns = config.grid.columns
                self?.gridRows = config.grid.rows
            }
            .store(in: &cancellables)
            
        // Generate visualization on initialization after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.generateVisualization()
        }
    }
    
    enum VisualizationMode {
        case interactive
        case image
    }
    
    // MARK: - Public Methods
    
    /// Generate a prime visualization based on current settings
    func generateVisualization() {
        guard !isGenerating else { return }
        
        isGenerating = true
        errorMessage = nil
        selectedNumber = nil
        
        // Get configuration settings
        let config = configController.configuration
        
        // Create a background task for generation
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                print("Starting visualization generation...")
                
                // Calculate dimensions
                let (width, height, totalPositions) = ImageGenerator.calculateDimensions(
                    columns: config.grid.columns,
                    rows: config.grid.rows,
                    dotSize: config.grid.dotSize,
                    spacing: config.grid.spacing
                )
                
                // Generate prime points
                let primePoints = ImageGenerator.createPrimeGrid(
                    totalPositions: totalPositions,
                    columns: config.grid.columns,
                    rows: config.grid.rows
                )
                
                // Generate statistics
                let stats = ImageGenerator.generateStatistics(
                    primePoints: primePoints,
                    columns: config.grid.columns,
                    rows: config.grid.rows,
                    dotSize: config.grid.dotSize,
                    spacing: config.grid.spacing,
                    width: width,
                    height: height,
                    totalPositions: totalPositions
                )
                
                if self.visualizationMode == .image {
                    // Generate the image using existing code
                    let stats = try ImageGenerator.generateVisualization(
                        columns: config.grid.columns,
                        rows: config.grid.rows,
                        dotSize: config.grid.dotSize,
                        spacing: config.grid.spacing,
                        colors: config.colors,
                        backgroundColor: config.grid.backgroundColor,
                        outputPath: self.resolveOutputPath(config.application.defaultOutputFile)
                    )
                    
                    // Load the generated image
                    let outputPath = self.resolveOutputPath(config.application.defaultOutputFile)
                    let image = NSImage(contentsOfFile: outputPath)
                    
                    // Update UI on main thread
                    DispatchQueue.main.async {
                        if let image = image {
                            self.currentImage = image
                            self.statistics = stats
                            self.zoomLevel = 1.0
                            self.primePoints = primePoints
                        } else {
                            self.errorMessage = "Failed to load the generated image"
                        }
                        self.isGenerating = false
                    }
                } else {
                    // For interactive mode, just update the prime points
                    DispatchQueue.main.async {
                        self.statistics = stats
                        self.primePoints = primePoints
                        self.isGenerating = false
                    }
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
    
    /// Generate an image from the current interactive visualization
    func generateImageFromInteractive(completion: @escaping (Bool) -> Void) {
        guard !isGenerating else {
            completion(false)
            return
        }
        
        isGenerating = true
        
        // Get configuration settings
        let config = configController.configuration
        let outputPath = resolveOutputPath(config.application.defaultOutputFile)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    self?.isGenerating = false
                    completion(false)
                }
                return
            }
            
            do {
                // Generate the image using existing code
                _ = try ImageGenerator.generateVisualization(
                    columns: config.grid.columns,
                    rows: config.grid.rows,
                    dotSize: config.grid.dotSize,
                    spacing: config.grid.spacing,
                    colors: config.colors,
                    backgroundColor: config.grid.backgroundColor,
                    outputPath: outputPath
                )
                
                // Load the generated image
                let image = NSImage(contentsOfFile: outputPath)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    if let image = image {
                        self.currentImage = image
                    }
                    self.isGenerating = false
                    completion(true)
                }
            } catch {
                print("Error generating image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isGenerating = false
                    completion(false)
                }
            }
        }
    }
    
    /// Generate and save an image from the current view
    func saveCurrentViewAsImage(to path: String, completion: @escaping (Bool) -> Void) {
        // If we already have an image and are in image mode, just save it
        if visualizationMode == .image, let currentImage = currentImage {
            let success = saveImage(currentImage, to: path)
            completion(success)
            return
        }
        
        // Otherwise, we need to generate an image from the interactive view
        generateImageFromInteractive { [weak self] success in
            guard let self = self, success, let image = self.currentImage else {
                completion(false)
                return
            }
            
            let saveSuccess = self.saveImage(image, to: path)
            completion(saveSuccess)
        }
    }
    
    /// Save an image to a file
    /// - Parameters:
    ///   - image: The image to save
    ///   - path: Path to save the image
    /// - Returns: True if successful, false otherwise
    func saveImage(_ image: NSImage, to path: String) -> Bool {
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
    
    /// Switch between interactive and image modes
    func toggleVisualizationMode() {
        if visualizationMode == .interactive {
            visualizationMode = .image
            // Generate image if needed
            if currentImage == nil {
                generateImageFromInteractive { _ in }
            }
        } else {
            visualizationMode = .interactive
        }
    }
    
    /// Get prime type for a number
    func getPrimeTypeForNumber(_ number: Int) -> PrimeType? {
        guard PrimeGenerator.isPrime(number) else { return nil }
        
        return PrimeClassifier.classifyPrime(
            number,
            primesSet: PrimeGenerator.generatePrimesSet(upTo: number + 10)
        )
    }
    
    /// Apply zoom to the current view
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
