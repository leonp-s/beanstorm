import SwiftUI

struct BoundedGuage: View {
    @Binding var current: Double
    @Binding var max: Double

    let labelHint: String
    private let minValue = 0.0
    private let gradient = Gradient(colors: [.blue, .green])
    
    var body: some View {
        VStack {
            Gauge(value: current, in: minValue...max) {
                Text(labelHint)
            } currentValueLabel: {
                Text(String(format: "%.1f", current))
                    .font(.headline)
                    .animation(.none)
            } minimumValueLabel: {
                Text("\(Int(minValue))")
            } maximumValueLabel: {
                Text("\(Int(max))")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(gradient)
            .animation(.spring, value: current)
        }
    }
}

struct BoundedGuagePreview: View {
    @State var value: Double = 0.1
    
    var body: some View {
        VStack {
            BoundedGuage(
                current: $value,
                max: .constant(96),
                labelHint: "Temperature (°C)"
            )
            Slider(value: $value, in: 0...100)
        }
        .padding()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    BoundedGuagePreview()
}
