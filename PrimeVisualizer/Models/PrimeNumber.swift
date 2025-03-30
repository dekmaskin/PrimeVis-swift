//
//  PrimeNumber.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import Foundation
import SwiftUI

// MARK: - PrimeType Enum
enum PrimeType: String, CaseIterable, Identifiable, Codable {
    case regularPrime = "regular_prime"
    case twinPrime = "twin_prime"
    case mersennePrime = "mersenne_prime"
    case safePrime = "safe_prime"
    case palindromicPrime = "palindromic_prime"
    case circularPrime = "circular_prime"
    case sophieGermainPrime = "sophie_germain_prime"
    case factorialPrime = "factorial_prime"
    case fibonacciPrime = "fibonacci_prime"
    case sexyPrime = "sexy_prime"
    case cubanPrime = "cuban_prime"
    case happyPrime = "happy_prime"
    case chenPrime = "chen_prime"
    case wieferichPrime = "wieferich_prime"
    case isolatedPrime = "isolated_prime"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        rawValue.split(separator: "_").map { $0.capitalized }.joined(separator: " ")
    }
    
    var description: String {
        switch self {
        case .regularPrime:
            return "Standard prime numbers"
        case .twinPrime:
            return "Primes that differ by 2 (e.g., 3 and 5)"
        case .mersennePrime:
            return "Primes of form 2^p-1"
        case .safePrime:
            return "Primes p where (p-1)/2 is also prime"
        case .palindromicPrime:
            return "Primes that read the same backward"
        case .circularPrime:
            return "All rotations of digits are prime"
        case .sophieGermainPrime:
            return "Primes p where 2p+1 is also prime"
        case .factorialPrime:
            return "Primes of form n!±1"
        case .fibonacciPrime:
            return "Primes that are also Fibonacci numbers"
        case .sexyPrime:
            return "Primes that differ by 6"
        case .cubanPrime:
            return "Primes of form (3m²+3m+1)"
        case .happyPrime:
            return "Primes that are also happy numbers"
        case .chenPrime:
            return "Primes p where p+2 is prime or semiprime"
        case .wieferichPrime:
            return "Primes p where 2^(p-1)≡1 (mod p²)"
        case .isolatedPrime:
            return "Primes with no primes at distance 2"
        }
    }
}

// MARK: - Color Codable Extensions
extension Color {
    // Encode and decode Color
    init(rgbArray: [Int]) {
        self.init(
            .sRGB,
            red: Double(rgbArray[0]) / 255.0,
            green: Double(rgbArray[1]) / 255.0,
            blue: Double(rgbArray[2]) / 255.0,
            opacity: 1.0
        )
    }
    
    var rgbArray: [Int] {
        let components = self.cgColor?.components ?? [0, 0, 0, 0]
        return [
            Int(components[0] * 255),
            Int(components[1] * 255),
            Int(components[2] * 255)
        ]
    }
}

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rgbArray = try container.decode([Int].self)
        self.init(rgbArray: rgbArray)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rgbArray)
    }
}



// MARK: - Prime Point Model
struct PrimePoint {
    let x: Int
    let y: Int
    let type: PrimeType
}

// MARK: - VisualizationStatistics Model
struct VisualizationStatistics {
    let width: Int
    let height: Int
    let gridColumns: Int
    let gridRows: Int
    let totalPositions: Int
    let totalPrimes: Int
    let density: Double
    let primeTypes: [PrimeType: Int]
    
    var formattedDensity: String {
        String(format: "%.2f%%", density)
    }
}
