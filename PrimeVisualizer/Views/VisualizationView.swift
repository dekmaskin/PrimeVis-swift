import SwiftUI

struct VisualizationView: View {
    @ObservedObject var controller: VisualizationController
    @State private var frameSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = controller.currentImage {
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        ZStack {
                            Color(.windowBackgroundColor)
                                .frame(width: max(geometry.size.width, image.size.width * controller.zoomLevel),
                                       height: max(geometry.size.height, image.size.height * controller.zoomLevel))
                            
                            imageView(image)
                                .scaleEffect(controller.zoomLevel)
                        }
                    }
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                controller.zoomLevel = value
                            }
                    )
                    .onAppear {
                        // Auto-fit the image when it first appears
                        autoFitImage(image, in: geometry.size)
                    }
                    .onChange(of: geometry.size) { oldSize, newSize in
                        // Adjust zoom when window size changes
                        autoFitImage(image, in: newSize)
                    }
                    .overlay(alignment: .topTrailing) {
                        zoomControls
                            .padding(8)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button(action: {
                            autoFitImage(image, in: geometry.size)
                        }) {
                            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                .padding(4)
                        }
                        .buttonStyle(.borderless)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                        .padding(8)
                        .help("Fit to window")
                    }
                } else {
                    placeholderView
                }
            }
            .background(Color(.windowBackgroundColor))
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    // MARK: - Subviews
    
    private func imageView(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.none) // Maintains pixel-perfect rendering
            .aspectRatio(contentMode: .fit)
            .background(Color.white)
            .border(Color.gray.opacity(0.3), width: 1)
            .shadow(radius: 3)
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
                controller.generateVisualization()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var zoomControls: some View {
        HStack(spacing: 4) {
            Button(action: {
                controller.zoom(by: 0.8)
            }) {
                Image(systemName: "minus.magnifyingglass")
                    .padding(4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .help("Zoom out")
            
            Button(action: {
                controller.resetZoom()
            }) {
                Text("\(Int(controller.zoomLevel * 100))%")
                    .font(.caption)
                    .monospacedDigit()
                    .frame(minWidth: 44)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .help("Reset zoom")
            
            Button(action: {
                controller.zoom(by: 1.25)
            }) {
                Image(systemName: "plus.magnifyingglass")
                    .padding(4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .help("Zoom in")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Automatically fits the image to the available space
    private func autoFitImage(_ image: NSImage, in size: CGSize) {
        let widthRatio = size.width / image.size.width
        let heightRatio = size.height / image.size.height
        
        // Use the smaller ratio to ensure the entire image fits
        let fitZoom = min(widthRatio, heightRatio) * 0.95 // 5% margin
        
        // Don't zoom too much in either direction
        let clampedZoom = min(max(fitZoom, 0.1), 2.0)
        
        controller.zoomLevel = clampedZoom
    }
}
