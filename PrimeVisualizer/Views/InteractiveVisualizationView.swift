import SwiftUI
import AppKit

struct InteractiveVisualizationView: View {
    @ObservedObject var controller: VisualizationController
    @State private var selectedNumber: Int? = nil
    @State private var hoveredNumber: Int? = nil
    @State private var zoomLevel: Double = 1.0
    
    // Store the prime numbers in a set for fast lookups
    @State private var primesSet: Set<Int> = []
    
    let columns: Int
    let rows: Int
    let dotSize: Int
    let spacing: Int
    let colors: [String: Color]
    let backgroundColor: Color
    
    private var effectiveDotSize: CGFloat {
        CGFloat(dotSize) * zoomLevel
    }
    
    private var effectiveSpacing: CGFloat {
        CGFloat(spacing) * zoomLevel
    }
    
    private var gridWidth: CGFloat {
        CGFloat(columns) * (effectiveDotSize + effectiveSpacing) - effectiveSpacing
    }
    
    private var gridHeight: CGFloat {
        CGFloat(rows) * (effectiveDotSize + effectiveSpacing) - effectiveSpacing
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                ZStack {
                    // Background grid
                    Rectangle()
                        .fill(backgroundColor)
                        .frame(width: gridWidth, height: gridHeight)
                    
                    // Invisible grid for hit testing
                    hitTestGrid
                    
                    // Only draw visible prime cells (or selected/hovered cells)
                    primeCellsLayer
                }
                .frame(width: gridWidth, height: gridHeight)
            }
            
            // Overlay controls (unchanged)
            VStack {
                HStack {
                    Spacer()
                    
                    // Zoom controls
                    HStack(spacing: 4) {
                        Button(action: {
                            zoomLevel = max(zoomLevel * 0.8, 0.1)
                        }) {
                            Image(systemName: "minus.magnifyingglass")
                                .padding(4)
                        }
                        .buttonStyle(.borderless)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                        
                        Button(action: {
                            zoomLevel = 1.0
                        }) {
                            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                .padding(4)
                        }
                        .buttonStyle(.borderless)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                        
                        Button(action: {
                            zoomLevel = min(zoomLevel * 1.25, 5.0)
                        }) {
                            Image(systemName: "plus.magnifyingglass")
                                .padding(4)
                        }
                        .buttonStyle(.borderless)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                        
                        Text("\(Int(zoomLevel * 100))%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .cornerRadius(6)
                    }
                    .padding(8)
                }
                
                Spacer()
                
                // Selected number details
                if let selectedNum = selectedNumber {
                    VStack(alignment: .leading, spacing: 8) {
                        // Details panel (unchanged)
                        HStack {
                            Text("Number: \(selectedNum)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedNumber = nil
                                controller.selectedNumber = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        if isPrime(selectedNum), let primeType = getPrimeType(selectedNum) {
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
                        } else {
                            Text("Not a prime number")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding()
                }
            }
        }
        .onAppear {
            // Initialize the view
            selectedNumber = controller.selectedNumber
            zoomLevel = controller.zoomLevel
            
            // Generate primes set
            initializePrimesSet()
            
            // Set up scroll-wheel zoom monitoring
            setupScrollWheelMonitoring()
        }
        .onChange(of: selectedNumber) { oldValue, newValue in
            controller.selectedNumber = newValue
        }
        .onChange(of: controller.selectedNumber) { oldValue, newValue in
            selectedNumber = newValue
        }
        .onChange(of: zoomLevel) { oldValue, newValue in
            controller.zoomLevel = newValue
        }
        .onChange(of: controller.zoomLevel) { oldValue, newValue in
            zoomLevel = newValue
        }
    }
    
    // MARK: - View Layers
    
    private var primeCellsLayer: some View {
        ZStack {
            // Draw each prime number
            ForEach(Array(primesSet), id: \.self) { number in
                cellView(for: number)
            }
            
            // Always draw selected and hovered numbers
            if let selected = selectedNumber, !primesSet.contains(selected) {
                cellView(for: selected)
            }
            
            if let hovered = hoveredNumber, !primesSet.contains(hovered) {
                cellView(for: hovered)
            }
        }
    }
    
    private var hitTestGrid: some View {
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Convert tap/drag location to grid position
                            let position = pointToGridPosition(value.location, in: geometry.size)
                            handleHitTest(at: position)
                        }
                        .onEnded { _ in
                            // Reset hover state when touch/drag ends (for touch devices)
                            hoveredNumber = nil
                        }
                )
                .onHover { isHovering in
                    if !isHovering {
                        hoveredNumber = nil
                    }
                }
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(let location):
                // Calculate hovered position
                let position = pointToGridPosition(location, in: CGSize(width: gridWidth, height: gridHeight))
                hoveredNumber = position
            case .ended:
                hoveredNumber = nil
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func cellView(for number: Int) -> some View {
        let x = (number - 1) % columns
        let y = (number - 1) / columns
        
        let posX = CGFloat(x) * (effectiveDotSize + effectiveSpacing)
        let posY = CGFloat(y) * (effectiveDotSize + effectiveSpacing)
        
        let isSelected = selectedNumber == number
        let isHovered = hoveredNumber == number
        let isPrimeNumber = isPrime(number)
        
        return ZStack {
            // Cell content
            if isPrimeNumber {
                let primeType = getPrimeType(number)
                Circle()
                    .fill(colors[primeType?.rawValue ?? "regular_prime"] ?? .black)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: isSelected ? 2 : 0)
                    )
                    .overlay(
                        Circle()
                            .stroke(isHovered ? Color.yellow : Color.clear, lineWidth: isHovered ? 1 : 0)
                    )
            } else if isSelected || isHovered {
                Circle()
                    .stroke(isSelected ? Color.white : Color.gray, lineWidth: 1)
            }
            
            // Number text
            if effectiveDotSize >= 16 || isSelected || isHovered {
                Text("\(number)")
                    .font(.system(size: min(effectiveDotSize * 0.6, 12)))
                    .foregroundColor(getTextColor(number, isSelected: isSelected))
            }
        }
        .frame(width: effectiveDotSize, height: effectiveDotSize)
        .position(x: posX + effectiveDotSize/2, y: posY + effectiveDotSize/2)
    }
    
    // MARK: - Interaction Helpers
    
    private func pointToGridPosition(_ point: CGPoint, in size: CGSize) -> Int? {
        // Convert position to grid coordinates
        let cellSize = effectiveDotSize + effectiveSpacing
        let x = Int(point.x / cellSize)
        let y = Int(point.y / cellSize)
        
        // Check if within valid range
        if x >= 0 && x < columns && y >= 0 && y < rows {
            // Calculate position using the same formula as in cellView
            let position = y * columns + x + 1
            if position >= 1 && position <= columns * rows {
                return position
            }
        }
        return nil
    }
    
    private func handleHitTest(at position: Int?) {
        guard let position = position else { return }
        
        // Update hover state
        hoveredNumber = position
        
        // Check for tap/click
        if let oldSelected = selectedNumber, oldSelected == position {
            selectedNumber = nil
            controller.selectedNumber = nil
        } else {
            selectedNumber = position
            controller.selectedNumber = position
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializePrimesSet() {
        // Generate all prime numbers from 1 to columns*rows
        DispatchQueue.global(qos: .userInitiated).async {
            let newPrimes = Set(PrimeGenerator.generatePrimes(upTo: columns * rows))
            DispatchQueue.main.async {
                self.primesSet = newPrimes
            }
        }
    }
    
    private func isPrime(_ n: Int) -> Bool {
        // Use cached set for better performance
        return primesSet.contains(n)
    }
    
    private func getPrimeType(_ n: Int) -> PrimeType? {
        if !isPrime(n) {
            return nil
        }
        return PrimeClassifier.classifyPrime(n, primesSet: primesSet)
    }
    
    private func getTextColor(_ number: Int, isSelected: Bool) -> Color {
        if !isPrime(number) {
            return isSelected ? .white : .gray
        }
        
        if let type = getPrimeType(number), let color = colors[type.rawValue] {
            let components = color.cgColor?.components ?? [0, 0, 0, 1]
            let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
            
            return brightness > 0.5 ? .black : .white
        }
        
        return .white
    }
    
    private func setupScrollWheelMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            // If command/control key is pressed, use for zoom
            if event.modifierFlags.contains(.command) || event.modifierFlags.contains(.control) {
                let zoomFactor = event.deltaY > 0 ? 1.1 : 0.9
                DispatchQueue.main.async {
                    let newZoom = self.zoomLevel * zoomFactor
                    self.zoomLevel = min(max(newZoom, 0.1), 5.0)
                }
                // Consume the event so it doesn't also trigger scroll
                return nil
            }
            // Let other scroll events pass through
            return event
        }
    }
}

// MARK: - Continuous Hover Support
extension View {
    func onContinuousHover(perform action: @escaping (HoverPhase) -> Void) -> some View {
        self.onHover { isHovering in
            if !isHovering {
                action(.ended)
            }
        }
        .background(
            GeometryReader { geometry in
                ContinuousHoverListener(geometry: geometry, perform: action)
            }
        )
    }
}

enum HoverPhase {
    case active(CGPoint)
    case ended
}

struct ContinuousHoverListener: NSViewRepresentable {
    let geometry: GeometryProxy
    let perform: (HoverPhase) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = HoverListenerView()
        view.perform = perform
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? HoverListenerView {
            view.perform = perform
        }
    }
    
    class HoverListenerView: NSView {
        var perform: ((HoverPhase) -> Void)?
        
        override func updateTrackingAreas() {
            for area in trackingAreas {
                removeTrackingArea(area)
            }
            
            let options: NSTrackingArea.Options = [
                .mouseEnteredAndExited,
                .mouseMoved,
                .activeInKeyWindow
            ]
            
            let trackingArea = NSTrackingArea(
                rect: bounds,
                options: options,
                owner: self,
                userInfo: nil
            )
            
            addTrackingArea(trackingArea)
        }
        
        override func mouseMoved(with event: NSEvent) {
            let point = convert(event.locationInWindow, from: nil)
            // Convert point from NSView's flipped coordinate system to SwiftUI's
            // In NSView, origin is bottom-left, in SwiftUI it's top-left
            let adjustedPoint = CGPoint(x: point.x, y: bounds.height - point.y)
            perform?(.active(adjustedPoint))
        }
        
        override func mouseExited(with event: NSEvent) {
            perform?(.ended)
        }
    }
}
