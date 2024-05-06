import SwiftUI
import Combine

func SmoothedValue (valueToSmooth: Double, target: Double) -> Double
{
    let delta = 0.08;
    let step = (target - valueToSmooth) * delta;
    return valueToSmooth + step;
}

struct BrewView: View {
    @StateObject var peripheralModel: BeanstormPeripheralModel
    @State var isBrewing: Bool = false
    @State var brewData: [BrewData] = []
    @State var shotStartTime: Date = Date.now;
    @State var shotElapsedTime: TimeInterval = TimeInterval(integerLiteral: 0.0)
    
    @State var smoothPressure: Double = 0.0
    @State var smoothTemperature: Double = 0.0
    @State var smoothFlow: Double = 0.0

    let shotTimer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    let brew_impact = UIImpactFeedbackGenerator(style: .medium)

    private var timer: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(.yellow)
            Text(shotElapsedTime.formattedMinsSecs)
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
    
    private var normalisedTemp: Double {
        return (peripheralModel.temperature - temperatureMin) / (temperatureMax - temperatureMin)
    }
    
    private var normalisedPressure: Double {
        return peripheralModel.pressure / pressureMax
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
                    shotStartTime = Date.now;
                    brewData = [];
                    smoothFlow = peripheralModel.flow
                    smoothPressure = normalisedPressure
                    smoothTemperature = normalisedTemp
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
            BrewGraph(data: $brewData)
                .onReceive(shotTimer) { time in
                    smoothTemperature = SmoothedValue(
                        valueToSmooth: smoothTemperature,
                        target: normalisedTemp
                    )
                    smoothPressure = SmoothedValue(
                        valueToSmooth: smoothPressure,
                        target: normalisedPressure
                    )
                    smoothFlow = SmoothedValue(
                        valueToSmooth: smoothFlow,
                        target: peripheralModel.flow
                    )
                    
                    shotElapsedTime = time.timeIntervalSince(shotStartTime)

                    brewData.append(BrewData(
                        id: UUID(),
                        shotTime: shotElapsedTime.magnitude,
                        temperature: smoothTemperature,
                        pressure: smoothPressure,
                        flow: smoothFlow
                    ))
                    
                    if(brewData.count > maxDataPoints) {
                        brewData.removeFirst()
                    }
                }
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
