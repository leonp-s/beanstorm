import SwiftUI
import Combine

struct BrewView: View {
    @StateObject var peripheralModel: BeanstormPeripheralModel
    @State var isBrewing: Bool = false
    
    let brew_impact = UIImpactFeedbackGenerator(style: .medium)


    private var timer: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(.yellow)
            Text("00:11")
                .font(.headline)
                .bold()
        }
    }
    
    private var status: some View {
        HStack {
            Image(systemName: "waveform.path.ecg.rectangle")
                .foregroundStyle(.primary)
            Text("Idle")
                .font(.headline)
                .bold()
        }
    }
    
    private var profile: some View {
        HStack {
            Image(systemName: "stopwatch")
                .foregroundStyle(.primary)
            Text("Bean Flow")
                .font(.headline)
                .bold()
        }
    }

    
    private var getReady: some View {
        ContentUnavailableView {
            Label("BeanstormOS Idle", systemImage: "lightswitch.off")
        } description: {
            Text("Load a profile and begin a shot using the machines front panel or via the app.")
            HStack {
                Button(action: {
                    isBrewing = true
                    brew_impact.prepare()
                    brew_impact.impactOccurred()
                    
                    peripheralModel.dataService.startShot()
                }) {
                    Text("Start Shot")
                    Image(systemName: "play.circle.fill")
                }
                .onLongPressGesture(minimumDuration: 0, perform: {}) { pressing in
                    if pressing {
                        brew_impact.prepare()
                        brew_impact.impactOccurred()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var brewing: some View {
        VStack {
            HStack {
                profile
                Spacer()
                timer
            }
            BrewGraph(data: .constant([]))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if(isBrewing) {
                    brewing
                        .transition(.move(edge: self.isBrewing ? .trailing : .leading))
                } else {
                    getReady
                        .transition(.move(edge: self.isBrewing ? .trailing : .leading))
                }
                QuickMonitorView(
                    pressue: $peripheralModel.pressure,
                    temperature: $peripheralModel.temperature,
                    flow: $peripheralModel.flow
                )
            }
            .padding()
            .animation(.easeInOut, value: isBrewing)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    status
                }
                if(isBrewing) {
                    ToolbarItem {
                        Button(
                            "End Shot",
                            systemImage: "stop.circle.fill",
                            role: .destructive
                        ) {
                            isBrewing = false
                            peripheralModel.dataService.endShot()
                            brew_impact.prepare()
                            brew_impact.impactOccurred()
                        }
                        .onLongPressGesture(minimumDuration: 0, perform: {}) { pressing in
                            if pressing {
                                brew_impact.prepare()
                                brew_impact.impactOccurred()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
}

class MockDataService: DataService {
    func startShot() { }
    func endShot() { }
    func updateSettings(heaterPid: PPID, pumpPid: PPID) { }
    func sendBrewProfile(brewProfile: PBrewProfile) { }
    func stopSendingBrewProfile() { }

    var pressureSubject: CurrentValueSubject<Float, Never>
    var temperatureSubject: CurrentValueSubject<Float, Never>
    var flowSubject: CurrentValueSubject<Float, Never>
    var heaterPIDSubject: CurrentValueSubject<PPID?, Never>
    var pumpPIDSubject: CurrentValueSubject<PPID?, Never>
    var brewProfileTransferSubject: CurrentValueSubject<BrewTransferState, Never>
    
    init() {
        self.pressureSubject = CurrentValueSubject<Float, Never>(1.4)
        self.temperatureSubject = CurrentValueSubject<Float, Never>(86.8)
        self.flowSubject = CurrentValueSubject<Float, Never>(2.6)
        self.heaterPIDSubject = CurrentValueSubject<PPID?, Never>(PPID.with {
            $0.kp = 1.0
            $0.ki = 0.6
            $0.kd = 1.2
        })
        self.pumpPIDSubject = CurrentValueSubject<PPID?, Never>(PPID.with {
            $0.kp = 1.0
            $0.ki = 0.6
            $0.kd = 1.2
        })
        self.brewProfileTransferSubject = CurrentValueSubject<BrewTransferState, Never>(.idle)
    }
}

#Preview {
    BrewView(
        peripheralModel: BeanstormPeripheralModel(
            dataService: MockDataService()
        )
    )
}
