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
        Group {
            if(beanstormBLE.isConnected) {
                content
            } else {
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
                .sheet(isPresented: $beanstormBLE.isScanning, onDismiss: {
                    beanstormBLE.service.stopScanning()
                }) {
                    NavigationView {
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
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Label("Scanning For Devices", systemImage: "antenna.radiowaves.left.and.right")
                                    .labelStyle(.titleAndIcon)
                                    .bold()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .padding()
                    .presentationDetents([.medium])
                }
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
    let isConnectedSubject: CurrentValueSubject<Bool, Never>
    let isScanningSubject: CurrentValueSubject<Bool, Never>
    let devicesSubject: CurrentValueSubject<[CBPeripheral], Never>
    var connectedPeripheral: BeanstormPeripheral? = nil

    func displaySettingsUI() { }
    func startScanning() { isScanningSubject.send(true) }
    func stopScanning() { isScanningSubject.send(false) }
    func connect(peripheral: CBPeripheral) { }
    
    init(centralState: CBManagerState, isConnected: Bool, isScanning: Bool) {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(centralState)
        isConnectedSubject = CurrentValueSubject<Bool, Never>(isConnected)
        isScanningSubject = CurrentValueSubject<Bool, Never>(isScanning)
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
            isConnected: false,
            isScanning: true
        )
    ))
}
