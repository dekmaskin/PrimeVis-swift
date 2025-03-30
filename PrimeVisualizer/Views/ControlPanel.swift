import SwiftUI

struct ControlPanel: View {
    @ObservedObject var configController: ConfigurationController
    @ObservedObject var visualizationController: VisualizationController
    
    @State private var selectedTab = 0
    @State private var gridColumns: Int
    @State private var gridRows: Int
    @State private var dotSize: Int
    @State private var spacing: Int
    @State private var backgroundColor: Color
    
    init(configController: ConfigurationController, visualizationController: VisualizationController) {
        self.configController = configController
        self.visualizationController = visualizationController
        
        // Initialize state from current configuration
        let grid = configController.configuration.grid
        _gridColumns = State(initialValue: grid.columns)
        _gridRows = State(initialValue: grid.rows)
        _dotSize = State(initialValue: grid.dotSize)
        _spacing = State(initialValue: grid.spacing)
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
            Form {
                Section(header: Text("Grid Settings")) {
                    HStack {
                        Text("Columns:")
                        Spacer()
                        Stepper("\(gridColumns)", value: $gridColumns, in: 10...1000)
                    }
                    
                    HStack {
                        Text("Rows:")
                        Spacer()
                        Stepper("\(gridRows)", value: $gridRows, in: 10...1000)
                    }
                    
                    HStack {
                        Text("Dot Size:")
                        Spacer()
                        Stepper("\(dotSize)", value: $dotSize, in: 1...50)
                    }
                    
                    HStack {
                        Text("Spacing:")
                        Spacer()
                        Stepper("\(spacing)", value: $spacing, in: 0...20)
                    }
                    
                    ColorPicker("Background Color:", selection: $backgroundColor)
                        .padding(.vertical, 4)
                }
                
                Section(header: Text("Prime Colors")) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(PrimeType.allCases) { primeType in
                                colorPickerRow(for: primeType)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 300)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        configController.resetToDefaults()
                        
                        // Update local state
                        let grid = configController.configuration.grid
                        gridColumns = grid.columns
                        gridRows = grid.rows
                        dotSize = grid.dotSize
                        spacing = grid.spacing
                        backgroundColor = grid.backgroundColor
                    }
                    .foregroundColor(.red)
                }
            }
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
        let newGridSettings = GridSettings(
            columns: gridColumns,
            rows: gridRows,
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
