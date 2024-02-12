import CoreBluetooth
import Combine

enum BeanstormConnectionState {
    case disconnected, scanning, connected
}

protocol BeanstormBLEService {
    var centralStateSubject: CurrentValueSubject<CBManagerState, Never> { get }
    var conectionStateSubject: CurrentValueSubject<BeanstormConnectionState, Never> { get }
    var devicesSubject: CurrentValueSubject<[CBPeripheral], Never> { get }
    var connectedPeripheral: BeanstormPeripheral? { get }

    func startScanning();
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
    let conectionStateSubject: CurrentValueSubject<BeanstormConnectionState, Never>
    let devicesSubject: CurrentValueSubject<[CBPeripheral], Never>
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral? = nil
    var scanningTimer = Timer()
    
    var connectedPeripheral: BeanstormPeripheral?

    override init() {
        centralStateSubject = CurrentValueSubject<CBManagerState, Never>(.poweredOff)
        conectionStateSubject = CurrentValueSubject<BeanstormConnectionState, Never>(.disconnected)
        devicesSubject = CurrentValueSubject<[CBPeripheral], Never>([])
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BeanstormBLE: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralStateSubject.send(central.state)
        print("State updated: \(central.state)")
        
        switch central.state {
        case .poweredOn:
            startScanning()
            break;
        default:
            break;
        }
    }

    func stopScanning() {
        print("Scan Stopped")
        conectionStateSubject.send(.disconnected)
        centralManager.stopScan()
        devicesSubject.send([])
    }
    
    func startScanning() {
        print("Scan Started")
        conectionStateSubject.send(.scanning)
        
        centralManager.scanForPeripherals(withServices: [dataServiceUUID], options: nil)
        scanningTimer = Timer.scheduledTimer(withTimeInterval: 18.0, repeats: false) { [weak self] _ in
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
        conectionStateSubject.send(.connected)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        conectionStateSubject.send(.connected)
        connectedPeripheral = nil
    }
}
