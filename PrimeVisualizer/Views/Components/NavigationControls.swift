//
//  NavigationControls.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-30.
//


import SwiftUI

struct NavigationControls: View {
    @Binding var zoomLevel: Double
    @Binding var selectedNumber: Int?
    let onResetView: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Button(action: {
                zoomLevel = max(zoomLevel * 0.8, 0.1)
            }) {
                Image(systemName: "minus.magnifyingglass")
                    .padding(4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .help("Zoom out")
            
            Button(action: {
                onResetView()
                zoomLevel = 1.0
            }) {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                    .padding(4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .help("Reset view")
            
            Button(action: {
                zoomLevel = min(zoomLevel * 1.25, 5.0)
            }) {
                Image(systemName: "plus.magnifyingglass")
                    .padding(4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .help("Zoom in")
            
            Text("\(Int(zoomLevel * 100))%")
                .font(.caption)
                .monospacedDigit()
                .frame(minWidth: 44)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
            
            Button(action: {
                selectedNumber = nil
            }) {
                Image(systemName: "xmark")
                    .padding(4)
            }
            .buttonStyle(.borderless)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .help("Clear selection")
            .opacity(selectedNumber != nil ? 1.0 : 0.5)
            .disabled(selectedNumber == nil)
        }
    }
}