import SwiftUI
import CoreBluetooth
import Combine

class BeanstormBLEModel: ObservableObject {
    let service: BeanstormBLEService
    
    private var subscriptions = Set<AnyCancellable>()
    @Published var centralState: CBManagerState!
    @Published var connectionState: BeanstormConnectionState = .disconnected
    @Published var devices: [BeanstormAdvertisingPeripheral] = []
    
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
    
    func displaySettingsUI() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
    }
}
