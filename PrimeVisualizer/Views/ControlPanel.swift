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
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                settingsView
            } else {
                statisticsView
            }
            
            Spacer()
            
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
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(visualizationController.isGenerating)
            .padding()
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
