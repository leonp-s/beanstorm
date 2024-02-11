import SwiftUI

struct DeviceAdvertisment: Identifiable {
    let id = UUID()
    let name: String
    let rssi: Double
}

struct DeviceConnectivity<Content: View>: View {
    @EnvironmentObject private var beanstormBLE: BeanstormBLE
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var grantPemission: some View {
        ContentUnavailableView {
            Label("Bluetooth Permissions", systemImage: "tropicalstorm")
        } description: {
            Text ("BLE permissions are required to communicate with devices running BeanstormOS. You can open settings manually to grant bluetooth permissions or use the shortcut below.")
                .multilineTextAlignment(.center)
            Divider()
            Button("Open App Settings", systemImage: "gear") {
                beanstormBLE.displaySettingsUI()
            }
        }
    }
    
    var poweredOn: some View {
        HStack {
            switch(beanstormBLE.connectionState) {
            case .disconnected:
                ContentUnavailableView {
                    Label("No Device Connected", systemImage: "tropicalstorm")
                } description: {
                    Text ("Get started by scanning for local devices running BeanstormOS.")
                        .multilineTextAlignment(.center)
                    Divider()
                    Button("Scan For Devices", systemImage: "antenna.radiowaves.left.and.right") {
                        beanstormBLE.startScanning()
                    }
                }
            case .scanning:
                VStack {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                        Text("Scanning For Devices")
                        Spacer()
                        ProgressView()
                    }
                    
                    Divider()
                    
                    List([DeviceAdvertisment(name: "BeastormOS", rssi: 1.0), DeviceAdvertisment(name: "mcAcorn", rssi: 0.6)]) { device in
                        HStack() {
                            Text(device.name)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "wifi", variableValue: device.rssi)
                        }
                    }
                    .refreshable {
                        
                    }
                }
                .padding()

            case .connected:
                content
            }
        }
    }
    
    var loading: some View {
        ContentUnavailableView {
            Label("BeanstormOS", systemImage: "tropicalstorm")
                .padding()
            ProgressView()
        }
    }
    
    var body: some View {
        switch(beanstormBLE.centralState) {
        case .unauthorized:
            grantPemission
                .padding()
        case .poweredOn:
            poweredOn
        default:
            loading
        }
    }
}

#Preview {
    DeviceConnectivity {
        Text("Content View")
    }
    .environmentObject(BeanstormBLE())
}
