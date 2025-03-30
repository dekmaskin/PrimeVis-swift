//
//  PrimeClassifier.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//
import Foundation

class PrimeClassifier {
    /// Checks if a number is part of a twin prime pair (p, p+2)
    /// - Parameters:
    ///   - n: The number to check
    ///   - primesSet: Set of primes to check against
    /// - Returns: True if n is part of a twin prime pair
    static func isTwinPrime(_ n: Int, primesSet: Set<Int>) -> Bool {
        return primesSet.contains(n) && (primesSet.contains(n - 2) || primesSet.contains(n + 2))
    }
    
    /// Checks if a number is a Mersenne prime (2^p - 1)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a Mersenne prime
    static func isMersennePrime(_ n: Int) -> Bool {
        // First check if n is prime
        if !PrimeGenerator.isPrime(n) {
            return false
        }
        
        // Check if n is of the form 2^p - 1
        let nPlus1 = n + 1
        if nPlus1 & (nPlus1 - 1) != 0 { // Check if n+1 is a power of 2
            return false
        }
        
        // Check if the exponent p is also prime
        let p = log2(Double(nPlus1))
        return PrimeGenerator.isPrime(Int(p))
    }
    
    /// Checks if a number is a safe prime (p where (p-1)/2 is also prime)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a safe prime
    static func isSafePrime(_ n: Int) -> Bool {
        return n > 2 && PrimeGenerator.isPrime(n) && PrimeGenerator.isPrime((n - 1) / 2)
    }
    
    /// Checks if a number is a Sophie Germain prime (p where 2p+1 is also prime)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a Sophie Germain prime
    static func isSophieGermainPrime(_ n: Int) -> Bool {
        return PrimeGenerator.isPrime(n) && PrimeGenerator.isPrime(2 * n + 1)
    }
    
    /// Checks if a number is a palindromic prime (reads the same forwards and backwards)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a palindromic prime
    static func isPalindromicPrime(_ n: Int) -> Bool {
        let str = String(n)
        return PrimeGenerator.isPrime(n) && str == String(str.reversed())
    }
    
    /// Checks if a number is a circular prime (all rotations of its digits are prime)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a circular prime
    static func isCircularPrime(_ n: Int) -> Bool {
        if !PrimeGenerator.isPrime(n) {
            return false
        }
        
        let strN = String(n)
        // Single digit primes are automatically circular
        if strN.count == 1 {
            return true
        }
        
        // Check all rotations
        for i in 1..<strN.count {
            let rotatedStr = String(strN.suffix(strN.count - i) + strN.prefix(i))
            if let rotated = Int(rotatedStr), !PrimeGenerator.isPrime(rotated) {
                return false
            }
        }
        
        return true
    }
    
    /// Checks if a number is a factorial prime (of the form n! ± 1)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a factorial prime
    static func isFactorialPrime(_ n: Int) -> Bool {
        if !PrimeGenerator.isPrime(n) {
            return false
        }
        
        // Check if n is of the form i! + 1 or i! - 1 for some i
        var factorial = 1
        var i = 1
        
        // Check up to a reasonable limit
        while factorial < n + 1 && i < 20 {
            factorial *= i
            if n == factorial - 1 || n == factorial + 1 {
                return true
            }
            i += 1
        }
        
        return false
    }
    
    /// Checks if a number is a Fibonacci prime (a prime that is also a Fibonacci number)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a Fibonacci prime
    static func isFibonacciPrime(_ n: Int) -> Bool {
        if !PrimeGenerator.isPrime(n) {
            return false
        }
        
        // A number is Fibonacci if and only if 5n² + 4 or 5n² - 4 is a perfect square
        func isPerfectSquare(_ x: Int) -> Bool {
            let sqrt = Int(sqrt(Double(x)))
            return sqrt * sqrt == x
        }
        
        return isPerfectSquare(5 * n * n + 4) || isPerfectSquare(5 * n * n - 4)
    }
    
    /// Checks if a number is part of a sexy prime pair (primes p, p+6)
    /// - Parameters:
    ///   - n: The number to check
    ///   - primesSet: Set of primes to check against
    /// - Returns: True if n is part of a sexy prime pair
    static func isSexyPrime(_ n: Int, primesSet: Set<Int>) -> Bool {
        return PrimeGenerator.isPrime(n) && (primesSet.contains(n + 6) || primesSet.contains(n - 6))
    }
    
    /// Checks if a number is a Cuban prime (of the form 3m² + 3m + 1)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a Cuban prime
    static func isCubanPrime(_ n: Int) -> Bool {
        if !PrimeGenerator.isPrime(n) {
            return false
        }
        
        // Check if n = 3m² + 3m + 1 for some m
        // Solving for m: 3m² + 3m + 1 - n = 0
        // Using quadratic formula: m = (-3 + sqrt(9 + 12*(n-1))) / 6
        let discriminant = 9 + 12 * (n - 1)
        let sqrtDiscriminant = sqrt(Double(discriminant))
        
        // Check if sqrtDiscriminant is an integer
        if sqrtDiscriminant.truncatingRemainder(dividingBy: 1) != 0 {
            return false
        }
        
        let m = Double(-3 + Int(sqrtDiscriminant)) / 6.0
        return m.truncatingRemainder(dividingBy: 1) == 0 && m >= 0
    }
    
    /// Checks if a number is a happy number
    /// - Parameter n: The number to check
    /// - Returns: True if n is a happy number
    static func isHappyNumber(_ n: Int) -> Bool {
        var seen = Set<Int>()
        var current = n
        
        while current != 1 && !seen.contains(current) {
            seen.insert(current)
            let digits = String(current).compactMap { Int(String($0)) }
            current = digits.reduce(0) { $0 + $1 * $1 }
        }
        
        return current == 1
    }
    
    /// Checks if a number is a happy prime (a prime that is also a happy number)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a happy prime
    static func isHappyPrime(_ n: Int) -> Bool {
        return PrimeGenerator.isPrime(n) && isHappyNumber(n)
    }
    
    /// Checks if a number is a Chen prime (p where p+2 is either prime or semiprime)
    /// - Parameter n: The number to check
    /// - Returns: True if n is a Chen prime
    static func isChenPrime(_ n: Int) -> Bool {
        if !PrimeGenerator.isPrime(n) {
            return false
        }
        
        let nPlus2 = n + 2
        
        // Check if n+2 is prime
        if PrimeGenerator.isPrime(nPlus2) {
            return true
        }
        
        // Check if n+2 is a semiprime (product of two primes)
        if nPlus2 < 4 {
            return false
        }
        
        for i in 2...Int(sqrt(Double(nPlus2))) {
            if nPlus2 % i == 0 {
                // i is a factor, check if both i and nPlus2/i are prime
                return PrimeGenerator.isPrime(i) && PrimeGenerator.isPrime(nPlus2 / i)
            }
        }
        
        return false
    }
    
    /// Checks if a number is a Wieferich prime (p where 2^(p-1) ≡ 1 (mod p²))
    /// - Parameter n: The number to check
    /// - Returns: True if n is a Wieferich prime
    static func isWieferichPrime(_ n: Int) -> Bool {
        // Only check known Wieferich primes due to computational constraints
        return PrimeGenerator.isPrime(n) && (n == 1093 || n == 3511)
    }
    
    /// Checks if a number is an isolated prime (neither n-2 nor n+2 is prime)
    /// - Parameters:
    ///   - n: The number to check
    ///   - primesSet: Set of primes to check against
    /// - Returns: True if n is an isolated prime
    static func isIsolatedPrime(_ n: Int, primesSet: Set<Int>) -> Bool {
        return PrimeGenerator.isPrime(n) &&
               !primesSet.contains(n - 2) &&
               !primesSet.contains(n + 2)
    }
    
    /// Classifies a prime number by its type
    /// - Parameters:
    ///   - n: The prime number to classify
    ///   - primesSet: Set of prime numbers to check against
    /// - Returns: The type of prime
    static func classifyPrime(_ n: Int, primesSet: Set<Int>) -> PrimeType {
        // Check for special prime types in order of computational complexity
        // and relative rarity to make interesting visualizations
        if isMersennePrime(n) {
            return .mersennePrime
        } else if isFactorialPrime(n) {
            return .factorialPrime
        } else if isWieferichPrime(n) {
            return .wieferichPrime
        } else if isFibonacciPrime(n) {
            return .fibonacciPrime
        } else if isTwinPrime(n, primesSet: primesSet) {
            return .twinPrime
        } else if isSexyPrime(n, primesSet: primesSet) {
            return .sexyPrime
        } else if isIsolatedPrime(n, primesSet: primesSet) {
            return .isolatedPrime
        } else if isSafePrime(n) {
            return .safePrime
        } else if isSophieGermainPrime(n) {
            return .sophieGermainPrime
        } else if isChenPrime(n) {
            return .chenPrime
        } else if isPalindromicPrime(n) {
            return .palindromicPrime
        } else if isCircularPrime(n) {
            return .circularPrime
        } else if isCubanPrime(n) {
            return .cubanPrime
        } else if isHappyPrime(n) {
            return .happyPrime
        } else {
            return .regularPrime
        }
    }
}
