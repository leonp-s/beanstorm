import SwiftUI

struct BrewView: View {
    @State private var started: Bool = false
    
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
                    Image(systemName: "play.circle")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    var body: some View {
            VStack {
                HStack {
                    status
                    Spacer()
                    if started {
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
                QuickMonitorView()
            }
            .padding()
    }
}

#Preview {
    BrewView()
}
