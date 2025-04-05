import SwiftUI

struct PrimeTypeSpecificInfo: View {
    let number: Int
    let primeType: PrimeType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Special Properties:")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top, 4)
            
            switch primeType {
            case .twinPrime:
                let twinPair = number > 2 ? number - 2 : number + 2
                Text("Forms a twin prime pair with \(twinPair)")
            
            case .mersennePrime:
                if let exponent = getMersenneExponent(number) {
                    Text("Has form 2^\(exponent) - 1")
                }
                
            case .sophieGermainPrime:
                Text("2 × \(number) + 1 = \(2*number+1) is also prime")
                
            case .safePrime:
                Text("(\(number) - 1) ÷ 2 = \((number-1)/2) is also prime")
                
            case .happyPrime:
                Text("Sum of squared digits eventually reaches 1")
                
            case .palindromicPrime:
                Text("\(number) reads the same forwards and backwards")
                
            case .circularPrime:
                Text("All digit rotations of \(number) are prime")
                
            case .sexyPrime:
                let pair = number > 6 ? number - 6 : number + 6
                Text("Forms a sexy prime pair with \(pair)")
                
            case .cubanPrime:
                Text("Has form 3m² + 3m + 1 for some integer m")
                
            case .fibonacciPrime:
                Text("Is both prime and a Fibonacci number")
                
            case .factorialPrime:
                Text("Has form n! ± 1 for some integer n")
                
            default:
                EmptyView()
            }
        }
        .font(.caption)
    }
    
    private func getMersenneExponent(_ n: Int) -> Int? {
        var p = 2
        while (1 << p) - 1 <= n {
            if (1 << p) - 1 == n {
                return p
            }
            p += 1
        }
        return nil
    }
}
