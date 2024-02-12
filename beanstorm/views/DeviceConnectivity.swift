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
                beanstormBLE.displayAppSettings()
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
                VStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                        .padding()
                    HStack {
                        Text("Scanning For Devices")
                            .font(.title2)
                            .bold()
                        Spacer()
                        ProgressView()
                    }
                    Divider()
                    List(beanstormBLE.devices) { device in
                        Button {
                            beanstormBLE.service.connect(peripheral: device)
                        } label: {
                            HStack() {
                                Text(device.name ?? "Unknown Device")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "wifi", variableValue: 1.0)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowSeparator(.visible)
                    .frame(
                        width: .infinity,
                        height: 80
                    )
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
    
    var turnBluetoothOn: some View {
        ContentUnavailableView {
            Label("Bluetooth Disabled", systemImage: "tropicalstorm")
        } description: {
            Text ("BLE is required to communicate with devices running BeanstormOS. You can open settings manually to enable bluetooth or use the shortcut below.")
                .multilineTextAlignment(.center)
            Divider()
            Button("Open Settings", systemImage: "gear") {
                beanstormBLE.displaySystemSettings()
            }
        }
    }
    
    var body: some View {
        switch(beanstormBLE.centralState) {
        case .poweredOff:
            turnBluetoothOn
        case .unauthorized:
            grantPemission
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
    let devicesSubject: CurrentValueSubject<[CBPeripheral], Never>
    var connectedPeripheral: BeanstormPeripheral? = nil

    func displaySettingsUI() { }
    func startScanning() { }
    func connect(peripheral: CBPeripheral) { }
    
    init(centralState: CBManagerState, connectionState: BeanstormConnectionState) {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(centralState)
        conectionStateSubject = CurrentValueSubject<BeanstormConnectionState, Never>(connectionState)
        devicesSubject = CurrentValueSubject<[CBPeripheral], Never>([])

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
