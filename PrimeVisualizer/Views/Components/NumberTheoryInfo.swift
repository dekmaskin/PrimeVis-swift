import SwiftUI

struct NumberTheoryInfo: View {
    let number: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider()
                .padding(.vertical, 4)
                
            Text("Number Facts:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("Binary: \(String(number, radix: 2))")
                .font(.caption)
            
            Text("Hexadecimal: \(String(number, radix: 16).uppercased())")
                .font(.caption)
            
            if number > 0 {
                Text("Square: \(number * number)")
                    .font(.caption)
                
                if number <= 20 { // Avoid factorial overflow
                    Text("Factorial: \(factorial(number))")
                        .font(.caption)
                }
            }
            
            if number > 1 {
                Text("Sum of digits: \(digitSum(number))")
                    .font(.caption)
                
                Text("Digital root: \(digitalRoot(number))")
                    .font(.caption)
            }
        }
    }
    
    private func factorial(_ n: Int) -> Int {
        if n <= 1 {
            return 1
        }
        return n * factorial(n - 1)
    }
    
    private func digitSum(_ n: Int) -> Int {
        String(n).compactMap { Int(String($0)) }.reduce(0, +)
    }
    
    private func digitalRoot(_ n: Int) -> Int {
        let sum = digitSum(n)
        return sum < 10 ? sum : digitalRoot(sum)
    }
}
