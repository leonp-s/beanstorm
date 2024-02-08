import SwiftUI
import CoreBluetooth

class BeanstormBLE: NSObject, ObservableObject {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral? = nil
    var someCharacteristic: CBCharacteristic? = nil
    var scanningTimer = Timer()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BeanstormBLE: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .unauthorized:
                print("State is unauthorized")

                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                    }
                }

            case .poweredOn:
                central.scanForPeripherals(withServices: nil, options: nil)
                print("Scanning...")
                
                scanningTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    self.stopBluetoothScanning()
                }
            default:
                print("\(central.state)")
            }
        }

        func stopBluetoothScanning() {
            centralManager.stopScan()
            print("Stopped...")
        }

        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            guard let peripheralName = peripheral.name else { return }

            print(peripheralName)

            if peripheralName == "BeanstormOS" {
                print("Device found!")
                stopBluetoothScanning()
                self.peripheral = peripheral
                centralManager.connect(peripheral, options: nil)
            }
        }

        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            peripheral.discoverServices(nil)
            peripheral.delegate = self
        }
}

extension BeanstormBLE: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        let characteristicId = CBUUID(string: "0x1234")

        for characteristic in characteristics {
            if characteristic.uuid == characteristicId {
                self.someCharacteristic = characteristic
                print("Found characteristic - \(characteristic)")
            }
        }
    }
}

struct ContentView: View {
    @StateObject var beanstormBLE = BeanstormBLE()
    
    var body: some View {
        TabView {
            BrewView()
                .tabItem {
                    Label(
                        "Brew",
                        systemImage: "play.circle"
                    )
                }
            ProfilesView()
                .tabItem {
                    Label(
                        "Profiles",
                        systemImage: "stopwatch"
                    )
                }
            SettingsView()
                .tabItem {
                    Label(
                        "Settings",
                        systemImage: "gearshape"
                    )
                }
        }
    }
}

#Preview {
    ContentView()
}
