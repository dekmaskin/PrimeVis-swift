# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- Build: `xcodebuild -project PrimeVis.xcodeproj -scheme PrimeVis build`
- Run: `open PrimeVis.xcodeproj`
- Test: `xcodebuild -project PrimeVis.xcodeproj -scheme PrimeVis test`
- Single test: `xcodebuild -project PrimeVis.xcodeproj -scheme PrimeVis -only-testing:PrimeVisualizerTests/TestClassName/testMethodName test`

## Code Style Guidelines
- Imports: Group imports (Swift/SwiftUI first, followed by Foundation, then others)
- Documentation: Use `///` for method/property documentation with parameter descriptions
- Naming: camelCase for properties/methods, PascalCase for types, lowercase_with_underscores for coding keys
- Types: Use explicit types for properties, avoid force unwrapping when possible
- Error handling: Use `try?` for non-critical operations, proper `do/catch` for critical paths
- Extensions: Create extensions for additional functionality on existing types
- Organization: Group code by functionality (Core, Models, Views, Controllers)
- SwiftUI: Use declarative syntax, prefer composition of smaller view components