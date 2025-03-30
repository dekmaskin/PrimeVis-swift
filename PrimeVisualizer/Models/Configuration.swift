//
//  Configuration.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import Foundation
import SwiftUI

struct Configuration: Codable {
    var grid: GridSettings
    var colors: [String: Color]
    var application: ApplicationSettings
    
    struct ApplicationSettings: Codable {
        var defaultOutputFile: String
        var enableStatistics: Bool
        var saveConfigOnExit: Bool
        
        enum CodingKeys: String, CodingKey {
            case defaultOutputFile = "default_output_file"
            case enableStatistics = "enable_statistics"
            case saveConfigOnExit = "save_config_on_exit"
        }
    }
    
    static var `default`: Configuration {
        Configuration(
            grid: GridSettings(),
            colors: [
                PrimeType.regularPrime.rawValue: Color.black,
                PrimeType.twinPrime.rawValue: Color.red,
                PrimeType.mersennePrime.rawValue: Color.green,
                PrimeType.safePrime.rawValue: Color.blue
            ],
            application: ApplicationSettings(
                defaultOutputFile: "prime_visualization.png",
                enableStatistics: true,
                saveConfigOnExit: true
            )
        )
    }
}
