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
                .font(.headline)
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(gradient)
    }
}


struct UnboundedGuagePreview: View {
    @State var value: Double = 4.8
    
    var body: some View {
        VStack {
            UnboundedGuage(
                current: $value,
                max: .constant(11.0),
                labelHint: "Pressure Guage"
            )
            Slider(value: $value, in: 0...11)
        }
        .padding()
    }
}

#Preview {
    UnboundedGuagePreview()
}
