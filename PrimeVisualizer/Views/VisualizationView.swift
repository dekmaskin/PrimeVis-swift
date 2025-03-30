//
//  VisualizationView.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import SwiftUI

struct VisualizationView: View {
    @ObservedObject var controller: VisualizationController
    
    var body: some View {
        VStack {
            if let image = controller.currentImage {
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    imageView(image)
                        .scaleEffect(controller.zoomLevel)
                }
                .overlay(alignment: .topTrailing) {
                    zoomControls
                        .padding(8)
                }
            } else {
                placeholderView
            }
        }
        .background(Color(.windowBackgroundColor))
    }
    
    // MARK: - Subviews
    
    private func imageView(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.none) // Maintains pixel-perfect rendering
            .aspectRatio(contentMode: .fit)
            .background(Color.white)
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
            
            Button(action: {
                controller.zoom(by: 1.25)
            }) {
                Image(systemName: "plus.magnifyingglass")
                    .padding(4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
        }
    }
}

struct VisualizationView_Previews: PreviewProvider {
    static var previews: some View {
        let configController = ConfigurationController()
        let vizController = VisualizationController(configController: configController)
        
        VisualizationView(controller: vizController)
    }
}
