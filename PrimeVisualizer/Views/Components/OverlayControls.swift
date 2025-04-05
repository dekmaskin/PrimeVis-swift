//
//  OverlayControls.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-30.
//


import SwiftUI

struct OverlayControls: View {
    let geometry: GeometryProxy
    @Binding var selectedNumber: Int?
    @Binding var zoomLevel: Double
    let colors: [String: Color]
    let onResetView: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                NavigationControls(
                    zoomLevel: $zoomLevel,
                    selectedNumber: $selectedNumber,
                    onResetView: onResetView
                )
                .padding(8)
            }
            
            Spacer()
            
            if let selectedNumber = selectedNumber {
                NumberDetailPanel(
                    number: selectedNumber,
                    colors: colors
                )
                .padding()
            }
        }
    }
}