import SwiftUI

struct PIDSettings: View {
    @Binding var pid: PPID
    
    var body: some View {
        Group {
            Section(header: Text("kP - " + pid.kp.formatted())) {
                Slider(value: $pid.kp)
            }
            Section(header: Text("kI - " + pid.ki.formatted())) {
                Slider(value: $pid.ki)
            }
            Section(header: Text("kD - " + pid.kd.formatted())) {
                Slider(value: $pid.kd)
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
            if let heaterPid = Binding($peripheralModel.heaterPid) {
                Section(header: Text("Heater PID")) {
                    PIDSettings(pid: heaterPid)
                }
                
                Button("Update Settings") {
                    if let heaterPid = peripheralModel.heaterPid {
                        peripheralModel.dataService.updateSettings(heaterPid: heaterPid)
                    }
                }
            } else {
                ProgressView()
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
