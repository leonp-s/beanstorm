import CoreBluetooth
import Combine

struct BeanstormAdvertisingPeripheral: Identifiable {
    let id: UUID
    let name: String
    let signalStrength: Double
    let isConnecting: Bool
}

protocol BeanstormBLEService {
    var centralStateSubject: CurrentValueSubject<CBManagerState, Never> { get }
    var isConnectedSubject: CurrentValueSubject<Bool, Never> { get }
    var isScanningSubject: CurrentValueSubject<Bool, Never> { get }
    var advertisingPeripheralsSubject: CurrentValueSubject<[BeanstormAdvertisingPeripheral], Never> { get }
    var connectedPeripheral: BeanstormPeripheral? { get }

    func startScanning();
    func stopScanning();
    func connect(advertisingPeripheral: BeanstormAdvertisingPeripheral)
}

extension CBPeripheral : Identifiable {
    public var id: UUID {
        identifier
    }
}

let dataServiceUUID = CBUUID(string: "8ec57513-faca-4a5c-9a45-912bd28ce1dc")

class BeanstormBLE: NSObject, BeanstormBLEService {
    let centralStateSubject: CurrentValueSubject<CBManagerState, Never>
    let isConnectedSubject: CurrentValueSubject<Bool, Never>
    let isScanningSubject: CurrentValueSubject<Bool, Never>
    
    var discoveredPeripherals: [CBPeripheral] = []
    let advertisingPeripheralsSubject: CurrentValueSubject<[BeanstormAdvertisingPeripheral], Never>
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral? = nil
    var scanningTimer = Timer()
    
    var connectedPeripheral: BeanstormPeripheral?

    override init() {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(.poweredOff)
        isConnectedSubject = CurrentValueSubject<Bool, Never>(false)
        isScanningSubject = CurrentValueSubject<Bool, Never>(false)
        advertisingPeripheralsSubject = CurrentValueSubject<[BeanstormAdvertisingPeripheral], Never>([])
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BeanstormBLE: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralStateSubject.send(central.state)
        print("State updated: \(central.state)")
    }

    func stopScanning() {
        print("Scan Stopped")
        scanningTimer.invalidate()
        isScanningSubject.send(false)
        centralManager.stopScan()

        advertisingPeripheralsSubject.send([])
        discoveredPeripherals = []
    }
    
    func startScanning() {
        print("Scan Started")
        isScanningSubject.send(true)
        
        centralManager.scanForPeripherals(withServices: [dataServiceUUID], options: nil)
        scanningTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.stopScanning()
        }
    }
    
    func updateAdvertisingPeripheralsSubject() {
        advertisingPeripheralsSubject.send(
            discoveredPeripherals.map { discoveredPeripheral in
                BeanstormAdvertisingPeripheral(
                    id: discoveredPeripheral.identifier,
                    name: discoveredPeripheral.name ?? "Unknown Device",
                    signalStrength: 0.8,
                    isConnecting: discoveredPeripheral.state == .connecting
                )
            }
        )
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(!discoveredPeripherals.contains(where: { discoveredPeripheral in discoveredPeripheral.identifier == peripheral.identifier })) {
            discoveredPeripherals.append(peripheral)
            updateAdvertisingPeripheralsSubject()
        }
    }
    
    func connect(advertisingPeripheral: BeanstormAdvertisingPeripheral)
    {
        guard let peripheral = discoveredPeripherals.first(where: { discoveredPeripheral in
            discoveredPeripheral.identifier == advertisingPeripheral.id
        }) else { return }

        centralManager.connect(peripheral)
        updateAdvertisingPeripheralsSubject()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        scanningTimer.invalidate()
        stopScanning()
    
        connectedPeripheral = BeanstormPeripheral(peripheral: peripheral)
        isConnectedSubject.send(true)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnectedSubject.send(false)
        connectedPeripheral = nil
    }
}
