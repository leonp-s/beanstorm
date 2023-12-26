import SwiftUI

struct QuickMonitorView: View {
    private var brewGuage: some View {
        Group {
            BoundedGuage(
                current: .constant(96),
                max: .constant(96),
                labelHint: "Brew (°C)"
            )
            Image(systemName: "thermometer")
        }
    }
    
    private var flowGuage: some View {
        Group {
            UnboundedGuage(
                current: .constant(2.4),
                max: .constant(11.0),
                labelHint: "Flow (ml/s)"
            )
            Image(systemName: "water.waves")
        }
    }
    
    private var pressureGuage: some View {
        Group {
            UnboundedGuage(
                current: .constant(6.8),
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
    QuickMonitorView()
        .padding()
}
