//
//  AboutView.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.3x3.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("Prime Visualizer")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("A tool for visualizing the distribution and patterns of prime numbers in a grid, with color-coding for different types of primes.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Features:")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                FeatureRow(text: "Generate visual representations of prime numbers")
                FeatureRow(text: "Identify and color-code different types of primes")
                FeatureRow(text: "Customize grid size, colors, and display options")
                FeatureRow(text: "Save visualizations as PNG images")
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 400)
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(text)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
