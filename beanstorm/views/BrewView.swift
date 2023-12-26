import SwiftUI

struct BrewView: View {
    @StateObject var viewModel = BrewGraphPreviewModel()

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
                .foregroundStyle(.green)
            Text("Brewing")
                .font(.headline)
                .bold()
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                status
                Spacer()
                timer
            }
            BrewGraph(data: $viewModel.brewData)
            QuickMonitorView()
        }
        .padding()
    }
}

#Preview {
    BrewView()
}
