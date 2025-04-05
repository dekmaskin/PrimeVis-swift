import SwiftUI

struct ControlPanel: View {
    @ObservedObject var configController: ConfigurationController
    @ObservedObject var visualizationController: VisualizationController
    
    @State private var selectedTab = 0
    @State private var gridColumns: String
    @State private var gridRows: String
    @State private var dotSize: String
    @State private var spacing: String
    @State private var backgroundColor: Color
    @State private var exportProgress: Bool = false
    
    init(configController: ConfigurationController, visualizationController: VisualizationController) {
        self.configController = configController
        self.visualizationController = visualizationController
        
        // Initialize state from current configuration
        let grid = configController.configuration.grid
        _gridColumns = State(initialValue: String(grid.columns))
        _gridRows = State(initialValue: String(grid.rows))
        _dotSize = State(initialValue: String(grid.dotSize))
        _spacing = State(initialValue: String(grid.spacing))
        _backgroundColor = State(initialValue: grid.backgroundColor)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs for settings and statistics
            Picker("", selection: $selectedTab) {
                Text("Settings").tag(0)
                Text("Statistics").tag(1)
                if visualizationController.selectedNumber != nil {
                    Text("Details").tag(2)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: visualizationController.selectedNumber) { oldValue, newValue in
                // Switch to details tab when a number is selected
                if newValue != nil && oldValue == nil {
                    selectedTab = 2
                }
                // Switch back to previous tab if number selection is cleared
                if newValue == nil && oldValue != nil && selectedTab == 2 {
                    selectedTab = 0
                }
            }
            
            if selectedTab == 0 {
                settingsView
            } else if selectedTab == 1 {
                statisticsView
            } else if selectedTab == 2, let selectedNumber = visualizationController.selectedNumber {
                numberDetailsView(selectedNumber)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 8) {
                // Generate button
                Button(action: {
                    // Update configuration
                    updateConfiguration()
                    
                    // Generate visualization
                    visualizationController.generateVisualization()
                }) {
                    if visualizationController.isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                        Text("Generating...")
                            .padding(.leading, 4)
                    } else {
                        Text("Generate Visualization")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(visualizationController.isGenerating)
                .padding(.horizontal)
                
                // Export button for interactive mode
                if visualizationController.visualizationMode == .interactive {
                    Button(action: {
                        exportProgress = true
                        visualizationController.generateImageFromInteractive { success in
                            exportProgress = false
                        }
                    }) {
                        if exportProgress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                            Text("Exporting...")
                                .padding(.leading, 4)
                        } else {
                            Text("Export as Image")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(visualizationController.isGenerating || visualizationController.primePoints.isEmpty || exportProgress)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - Views
    
    // Settings view
    private var settingsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Grid settings
                GroupBox(label: Text("Grid Settings").font(.headline)) {
                    VStack(spacing: 12) {
                        numericField(label: "Columns:", value: $gridColumns, range: 1...100000)
                        numericField(label: "Rows:", value: $gridRows, range: 1...100000)
                        numericField(label: "Dot Size:", value: $dotSize, range: 1...50)
                        numericField(label: "Spacing:", value: $spacing, range: 0...20)
                        ColorPicker("Background Color:", selection: $backgroundColor)
                            .padding(.vertical, 4)
                    }
                    .padding(8)
                }
                
                // Prime colors
                GroupBox(label: Text("Prime Colors").font(.headline)) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(PrimeType.allCases) { primeType in
                                colorPickerRow(for: primeType)
                            }
                        }
                        .padding(8)
                    }
                    .frame(maxHeight: 300)
                }
                
                // Mode description
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Mode:")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        Text(visualizationController.visualizationMode == .interactive ?
                             "Interactive: Click on numbers to view details" :
                             "Image: View the visualization as a static image")
                            .font(.caption)
                        
                        Text("Switch modes using the toolbar button above")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button("Reset to Defaults") {
                    configController.resetToDefaults()
                    
                    // Update local state
                    let grid = configController.configuration.grid
                    gridColumns = String(grid.columns)
                    gridRows = String(grid.rows)
                    dotSize = String(grid.dotSize)
                    spacing = String(grid.spacing)
                    backgroundColor = grid.backgroundColor
                }
                .foregroundColor(.red)
                .padding(.top, 8)
            }
            .padding()
        }
    }
    
    // MARK: - Statistics view
    private var statisticsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let stats = visualizationController.statistics {
                    Group {
                        StatRow(label: "Grid Size:", value: "\(stats.gridColumns)×\(stats.gridRows)")
                        StatRow(label: "Image Size:", value: "\(stats.width)×\(stats.height) pixels")
                        StatRow(label: "Total Positions:", value: "\(stats.totalPositions)")
                        StatRow(label: "Total Primes:", value: "\(stats.totalPrimes)")
                        StatRow(label: "Prime Density:", value: stats.formattedDensity)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    Text("Prime Types:")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    // Sort prime types by count, descending
                    let sortedTypes = stats.primeTypes.sorted { $0.value > $1.value }
                    
                    ForEach(sortedTypes, id: \.key) { primeType, count in
                        let percentage = Double(count) / Double(stats.totalPrimes) * 100
                        
                        HStack {
                            Rectangle()
                                .fill(configController.configuration.colors[primeType.rawValue] ?? .black)
                                .frame(width: 12, height: 12)
                            
                            Text(primeType.displayName)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(count) (\(String(format: "%.1f%%", percentage)))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                } else {
                    Text("No visualization generated yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
            }
            .padding()
        }
    }
    
    // MARK: - Number Details View
    private func numberDetailsView(_ number: Int) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Basic number info
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Number:")
                                .fontWeight(.bold)
                            
                            Text("\(number)")
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Status:")
                                .fontWeight(.bold)
                            
                            let isPrime = PrimeGenerator.isPrime(number)
                            
                            Text(isPrime ? "Prime" : "Not Prime")
                                .foregroundColor(isPrime ? .green : .red)
                                .fontWeight(.medium)
                        }
                        
                        if !PrimeGenerator.isPrime(number) {
                            Divider()
                            
                            Text("Factors:")
                                .fontWeight(.bold)
                            
                            Text(factorsString(for: number))
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Prime type info (if applicable)
                if let primeType = visualizationController.getPrimeTypeForNumber(number) {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Prime Type:")
                                    .fontWeight(.bold)
                                
                                Text(primeType.displayName)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Color:")
                                    .fontWeight(.bold)
                                
                                Rectangle()
                                    .fill(configController.configuration.colors[primeType.rawValue] ?? .black)
                                    .frame(width: 20, height: 20)
                                    .cornerRadius(4)
                            }
                            
                            Divider()
                            
                            Text("Description:")
                                .fontWeight(.bold)
                            
                            Text(primeType.description)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Additional properties based on prime type
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Special Properties:")
                                .fontWeight(.bold)
                            
                            switch primeType {
                            case .twinPrime:
                                Text("Twin pair: \(number) and \(number > 2 ? number - 2 : number + 2)")
                            case .sophieGermainPrime:
                                Text("2*\(number)+1 = \(2*number+1) is also prime")
                            case .safePrime:
                                Text("(\(number)-1)/2 = \((number-1)/2) is also prime")
                            case .happyPrime:
                                Text("Repeated sum of squared digits reaches 1")
                            case .palindromicPrime:
                                Text("\(number) reads the same forwards and backwards")
                            case .circularPrime:
                                Text("All digit rotations of \(number) are prime")
                            default:
                                Text("See description above")
                            }
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Number theory facts
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number Facts:")
                            .fontWeight(.bold)
                        
                        if PrimeGenerator.isPrime(number) {
                            Text("Position in sequence of primes: calculation requires full prime database")
                                .font(.caption)
                        }
                        
                        Text("Binary: \(String(number, radix: 2))")
                        Text("Hexadecimal: \(String(number, radix: 16).uppercased())")
                        
                        if number > 0 {
                            Text("Square: \(number * number)")
                            if number <= 20 { // Avoid factorial overflow
                                Text("Factorial: \(factorial(number))")
                            }
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Views
    
    private func numericField(label: String, value: Binding<String>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
            
            TextField("", text: value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: .infinity)
                .onChange(of: value.wrappedValue) { oldValue, newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        value.wrappedValue = filtered
                    }
                    
                    if let num = Int(filtered), !range.contains(num) {
                        if num < range.lowerBound {
                            value.wrappedValue = String(range.lowerBound)
                        } else if num > range.upperBound {
                            value.wrappedValue = String(range.upperBound)
                        }
                    }
                }
            
            Stepper("", onIncrement: {
                if let num = Int(value.wrappedValue), num < range.upperBound {
                    value.wrappedValue = String(num + 1)
                } else {
                    value.wrappedValue = String(range.lowerBound)
                }
            }, onDecrement: {
                if let num = Int(value.wrappedValue), num > range.lowerBound {
                    value.wrappedValue = String(num - 1)
                } else {
                    value.wrappedValue = String(range.upperBound)
                }
            })
            .labelsHidden()
        }
    }
    
    private func colorPickerRow(for primeType: PrimeType) -> some View {
        HStack {
            Text(primeType.displayName)
                .lineLimit(1)
            
            Spacer()
            
            ColorPicker("", selection: Binding(
                get: { configController.configuration.colors[primeType.rawValue] ?? .black },
                set: { configController.updateColor($0, for: primeType) }
            ))
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateConfiguration() {
        let columns = Int(gridColumns) ?? configController.configuration.grid.columns
        let rows = Int(gridRows) ?? configController.configuration.grid.rows
        let dotSize = Int(dotSize) ?? configController.configuration.grid.dotSize
        let spacing = Int(spacing) ?? configController.configuration.grid.spacing
        
        let newGridSettings = GridSettings(
            columns: columns,
            rows: rows,
            dotSize: dotSize,
            spacing: spacing,
            backgroundColor: backgroundColor
        )
        
        configController.updateGridSettings(newGridSettings)
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
    
    private func factorial(_ n: Int) -> Int {
        if n <= 1 {
            return 1
        }
        return n * factorial(n - 1)
    }
}

// MARK: - StatRow View
struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
