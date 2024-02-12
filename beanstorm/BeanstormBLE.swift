import CoreBluetooth
import SwiftUI
import Combine

enum BeanstormConnectionState {
    case disconnected, scanning, connected
}

struct DeviceAdvertisment: Identifiable {
    let id = UUID()
    let name: String
    let rssi: Double
}

class BeanstormOSPeripheral: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral
    var someCharacteristic: CBCharacteristic? = nil
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
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

protocol BeanstormBLEService {
    var centralStateSubject: CurrentValueSubject<CBManagerState, Never> { get }
    var conectionStateSubject: CurrentValueSubject<BeanstormConnectionState, Never> { get }
    var devicesSubject: CurrentValueSubject<[DeviceAdvertisment], Never> { get }

    func displaySettingsUI();
    func startScanning();
}

class BeanstormBLE: NSObject, BeanstormBLEService {
    let centralStateSubject: CurrentValueSubject<CBManagerState, Never>
    let conectionStateSubject: CurrentValueSubject<BeanstormConnectionState, Never>
    let devicesSubject: CurrentValueSubject<[DeviceAdvertisment], Never>
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral? = nil
    var scanningTimer = Timer()

    override init() {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(.poweredOff)
        conectionStateSubject = CurrentValueSubject<BeanstormConnectionState, Never>(.disconnected)
        devicesSubject = CurrentValueSubject<[DeviceAdvertisment], Never>([])
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
        centralStateSubject.send(central.state)
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
        conectionStateSubject.send(.disconnected)
        centralManager.stopScan()
        devicesSubject.send([])
    }
    
    func startScanning() {
        print("Start Scanning")
        conectionStateSubject.send(.scanning)
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        scanningTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.stopScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name else { return }
//        if peripheralName == "BeanstormOS" {
            //  self.peripheral = peripheral
            //  centralManager.connect(peripheral, options: nil)

            var devices = self.devicesSubject.value
            devices.append(DeviceAdvertisment(name: peripheralName, rssi: Double(truncating: RSSI)))
            devicesSubject.send(devices)
//        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

    }
}

class BeanstormBLEModel: ObservableObject {
    let service: BeanstormBLEService
    
    private var subscriptions = Set<AnyCancellable>()
    @Published var centralState: CBManagerState!
    @Published var connectionState: BeanstormConnectionState = .disconnected
    @Published var devices: [DeviceAdvertisment] = []
    
    init(service: BeanstormBLEService = BeanstormBLE()) {
        self.service = service
        
        service.centralStateSubject
            .sink { centralState in self.centralState = centralState }
            .store(in: &subscriptions)
        
        service.conectionStateSubject
            .sink { connectionState in self.connectionState = connectionState }
            .store(in: &subscriptions)
        
        service.devicesSubject
            .sink { devices in self.devices = devices }
            .store(in: &subscriptions)
    }
}
