import Foundation
import SwiftUI

class ConfigurationController: ObservableObject {
    @Published var configuration: Configuration
    
    private let configFileName = "prime_visualizer_config.json"
    private var configURL: URL {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectoryURL = appSupportURL.appendingPathComponent("PrimeVisualizer", isDirectory: true)
        
        if !fileManager.fileExists(atPath: appDirectoryURL.path) {
            try? fileManager.createDirectory(at: appDirectoryURL, withIntermediateDirectories: true)
        }
        
        return appDirectoryURL.appendingPathComponent(configFileName)
    }
    
    init() {
        // Initialize with default configuration first
        self.configuration = Configuration.default
        
        // Then try to load from file, if available
        if let loadedConfig = try? loadConfiguration() {
            self.configuration = loadedConfig
        } else {
            // Save the default configuration if no file exists
            try? saveConfiguration()
        }
    }
    
    // MARK: - Public Methods
    
    /// Update grid settings
    /// - Parameter gridSettings: New grid settings
    func updateGridSettings(_ gridSettings: GridSettings) {
        configuration.grid = gridSettings
        objectWillChange.send()
        try? saveConfiguration()
    }
    
    /// Update a specific color for a prime type
    /// - Parameters:
    ///   - color: New color
    ///   - primeType: Prime type to update
    func updateColor(_ color: Color, for primeType: PrimeType) {
        configuration.colors[primeType.rawValue] = color
        objectWillChange.send()
        try? saveConfiguration()
    }
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        configuration = Configuration.default
        objectWillChange.send()
        try? saveConfiguration()
    }
    
    // MARK: - Private Methods
    
    /// Save configuration to file
    /// - Throws: Error if saving fails
    private func saveConfiguration() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(configuration)
        try data.write(to: configURL)
    }
    
    /// Load configuration from file
    /// - Returns: Configuration object
    /// - Throws: Error if loading fails
    private func loadConfiguration() throws -> Configuration {
        let data = try Data(contentsOf: configURL)
        let decoder = JSONDecoder()
        return try decoder.decode(Configuration.self, from: data)
    }
}
