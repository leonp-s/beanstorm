import SwiftUI

struct SettingsView: View {
    @State var isDarkModeEnabled: Bool = true
    @State var enableLiveActivity: Bool = false
    
    var body: some View {
        Form {            
            Section("Content"){
                HStack{
                    Image(systemName: "star")
                    Text("Favorites")
                }
            }

            Section("Preferences") {
                HStack{
                    Image(systemName: "globe")
                    Text("Language")
                }
                HStack{
                    Image(systemName: "waveform.path.ecg.rectangle")
                    Toggle(isOn: $enableLiveActivity) {
                        Text("Live activity enabled")
                    }
                }
            }
            
            Section("Device") {
                ContentUnavailableView {
                    Label("No Device Connected", systemImage: "tropicalstorm")
                } description: {
                    Text("Connect to a device to view these settings.")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
