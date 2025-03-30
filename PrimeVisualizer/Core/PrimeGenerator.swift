//
//  PrimeGenerator.swift
//  PrimeVis
//
//  Created by Johan Karlsson on 2025-03-29.
//

import Foundation

class PrimeGenerator {
    /// Checks if a number is prime
    /// - Parameter n: The number to check
    /// - Returns: True if n is prime, false otherwise
    static func isPrime(_ n: Int) -> Bool {
        if n <= 1 {
            return false
        }
        if n <= 3 {
            return true
        }
        if n % 2 == 0 || n % 3 == 0 {
            return false
        }
        
        // Check divisibility by numbers of form 6k ± 1
        var i = 5
        while i * i <= n {
            if n % i == 0 || n % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        
        return true
    }
    
    /// Generates primes up to a limit using the Sieve of Eratosthenes
    /// - Parameter limit: Upper bound for prime generation
    /// - Returns: Array of prime numbers up to the limit
    static func generatePrimes(upTo limit: Int) -> [Int] {
        if limit < 2 {
            return []
        }
        
        // Initialize sieve
        var sieve = [Bool](repeating: true, count: limit + 1)
        sieve[0] = false
        sieve[1] = false
        
        // Mark multiples of each prime as non-prime
        for i in 2...Int(sqrt(Double(limit))) {
            if sieve[i] {
                for j in stride(from: i * i, through: limit, by: i) {
                    sieve[j] = false
                }
            }
        }
        
        // Collect the primes
        var primes = [Int]()
        for i in 2...limit {
            if sieve[i] {
                primes.append(i)
            }
        }
        
        return primes
    }
    
    /// Generates a set of primes up to a limit
    /// - Parameter limit: Upper bound for prime generation
    /// - Returns: Set of prime numbers up to the limit
    static func generatePrimesSet(upTo limit: Int) -> Set<Int> {
        return Set(generatePrimes(upTo: limit))
    }
    
    /// Estimates the number of primes less than or equal to x using Prime Number Theorem
    /// - Parameter x: The upper bound
    /// - Returns: Estimated number of primes
    static func primeCountEstimate(_ x: Int) -> Int {
        if x < 2 {
            return 0
        }
        return Int(Double(x) / log(Double(x)))
    }
}
