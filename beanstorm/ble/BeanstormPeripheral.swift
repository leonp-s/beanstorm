import CoreBluetooth
import SwiftUI
import Combine

struct BeanstormAdvertisingPeripheral: Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral?
    let name: String
    
    init(peripheral: CBPeripheral?) {
        self.peripheral = peripheral
        name = peripheral?.name ?? "Unknown Device"
    }
}

let pressureCharacteristicUUID = CBUUID(string: "46851b87-ee86-42eb-9e35-aaee0cad5485")
let temperatureCharacteristicUUID = CBUUID(string: "76400bdc-15ce-4375-b861-97be9d54072c")
let flowCharacteristicUUID = CBUUID(string: "13cdb71e-8d34-4d53-8f40-05d5677a48f3")

class BeanstormPeripheral: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral

    var dataService: CBService? = nil
    
    var pressureCharacteristic: CBCharacteristic? = nil
    var temperatureCharacteristic: CBCharacteristic? = nil
    var flowCharacteristic: CBCharacteristic? = nil
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        
        peripheral.delegate = self
        peripheral.discoverServices([dataServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error != nil) {
            print("Error discovering services. \(error!)")
            return
        }
        
        if let services = peripheral.services {
            self.dataService = services.first(where: { $0.uuid == dataServiceUUID })
            guard let dataService = self.dataService else { return }
            peripheral.discoverCharacteristics(nil, for: dataService)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error != nil) {
             print("Error discovering characteristics. \(error!)")
             return;
        }
        
        guard let characteristics = service.characteristics else { return }
        self.pressureCharacteristic = characteristics.first(where: { $0.uuid == pressureCharacteristicUUID })
        self.temperatureCharacteristic = characteristics.first(where: { $0.uuid == temperatureCharacteristicUUID })
        self.flowCharacteristic = characteristics.first(where: { $0.uuid == flowCharacteristicUUID })
        
        subscribeToCharacteristics()
    }
    
    func subscribeToCharacteristics() {
        guard let pressureCharacteristic = self.pressureCharacteristic, let temperatureCharacteristic = self.temperatureCharacteristic, let flowCharacteristic = self.flowCharacteristic else {
            print("Characteristics were not found during discovery!")
            return
        }
        
        peripheral.setNotifyValue(true, for: pressureCharacteristic)
        peripheral.setNotifyValue(true, for: temperatureCharacteristic)
        peripheral.setNotifyValue(true, for: flowCharacteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
             print("Error receiveing notification for characteristic. \(error!)")
             return;
        }
        
        if let data = characteristic.value {
            let value = data.withUnsafeBytes( {(pointer: UnsafeRawBufferPointer) -> Float in
                return pointer.load(as: Float.self)
            })
            
            print("Value updated for charecteristic: \(characteristic.uuid), Updated Value: \(value)")
        }
    }
}
