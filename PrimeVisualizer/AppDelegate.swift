//
//  AppDelegate.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Application setup code
        setupDefaults()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Application cleanup code
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func setupDefaults() {
        // Create application support directory if needed
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectoryURL = appSupportURL.appendingPathComponent("PrimeVisualizer", isDirectory: true)
        
        if !fileManager.fileExists(atPath: appDirectoryURL.path) {
            try? fileManager.createDirectory(at: appDirectoryURL, withIntermediateDirectories: true)
        }
    }
}
