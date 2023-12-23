import SwiftUI

struct QuickMonitorView: View {
    private var brewGuage: some View {
        GroupBox(
            label: Text("Brew (°C)")
                .font(.footnote)
        ) {
            HStack {
                TemperatureGuage(
                    currentTemperature: .constant(96),
                    maxTemperature: .constant(96)
                )
                Image(systemName: "thermometer")
            }
        }
    }
    
    private var steamGuage: some View {
        GroupBox(
            label: Text("Steam (°C)")
                .font(.footnote)
        ) {
            HStack {
                TemperatureGuage(
                    currentTemperature: .constant(102),
                    maxTemperature: .constant(104)
                )
                Image(systemName: "wind")
            }
        }
    }
    
    private var pressureGuage: some View {
        GroupBox(
            label: Text("Pressure (MPa)")
                .font(.footnote)
        ) {
            HStack {
                PressureGuage(
                    currentPressure: .constant(6.8),
                    maxPressure: .constant(11.0)
                )
                Image(systemName: "barometer")
            }
        }
    }
    
    var body: some View {
        HStack {
            brewGuage
            steamGuage
            pressureGuage
        }
    }
}

#Preview {
    QuickMonitorView()
}
