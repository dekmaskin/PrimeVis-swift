import SwiftUI

struct NumberDetailPanel: View {
    let number: Int
    let colors: [String: Color]
    
    private var isPrime: Bool {
        PrimeGenerator.isPrime(number)
    }
    
    private var primeType: PrimeType? {
        isPrime ? PrimeClassifier.classifyPrime(number, primesSet: PrimeGenerator.generatePrimesSet(upTo: number + 10)) : nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Number: \(number)")
                    .font(.headline)
                
                Spacer()
                
                if isPrime {
                    Text("PRIME")
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .cornerRadius(4)
                } else {
                    Text("NOT PRIME")
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
            
            if let primeType = primeType {
                HStack {
                    Text("Type:")
                        .fontWeight(.medium)
                    
                    Text(primeType.displayName)
                    
                    Rectangle()
                        .fill(colors[primeType.rawValue] ?? .black)
                        .frame(width: 16, height: 16)
                        .cornerRadius(2)
                }
                
                Text(primeType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Enhanced prime number information
                if primeType != .regularPrime {
                    PrimeTypeSpecificInfo(number: number, primeType: primeType)
                }
            }
            
            // Add factors for non-prime numbers
            if !isPrime {
                Text("Factors: \(factorsString(for: number))")
                    .font(.caption)
            }
            
            // Add number theory information
            NumberTheoryInfo(number: number)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .frame(maxWidth: 300)
    }
    
    private func factorsString(for number: Int) -> String {
        if number < 2 {
            return number == 0 ? "None (Zero)" : "1"
        }
        
        var factors = [Int]()
        let sqrtNum = Int(sqrt(Double(number)))
        
        for i in 1...sqrtNum {
            if number % i == 0 {
                factors.append(i)
                if i != number / i {
                    factors.append(number / i)
                }
            }
        }
        
        return factors.sorted().map(String.init).joined(separator: ", ")
    }
}