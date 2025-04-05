import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @StateObject private var configController = ConfigurationController()
    @StateObject private var visualizationController: VisualizationController
    @StateObject private var documentHandler = ImageDocumentHandler()
    
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
            mainContentView
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
                .disabled(visualizationController.isGenerating)
                .help("Save visualization as image")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    visualizationController.toggleVisualizationMode()
                }) {
                    Label(
                        visualizationController.visualizationMode == .interactive ? "Image Mode" : "Interactive Mode",
                        systemImage: visualizationController.visualizationMode == .interactive ? "photo" : "hand.tap"
                    )
                }
                .help(visualizationController.visualizationMode == .interactive ? "Switch to image mode" : "Switch to interactive mode")
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
        Button(action: {
                documentHandler.saveImage(visualizationController.currentImage,
                                         filename: "prime_visualization") { result in
                    switch result {
                    case .success(let url):
                        print("Image saved to \(url.path)")
                    case .failure(let error):
                        print("Failed to save image: \(error.localizedDescription)")
                    }
                }
            }) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(visualizationController.currentImage == nil ||
                      visualizationController.isGenerating)
            .help("Save visualization as image")
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
    
    // MARK: - Main Content View
    
    private var mainContentView: some View {
        Group {
            if visualizationController.isGenerating {
                loadingView
            } else if visualizationController.primePoints.isEmpty {
                placeholderView
            } else if visualizationController.visualizationMode == .interactive {
                InteractiveVisualizationView(
                    controller: visualizationController,
                    columns: configController.configuration.grid.columns,
                    rows: configController.configuration.grid.rows,
                    dotSize: configController.configuration.grid.dotSize,
                    spacing: configController.configuration.grid.spacing,
                    colors: configController.configuration.colors,
                    backgroundColor: configController.configuration.grid.backgroundColor
                )
            } else {
                // Traditional image view
                VisualizationView(controller: visualizationController)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Generating visualization...")
                .font(.headline)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var placeholderView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.3x3.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.secondary)
                .opacity(0.5)
            
            Text("No visualization generated")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Use the controls on the left panel to configure and generate a visualization.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Button("Generate Visualization") {
                visualizationController.generateVisualization()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
