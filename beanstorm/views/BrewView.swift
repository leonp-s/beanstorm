import SwiftUI

struct BrewView: View {
    var body: some View {
        VStack {
            BrewGraph(data: .constant([]))
            QuickMonitorView()
        }
        .padding()
    }
}

#Preview {
    BrewView()
}
