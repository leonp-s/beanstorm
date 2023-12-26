import SwiftUI

struct UnboundedGuage: View {
    @Binding var current: Double
    @Binding var max: Double

    let labelHint: String
    private let minPressure: Double = 0.0
    private let gradient = Gradient(colors: [.red, .green, .blue])

    var body: some View {
        Gauge(value: current, in: minPressure...max) {
            Text(labelHint)
        } currentValueLabel: {
            Text(String(format: "%.1f", current))
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(gradient)
    }
}

#Preview {
    UnboundedGuage(
        current: .constant(9.2),
        max: .constant(11.0),
        labelHint: "Pressure Guage"
    )
}
