import SwiftUI

extension View {
    func deviceConnectivityScanningRoot() -> some View {
        modifier(DeviceConnectivityScanningRoot())
    }
    
    func profileGraphChart(xAxisMax: Binding<Double>, controlType: Binding<ControlType>) -> some View {
        modifier(
            ProfileGraphChartModifier(
                xAxisMax: xAxisMax,
                controlType: controlType
            )
        )
    }
}
