//
//  LegendView.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import SwiftUI

struct LegendView: View {
    let colors: [String: Color]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("Prime Types Legend")
                    .font(.title)
                    .padding(.top)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            legendTable
                .padding()
            
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom)
        }
    }
    
    private var legendTable: some View {
        Table(PrimeType.allCases) {
            TableColumn("Color") { primeType in
                Rectangle()
                    .fill(colors[primeType.rawValue] ?? .black)
                    .frame(width: 30, height: 20)
                    .cornerRadius(4)
            }
            .width(50)
            
            TableColumn("Prime Type") { primeType in
                Text(primeType.displayName)
                    .fontWeight(.medium)
            }
            .width(min: 150, ideal: 180)
            
            TableColumn("Description") { primeType in
                Text(primeType.description)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .width(min: 280, ideal: 350)
        }
    }
}

struct LegendView_Previews: PreviewProvider {
    static var previews: some View {
        let defaultColors: [String: Color] = [
            PrimeType.regularPrime.rawValue: .black,
            PrimeType.twinPrime.rawValue: .red,
            PrimeType.mersennePrime.rawValue: .green,
            PrimeType.safePrime.rawValue: .blue
        ]
        
        LegendView(colors: defaultColors)
            .frame(width: 650, height: 500)
    }
}
