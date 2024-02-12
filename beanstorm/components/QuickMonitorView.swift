import SwiftUI

struct QuickMonitorView: View {
    @Binding var pressue: Double
    @Binding var temperature: Double
    @Binding var flow: Double

    
    private var brewGuage: some View {
        Group {
            BoundedGuage(
                current: $temperature,
                max: .constant(96),
                labelHint: "Brew (°C)"
            )
            Image(systemName: "thermometer")
        }
    }
    
    private var flowGuage: some View {
        Group {
            UnboundedGuage(
                current: $flow,
                max: .constant(11.0),
                labelHint: "Flow (ml/s)"
            )
            Image(systemName: "water.waves")
        }
    }
    
    private var pressureGuage: some View {
        Group {
            UnboundedGuage(
                current: $pressue,
                max: .constant(11.0),
                labelHint: "Pressure (MPa)"
            )
            Image(systemName: "barometer")
        }
    }
    
    var body: some View {
        GroupBox {
            HStack {
                flowGuage
                Spacer()
                Divider()
                Spacer()
                brewGuage
                Spacer()
                Divider()
                Spacer()
                pressureGuage
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    QuickMonitorView(pressue: .constant(2.6), temperature: .constant(96.0), flow: .constant(5.0))
        .padding()
}
