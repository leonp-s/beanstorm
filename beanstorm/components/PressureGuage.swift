import SwiftUI

struct PressureGuage: View {
    @Binding var currentPressure: Double
    @Binding var maxPressure: Double
    
    private let minPressure: Double = 0.0
    private let gradient = Gradient(colors: [.red, .green, .blue])

    var body: some View {
        Gauge(value: currentPressure, in: minPressure...maxPressure) {
            Text("Pressure Guage")
        } currentValueLabel: {
            Text(String(format: "%.1f", currentPressure))
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(gradient)
    }
}

#Preview {
    PressureGuage(
        currentPressure: .constant(9.2),
        maxPressure: .constant(11.0)
    )
}
