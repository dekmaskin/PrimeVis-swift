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
        _configController = StateObject(wrappedValue: config)
        _visualizationController = StateObject(wrappedValue: VisualizationController(configController: config))
    }
    
    var body: some View {
        NavigationSplitView {
            ControlPanel(
                configController: configController,
                visualizationController: visualizationController
            )
            .frame(minWidth: 250, idealWidth: 300, maxWidth: 350)
        } detail: {
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
                .help("Generate visualization")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingSaveDialog = true
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .disabled(visualizationController.currentImage == nil || visualizationController.isGenerating)
                .help("Save visualization as image")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingLegend = true
                }) {
                    Label("Legend", systemImage: "info.circle")
                }
                .help("Show legend")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isShowingAbout = true
                }) {
                    Label("About", systemImage: "questionmark.circle")
                }
                .help("About Prime Visualizer")
            }
        }
        .navigationTitle("Prime Visualizer")
        .sheet(isPresented: $isShowingLegend) {
            NavigationStack {
                LegendView(colors: configController.configuration.colors)
                    .navigationTitle("Prime Types Legend")
                    // navigationBarTitleDisplayMode not available in macOS
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                isShowingLegend = false
                            }
                        }
                    }
                    .frame(minWidth: 600, minHeight: 500)
            }
        }
        .sheet(isPresented: $isShowingAbout) {
            NavigationStack {
                AboutView()
                    .navigationTitle("About")
                    // navigationBarTitleDisplayMode not available in macOS
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                isShowingAbout = false
                            }
                        }
                    }
                    .frame(width: 400, height: 450)
            }
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
