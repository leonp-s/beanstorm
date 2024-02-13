import SwiftUI
import Combine
import CoreBluetooth

struct DeviceConnectivityScanningRoot: ViewModifier {
    @EnvironmentObject private var beanstormBLE: BeanstormBLEModel

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $beanstormBLE.isScanning, onDismiss: {
                beanstormBLE.service.stopScanning()
            }) {
                NavigationView {
                    List(beanstormBLE.advertisingPeripherals) { advertisingPeripheral in
                        Button {
                            beanstormBLE.service.connect(advertisingPeripheral: advertisingPeripheral)
                        } label: {
                            HStack() {
                                Text(advertisingPeripheral.name)
                                    .font(.headline)
                                Spacer()
                                if(advertisingPeripheral.isConnecting) {
                                    ProgressView()
                                        .padding(.trailing)
                                }
                                Image(systemName: "wifi", variableValue: advertisingPeripheral.signalStrength)
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Label("Scanning For Devices", systemImage: "antenna.radiowaves.left.and.right")
                                .labelStyle(.titleAndIcon)
                                .bold()
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium])
            }
    }
}

struct DeviceConnectivity: View {
    @EnvironmentObject private var beanstormBLE: BeanstormBLEModel
    
    var poweredOn: some View {
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

class MockBeanstormBLEService: BeanstormBLEService {
    let centralStateSubject: CurrentValueSubject<CBManagerState, Never>
    let isConnectedSubject: CurrentValueSubject<Bool, Never>
    let isScanningSubject: CurrentValueSubject<Bool, Never>
    var advertisingPeripheralsSubject: CurrentValueSubject<[BeanstormAdvertisingPeripheral], Never>
    var connectedPeripheral: BeanstormPeripheral? = nil

    func displaySettingsUI() { }
    func startScanning() { isScanningSubject.send(true) }
    func stopScanning() { isScanningSubject.send(false) }
    func connect(advertisingPeripheral: BeanstormAdvertisingPeripheral) { }
    
    init(centralState: CBManagerState, isConnected: Bool, isScanning: Bool) {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(centralState)
        isConnectedSubject = CurrentValueSubject<Bool, Never>(isConnected)
        isScanningSubject = CurrentValueSubject<Bool, Never>(isScanning)
        advertisingPeripheralsSubject = CurrentValueSubject<[BeanstormAdvertisingPeripheral], Never>([
            BeanstormAdvertisingPeripheral(
                id: UUID(),
                name: "Beanstorm Device 1",
                signalStrength: 0.4,
                isConnecting: false
            ),
            BeanstormAdvertisingPeripheral(
                id: UUID(),
                name: "Beanstorm Device 2",
                signalStrength: 0.8,
                isConnecting: true
            )
        ])
    }
}


#Preview {
    DeviceConnectivity()
    .deviceConnectivityScanningRoot()
    .environmentObject(BeanstormBLEModel(
        service: MockBeanstormBLEService(
            centralState: .poweredOn,
            isConnected: false,
            isScanning: true
        )
    ))
}
