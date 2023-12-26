import SwiftUI

struct BoundedGuage: View {
    @Binding var current: Double
    @Binding var max: Double

    let labelHint: String
    private let minValue = 0.0
    private let gradient = Gradient(colors: [.blue, .green])
    
    var body: some View {
        Gauge(value: current, in: minValue...max) {
            Text(labelHint)
        } currentValueLabel: {
            Text("\(Int(current))")
        } minimumValueLabel: {
            Text("\(Int(minValue))")
        } maximumValueLabel: {
            Text("\(Int(max))")
        }
        .gaugeStyle(.accessoryCircular)
        .tint(gradient)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    BoundedGuage(
        current: .constant(96),
        max: .constant(96),
        labelHint: "Temperature (°C)"
    )
}
