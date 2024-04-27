import CoreBluetooth
import SwiftUI
import Combine

protocol DataService {
    var pressureSubject: CurrentValueSubject<Float, Never> { get }
    var temperatureSubject: CurrentValueSubject<Float, Never> { get }
    var flowSubject: CurrentValueSubject<Float, Never> { get }
    var heaterPIDSubject: CurrentValueSubject<PPID?, Never> { get }
    var brewProfileTransferSubject: CurrentValueSubject<BrewTransferState, Never> { get }
    
    func startShot();
    func endShot();
    func updateSettings(heaterPid: PPID);
    func sendBrewProfile(brewProfile: PBrewProfile);
}

let pressureCharacteristicUUID = CBUUID(string: "46851b87-ee86-42eb-9e35-aaee0cad5485")
let temperatureCharacteristicUUID = CBUUID(string: "76400bdc-15ce-4375-b861-97be9d54072c")
let flowCharacteristicUUID = CBUUID(string: "13cdb71e-8d34-4d53-8f40-05d5677a48f3")
let shotControlCharacteristicUUID = CBUUID(string: "7e4881af-f9f6-4c12-bf5c-70509ba3d6b4")
let heaterPIDCharacteristicUUID = CBUUID(string: "ad94bdc2-8ea0-4282-aed8-47c4f917349b")
let brewProfileTransferCharacteristicUUID = CBUUID(string: "417249bc-3a8b-4958-8d44-d080eb48b890")


enum BrewTransferState: Equatable {
    case idle
    case transfer
    case failed(String)
}

class BeanstormPeripheral: NSObject, CBPeripheralDelegate, DataService {
    let peripheral: CBPeripheral
    
    let pressureSubject = CurrentValueSubject<Float, Never> (0.0);
    let temperatureSubject = CurrentValueSubject<Float, Never> (0.0);
    let flowSubject = CurrentValueSubject<Float, Never> (0.0);
    let heaterPIDSubject = CurrentValueSubject<PPID?, Never> (nil);
    let brewProfileTransferSubject = CurrentValueSubject<BrewTransferState, Never> (.idle);

    var dataService: CBService? = nil
    
    var pressureCharacteristic: CBCharacteristic? = nil
    var temperatureCharacteristic: CBCharacteristic? = nil
    var flowCharacteristic: CBCharacteristic? = nil
    var shotControlCharacteristic: CBCharacteristic? = nil
    var heaterPIDCharacteristic: CBCharacteristic? = nil
    
    let endFileFlag = "EOF"
    var brewProfileData: Data? = nil
    var brewProfileTransferCharacteristic: CBCharacteristic? = nil
    
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
        self.shotControlCharacteristic = characteristics.first(where: { $0.uuid == shotControlCharacteristicUUID })
        self.heaterPIDCharacteristic = characteristics.first(where: {$0.uuid == heaterPIDCharacteristicUUID })
        self.brewProfileTransferCharacteristic = characteristics.first(where: {$0.uuid == brewProfileTransferCharacteristicUUID })

        subscribeToCharacteristics()
    }
    
    func subscribeToCharacteristics() {
        guard let pressureCharacteristic = self.pressureCharacteristic, let temperatureCharacteristic = self.temperatureCharacteristic, let flowCharacteristic = self.flowCharacteristic, let heaterPIDCharacteristic = self.heaterPIDCharacteristic else {
            print("Characteristics were not found during discovery!")
            return
        }
        
        peripheral.setNotifyValue(true, for: pressureCharacteristic)
        peripheral.setNotifyValue(true, for: temperatureCharacteristic)
        peripheral.setNotifyValue(true, for: flowCharacteristic)
        
        peripheral.setNotifyValue(true, for: heaterPIDCharacteristic)
        peripheral.readValue(for: heaterPIDCharacteristic)
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
        
        if(characteristic == heaterPIDCharacteristic) {
            readHeaterPID()
        }
        
        if(characteristic == brewProfileTransferCharacteristic) {
            brewTransferUpdate()
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
    
    func startShot() {
        if let shotControlCharacteristic = self.shotControlCharacteristic {
            var startShot = true.intValue
            let data = Data(bytes: &startShot, count: MemoryLayout.size(ofValue: startShot))
            peripheral.writeValue(data, for: shotControlCharacteristic, type: .withResponse)
        }
    }
    
    func endShot() {
        if let shotControlCharacteristic = self.shotControlCharacteristic {
            var startShot = false.intValue
            let data = Data(bytes: &startShot, count: MemoryLayout.size(ofValue: startShot))
            peripheral.writeValue(data, for: shotControlCharacteristic, type: .withResponse)
        }
    }
    
    func readHeaterPID() {
        if let data = heaterPIDCharacteristic?.value {
            heaterPIDSubject.send(try? PPID(serializedData: data))
        }
    }
    
    func updateSettings(heaterPid: PPID) {
        if let heaterPIDCharacteristic = self.heaterPIDCharacteristic {
            if let data = try? heaterPid.serializedData() {
                peripheral.writeValue(data, for: heaterPIDCharacteristic, type: .withResponse)
            }
        }
    }
    
    func extractBrewProfileChunk() -> Data? {
        guard var content = brewProfileData, content.count > 0  else {
            return nil
        }
        
        let amountToSend = min(content.count, peripheral.maximumWriteValueLength(for: .withoutResponse))
        let range = 0..<amountToSend
        let chunk = content.subdata(in: range)
        content.removeSubrange(range)
        return chunk
    }
    
    func sendBrewProfileData() {
        if let brewProfileTransferCharacteristic = self.brewProfileTransferCharacteristic {
            let sentDataPacket = extractBrewProfileChunk()

            if sentDataPacket != nil {
                peripheral.writeValue(sentDataPacket!, for: brewProfileTransferCharacteristic, type: .withoutResponse)
            }
            else {
                peripheral.writeValue(endFileFlag.data(using: String.Encoding.utf8)!, for: brewProfileTransferCharacteristic, type: .withoutResponse)
            }
        }
    }
    
    func brewTransferUpdate() {
        if let brewProfileTransferCharacteristic = brewProfileTransferCharacteristic, let data = brewProfileTransferCharacteristic.value {
            if data == endFileFlag.data(using: .utf8) {
                peripheral.setNotifyValue(false, for: brewProfileTransferCharacteristic)
                brewProfileTransferSubject.send(.idle)
            } else {
                sendBrewProfileData()
            }
        }
    }
    
    func sendBrewProfile(brewProfile: PBrewProfile) {
        brewProfileTransferSubject.send(.transfer)

        if let brewProfileTransferCharacteristic = self.brewProfileTransferCharacteristic {
            if let data = try? brewProfile.serializedData() {
                brewProfileData = data
                peripheral.setNotifyValue(true, for: brewProfileTransferCharacteristic)
                sendBrewProfileData()
            } else {
                brewProfileTransferSubject.send(.failed("Failed to serialize profile!"))
            }
        } else {
            brewProfileTransferSubject.send(.failed("No characteristic found!"))
        }
    }
}

class BeanstormPeripheralModel: ObservableObject {
    let dataService: DataService

    private var subscriptions = Set<AnyCancellable>()

    @Published var pressure: Double = 0.0
    @Published var temperature: Double = 0.0
    @Published var flow: Double = 0.0
    @Published var heaterPid: PPID? = nil
    @Published var brewProfileTransfer: BrewTransferState = .idle
        
    init(dataService: DataService) {
        self.dataService = dataService
        
        self.dataService.pressureSubject
            .sink { value in self.pressure = Double(value) }
            .store(in: &subscriptions)
        
        self.dataService.temperatureSubject
            .sink { value in self.temperature = Double(value) }
            .store(in: &subscriptions)
        
        self.dataService.flowSubject
            .sink { value in self.flow = Double(value) }
            .store(in: &subscriptions)
        
        self.dataService.heaterPIDSubject
            .sink { value in self.heaterPid = value }
            .store(in: &subscriptions)
        
        self.dataService.brewProfileTransferSubject
            .sink { value in self.brewProfileTransfer = value }
            .store(in: &subscriptions)
    }
}
