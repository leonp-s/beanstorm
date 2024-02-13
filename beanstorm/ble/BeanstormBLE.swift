import CoreBluetooth
import Combine

protocol BeanstormBLEService {
    var centralStateSubject: CurrentValueSubject<CBManagerState, Never> { get }
    var isConnectedSubject: CurrentValueSubject<Bool, Never> { get }
    var isScanningSubject: CurrentValueSubject<Bool, Never> { get }
    var devicesSubject: CurrentValueSubject<[CBPeripheral], Never> { get }
    var connectedPeripheral: BeanstormPeripheral? { get }

    func startScanning();
    func stopScanning();
    func connect(peripheral: CBPeripheral)
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
    let devicesSubject: CurrentValueSubject<[CBPeripheral], Never>
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral? = nil
    var scanningTimer = Timer()
    
    var connectedPeripheral: BeanstormPeripheral?

    override init() {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(.poweredOff)
        isConnectedSubject = CurrentValueSubject<Bool, Never>(false)
        isScanningSubject = CurrentValueSubject<Bool, Never>(false)
        devicesSubject = CurrentValueSubject<[CBPeripheral], Never>([])
        
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
        devicesSubject.send([])
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

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var devices = self.devicesSubject.value
        if(!devices.contains(where: { device in device.identifier == peripheral.identifier })) {
            devices.append(peripheral)
            devicesSubject.send(devices)
        }
    }
    
    func connect(peripheral: CBPeripheral)
    {
        centralManager.connect(peripheral)
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
