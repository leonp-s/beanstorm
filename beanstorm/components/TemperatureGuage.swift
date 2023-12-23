import SwiftUI

struct TemperatureGuage: View {
    @Binding var currentTemperature: Double
    @Binding var maxTemperature: Double

    private let minValue = 0.0
    
    private let gradient = Gradient(colors: [.blue, .green])
    
    var body: some View {
        Gauge(value: currentTemperature, in: minValue...maxTemperature) {
            Text("Temperature (°C)")
        } currentValueLabel: {
            Text("\(Int(currentTemperature))°")
        } minimumValueLabel: {
            Text("\(Int(minValue))")
        } maximumValueLabel: {
            Text("\(Int(maxTemperature))")
        }
        .gaugeStyle(.accessoryCircular)
        .tint(gradient)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TemperatureGuage(
        currentTemperature: .constant(96),
        maxTemperature: .constant(96)
    )
}
