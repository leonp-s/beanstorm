import SwiftUI

struct QuickMonitorView: View {
    private var brewGuage: some View {
        GroupBox(
            label: Text("Brew (°C)")
                .font(.footnote)
        ) {
            HStack {
                BoundedGuage(
                    current: .constant(96),
                    max: .constant(96),
                    labelHint: "Brew (°C)"
                )
                Image(systemName: "thermometer")
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    private var flowGuage: some View {
        GroupBox(
            label: Text("Flow (ml/s)")
                .font(.footnote)
        ) {
            HStack(alignment: .center) {
                UnboundedGuage(
                    current: .constant(2.4),
                    max: .constant(11.0),
                    labelHint: "Flow (ml/s)"
                )
                Image(systemName: "water.waves")
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    private var pressureGuage: some View {
        GroupBox(
            label: Text("Pressure (MPa)")
                .font(.footnote)
        ) {
            HStack(alignment: .center) {
                UnboundedGuage(
                    current: .constant(6.8),
                    max: .constant(11.0),
                    labelHint: "Pressure (MPa)"
                )
                Image(systemName: "barometer")
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    var body: some View {
        HStack {
            brewGuage
            flowGuage
            pressureGuage
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    QuickMonitorView()
        .padding()
}
