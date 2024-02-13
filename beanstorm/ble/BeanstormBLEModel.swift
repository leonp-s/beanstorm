import SwiftUI
import CoreBluetooth
import Combine

class BeanstormBLEModel: ObservableObject {
    let service: BeanstormBLEService
    
    private var subscriptions = Set<AnyCancellable>()
    @Published var centralState: CBManagerState!
    @Published var isConnected: Bool = false
    @Published var isScanning: Bool = false
    @Published var devices: [CBPeripheral] = []
    
    init(service: BeanstormBLEService = BeanstormBLE()) {
        self.service = service
        
        service.centralStateSubject
            .sink { centralState in self.centralState = centralState }
            .store(in: &subscriptions)
        
        service.isConnectedSubject
            .sink { isConnected in self.isConnected = isConnected }
            .store(in: &subscriptions)
        
        service.isScanningSubject
            .sink { isScanning in self.isScanning = isScanning }
            .store(in: &subscriptions)
        
        service.devicesSubject
            .sink { devices in self.devices = devices }
            .store(in: &subscriptions)
    }
    
    func displayAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
    }
    
    func displaySystemSettings() {
        if let settingsUrl = URL(string: "App-Prefs:root=General") {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
    }
}
