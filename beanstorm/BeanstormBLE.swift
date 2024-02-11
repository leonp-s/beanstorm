import CoreBluetooth
import SwiftUI

class BeanstormBLE: NSObject, ObservableObject {
    enum ConnectionState {
        case disconnected, scanning, connected
    }
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral? = nil
    var someCharacteristic: CBCharacteristic? = nil
    var scanningTimer = Timer()

    @Published var centralState: CBManagerState!
    @Published var connectionState: ConnectionState = .disconnected
    
    override init() {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralState = centralManager.state
    }
}

extension BeanstormBLE: CBCentralManagerDelegate {
    func displaySettingsUI() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralState = central.state
        print("\(central.state)")
        
        switch central.state {
        case .poweredOn:
            startScanning()
            break;
        default:
            break;
        }
    }

    func stopScanning() {
        print("Stop Scanning")
        connectionState = .disconnected
        centralManager.stopScan()
    }
    
    func startScanning() {
        print("Start Scanning")
        connectionState = .scanning
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        scanningTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.stopScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name else { return }
        print(peripheralName)

        if peripheralName == "BeanstormOS" {
            print("Device found!")
            stopScanning()
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
