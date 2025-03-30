import SwiftUI

struct LegendView: View {
    let colors: [String: Color]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(PrimeType.allCases) { primeType in
                    legendRow(for: primeType)
                }
            }
            .padding()
        }
    }
    
    private func legendRow(for primeType: PrimeType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(colors[primeType.rawValue] ?? .black)
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)
                
                Text(primeType.displayName)
                    .font(.headline)
            }
            
            Text(primeType.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 28)
        }
        .padding(.vertical, 4)
    }
}
