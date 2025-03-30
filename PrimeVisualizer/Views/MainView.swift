//
//  MainView.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @StateObject private var configController = ConfigurationController()
    @StateObject private var visualizationController: VisualizationController
    
    @State private var isShowingLegend = false
    @State private var isShowingAbout = false
    @State private var isShowingSaveDialog = false
    
    init() {
        let config = ConfigurationController()
        _visualizationController = StateObject(wrappedValue: VisualizationController(configController: config))
    }
    
    var body: some View {
        NavigationView {
            ControlPanel(
                configController: configController,
                visualizationController: visualizationController
            )
            .frame(minWidth: 250, idealWidth: 300, maxWidth: 350)
            
            VisualizationView(controller: visualizationController)
                .frame(minWidth: 500, minHeight: 400)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    visualizationController.generateVisualization()
                }) {
                    Label("Generate", systemImage: "wand.and.stars")
                }
                .disabled(visualizationController.isGenerating)
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingSaveDialog = true
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .disabled(visualizationController.currentImage == nil || visualizationController.isGenerating)
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingLegend = true
                }) {
                    Label("Legend", systemImage: "info.circle")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingAbout = true
                }) {
                    Label("About", systemImage: "questionmark.circle")
                }
            }
        }
        .navigationTitle("Prime Visualizer")
        .sheet(isPresented: $isShowingLegend) {
            LegendView(colors: configController.configuration.colors)
                .frame(minWidth: 600, minHeight: 500)
        }
        .sheet(isPresented: $isShowingAbout) {
            AboutView()
                .frame(width: 400, height: 300)
        }
        .fileExporter(
            isPresented: $isShowingSaveDialog,
            document: ImageDocument(image: visualizationController.currentImage),
            contentType: .png,
            defaultFilename: "prime_visualization"
        ) { result in
            if case .success(let url) = result {
                print("Image saved to \(url.path)")
            }
        }
        .alert(
            "Error",
            isPresented: Binding<Bool>(
                get: { visualizationController.errorMessage != nil },
                set: { if !$0 { visualizationController.errorMessage = nil } }
            ),
            presenting: visualizationController.errorMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { errorMessage in
            Text(errorMessage)
        }
    }
}

// MARK: - ImageDocument for file export
struct ImageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    
    var image: NSImage?
    
    init(image: NSImage?) {
        self.image = image
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let nsImage = NSImage(data: data) {
            image = nsImage
        } else {
            image = nil
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data: Data
        
        if let image = image, let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            data = pngData
        } else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        return .init(regularFileWithContents: data)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
