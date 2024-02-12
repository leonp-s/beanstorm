import CoreBluetooth
import SwiftUI
import Combine

protocol DataService {
    var pressureSubject: CurrentValueSubject<Float, Never> { get }
    var temperatureSubject: CurrentValueSubject<Float, Never> { get }
    var flowSubject: CurrentValueSubject<Float, Never> { get }
}

let pressureCharacteristicUUID = CBUUID(string: "46851b87-ee86-42eb-9e35-aaee0cad5485")
let temperatureCharacteristicUUID = CBUUID(string: "76400bdc-15ce-4375-b861-97be9d54072c")
let flowCharacteristicUUID = CBUUID(string: "13cdb71e-8d34-4d53-8f40-05d5677a48f3")

class BeanstormPeripheral: NSObject, CBPeripheralDelegate, DataService {
    let peripheral: CBPeripheral
    
    let pressureSubject = CurrentValueSubject<Float, Never> (0.0);
    let temperatureSubject = CurrentValueSubject<Float, Never> (0.0);
    let flowSubject = CurrentValueSubject<Float, Never> (0.0);

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
        
        if(characteristic == pressureCharacteristic) {
            readPressure()
        }
        
        if(characteristic == temperatureCharacteristic) {
            readTemperature()
        }
        
        if(characteristic == flowCharacteristic) {
            readFlow()
        }
    }
    
    func readPressure() {
        if let data = pressureCharacteristic?.value {
            let value = data.withUnsafeBytes( {(pointer: UnsafeRawBufferPointer) -> Float in
                return pointer.load(as: Float.self)
            })
            pressureSubject.send(value)
        }
    }
    
    func readTemperature() {
        if let data = temperatureCharacteristic?.value {
            let value = data.withUnsafeBytes( {(pointer: UnsafeRawBufferPointer) -> Float in
                return pointer.load(as: Float.self)
            })
            temperatureSubject.send(value)
        }
    }
    
    func readFlow() {
        if let data = flowCharacteristic?.value {
            let value = data.withUnsafeBytes( {(pointer: UnsafeRawBufferPointer) -> Float in
                return pointer.load(as: Float.self)
            })
            flowSubject.send(value)
        }
    }
}

class BeanstormPeripheralModel: ObservableObject {
    let dataService: DataService

    private var subscriptions = Set<AnyCancellable>()

    @Published var pressure: Double = 0.0
    @Published var temperature: Double = 0.0
    @Published var flow: Double = 0.0
    
    private var targetPressure: Double = 0.0
    private var targetTemperature: Double = 0.0
    private var targetFlow: Double = 0.0
    
    private var timer: Timer?
    
    init(dataService: DataService) {
        self.dataService = dataService
        
        self.dataService.pressureSubject
            .sink { value in self.targetPressure = Double(value) }
            .store(in: &subscriptions)
        
        self.dataService.temperatureSubject
            .sink { value in self.targetTemperature = Double(value) }
            .store(in: &subscriptions)
        
        self.dataService.flowSubject
            .sink { value in self.targetFlow = Double(value) }
            .store(in: &subscriptions)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if(!self.pressure.isNearlyEqual(to: self.targetPressure, precision: 0.1)) {
                self.pressure = self.smoothedValue(
                    valueToSmooth: self.pressure,
                    target: self.targetPressure
                )
            }
            
            if(!self.temperature.isNearlyEqual(to: self.targetTemperature, precision: 0.1)) {
                self.temperature = self.smoothedValue(
                    valueToSmooth: self.temperature,
                    target: self.targetTemperature
                )
            }
            
            if(!self.flow.isNearlyEqual(to: self.targetFlow, precision: 0.1)) {
                self.flow = self.smoothedValue(
                    valueToSmooth: self.flow,
                    target: self.targetFlow
                )
            }
        }
    }
    
    private func smoothedValue (valueToSmooth: Double,
                                target: Double) -> Double
    {
        let delta = 0.01
        let step = (target - valueToSmooth) * delta;
        return valueToSmooth + step;
    }
}
