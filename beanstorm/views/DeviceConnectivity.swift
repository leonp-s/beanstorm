import SwiftUI
import Combine
import CoreBluetooth

struct DeviceConnectivity<Content: View>: View {
    @EnvironmentObject private var beanstormBLE: BeanstormBLEModel
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
                beanstormBLE.service.displaySettingsUI()
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
                        beanstormBLE.service.startScanning()
                    }
                }
            case .scanning:
                VStack(alignment: .center) {
                    HStack {
                        Label("Scanning For Devices", systemImage: "antenna.radiowaves.left.and.right")
                        Spacer()
                        ProgressView()
                    }
                    .padding()
                    Divider()
                    List(beanstormBLE.devices) { device in
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

class MockBeanstormBLEService : BeanstormBLEService {
    let centralStateSubject: CurrentValueSubject<CBManagerState, Never>
    let conectionStateSubject: CurrentValueSubject<BeanstormConnectionState, Never>
    let devicesSubject: CurrentValueSubject<[DeviceAdvertisment], Never>

    func displaySettingsUI() { }
    func startScanning() { }
    
    init(centralState: CBManagerState, connectionState: BeanstormConnectionState) {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(centralState)
        conectionStateSubject = CurrentValueSubject<BeanstormConnectionState, Never>(connectionState)
        devicesSubject = CurrentValueSubject<[DeviceAdvertisment], Never>([DeviceAdvertisment(name: "BeastormOS", rssi: 1.0), DeviceAdvertisment(name: "mcAcorn", rssi: 0.6)])

    }
}


#Preview {
    DeviceConnectivity {
        Text("Content View")
    }
    .environmentObject(BeanstormBLEModel(
        service: MockBeanstormBLEService(
            centralState: .poweredOn,
            connectionState: .scanning
        )
    ))
}
