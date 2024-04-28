import SwiftUI

struct PIDSettings: View {
    @Binding var pid: PPID
    
    var body: some View {
        Group {
            Section(header: Text("kP - " + pid.kp.formatted())) {
                Stepper(value: $pid.kp, in: 0...10, step: 0.01) {
                    Slider(value: $pid.kp, in: 0...10)
                }
            }
            Section(header: Text("kI - " + pid.ki.formatted())) {
                Stepper(value: $pid.ki, in: 0...10, step: 0.01) {
                    Slider(value: $pid.ki, in: 0...10)
                }
            }
            Section(header: Text("kD - " + pid.kd.formatted())) {
                Stepper(value: $pid.kd, in: 0...10, step: 0.01) {
                    Slider(value: $pid.kd, in: 0...10)
                }
            }
        }
    }
}


#Preview("PID Settings") {
    PIDSettings(pid: .constant(PPID.with {
        $0.kp = 1.0
        $0.ki = 0.8
        $0.kd = 1.2
    }))
}

struct PeripheralSettingsView : View {
    @StateObject var peripheralModel: BeanstormPeripheralModel
    
    var body: some View {
        Group {
            if let heaterPid = Binding($peripheralModel.heaterPid), let pumpPid = Binding($peripheralModel.pumpPid) {
                Section(header: Text("Heater PID")) {
                    PIDSettings(pid: heaterPid)
                }
                
                Section(header: Text("Pump PID")) {
                    PIDSettings(pid: pumpPid)
                }
            } else {
                ProgressView()
            }
            
            Button("Update Settings") {
                if let heaterPid = peripheralModel.heaterPid, let pumpPid = peripheralModel.pumpPid {
                    peripheralModel.dataService.updateSettings(heaterPid: heaterPid, pumpPid: pumpPid)
                }
            }
        }
    }
}

#Preview {
    PeripheralSettingsView(peripheralModel: BeanstormPeripheralModel(
        dataService: MockDataService()
    ))
}


struct SettingsView: View {
    @State var isDarkModeEnabled: Bool = true
    @State var enableLiveActivity: Bool = false
    @EnvironmentObject private var beanstormBLE: BeanstormBLEModel

    var body: some View {
        Form {
            Section("Preferences") {
                HStack{
                    Image(systemName: "waveform.path.ecg.rectangle")
                    Toggle(isOn: $enableLiveActivity) {
                        Text("Live activity enabled")
                    }
                }
            }
            
            Section("Device") {
                if(beanstormBLE.isConnected) {
                    PeripheralSettingsView(
                        peripheralModel: .init(
                            dataService: beanstormBLE.service.connectedPeripheral!
                        )
                    )
                } else {
                    DeviceConnectivity()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(BeanstormBLEModel())
}
