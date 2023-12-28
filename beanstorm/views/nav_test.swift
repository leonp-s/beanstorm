import SwiftUI

enum BrewState {
    case idle
    case brewing
}

class NavigationStateManager: ObservableObject {

    @Published var path = NavigationPath()
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func didConnect() {
        path.append(BrewState.idle)
    }
    
    func startBrew() {
        path.append(BrewState.brewing)
    }
}

struct test: View {
    @StateObject private var nav = NavigationStateManager()

    var body: some View {
        NavigationStack(path: $nav.path) {
            VStack {
                Button {
                    nav.didConnect()
                } label: {
                    Text("Connect")
                }
                
                Button {
                    nav.startBrew()
                } label: {
                    Text("Brew")
                }
            }
            .navigationDestination(for: BrewState.self) { brewState in
                switch brewState {
                case .brewing:
                    Text("BREW")
                        .navigationBarBackButtonHidden()
                case .idle:
                    Text("IDLE")
                }

            }
        }
    }
}

#Preview {
    test()
}
