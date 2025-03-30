//
//  PrimeVisApp.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import SwiftUI

@main
struct PrimeVisualizerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            // Add menu commands
            CommandGroup(replacing: .newItem) {
                Button("Generate Visualization") {
                    NotificationCenter.default.post(name: .generateVisualization, object: nil)
                }
                .keyboardShortcut("g", modifiers: [.command])
            }
            
            CommandGroup(replacing: .saveItem) {
                Button("Save Visualization...") {
                    NotificationCenter.default.post(name: .saveVisualization, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
            
            CommandMenu("Settings") {
                Button("Reset to Defaults") {
                    NotificationCenter.default.post(name: .resetToDefaults, object: nil)
                }
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let generateVisualization = Notification.Name("generateVisualization")
    static let saveVisualization = Notification.Name("saveVisualization")
    static let resetToDefaults = Notification.Name("resetToDefaults")
}
