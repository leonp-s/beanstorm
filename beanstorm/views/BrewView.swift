import SwiftUI
import Combine

struct BrewView: View {
    @State private var started: Bool = false
    @StateObject var peripheralModel: BeanstormPeripheralModel
    
    private var timer: some View {
        Group {
            Image(systemName: "timer")
                .foregroundStyle(.yellow)
            Text("00:11")
                .font(.headline)
                .bold()
        }
    }
    
    private var status: some View {
        Group {
            Image(systemName: "waveform.path.ecg.rectangle")
                .foregroundStyle(.primary)
            Text("Idle")
                .font(.headline)
                .bold()
        }
    }
    
    private var profile: some View {
        Group {
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
                    started = true
                }) {
                    Text("Start Shot")
                    Image(systemName: "play.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    var body: some View {
        VStack {
                if started {
                    HStack {
                        Spacer()
                        Button("End Shot", systemImage: "stop.circle.fill", role: .destructive) {
                            started = false
                        }
                    }
                    .padding(.bottom)
                }
                HStack {
                    status
                    Spacer()
                    if started {
                        profile
                        Spacer()
                        timer
                    }
                }
                Group {
                    if started {
                        BrewGraph(data: .constant([]))
                    } else {
                        getReady
                    }
                }
                .animation(.bouncy, value: started)
                .transition(.slide)
                QuickMonitorView(
                    pressue: $peripheralModel.pressure,
                    temperature: $peripheralModel.temperature,
                    flow: $peripheralModel.flow
                )
        }
        .padding()
    }
}

class MockDataService: DataService {
    var pressureSubject: CurrentValueSubject<Float, Never>
    var temperatureSubject: CurrentValueSubject<Float, Never>
    var flowSubject: CurrentValueSubject<Float, Never>
    
    init() {
        self.pressureSubject = CurrentValueSubject<Float, Never>(1.4)
        self.temperatureSubject = CurrentValueSubject<Float, Never>(86.8)
        self.flowSubject = CurrentValueSubject<Float, Never>(2.6)
    }
}

#Preview {
    BrewView(
        peripheralModel: BeanstormPeripheralModel(
            dataService: MockDataService()
        )
    )
}
