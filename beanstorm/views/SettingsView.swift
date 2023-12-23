import SwiftUI

struct SettingsView: View {
    @State var isDarkModeEnabled: Bool = true
    @State var downloadViaWifiEnabled: Bool = false
    
    var body: some View {
        Form {            
            Section("Content"){
                HStack{
                    Image(systemName: "star")
                    Text("Favorites")
                }

                HStack{
                    Image(systemName: "arrow.down.circle")
                    Text("Downloads")
                }
            }

            Section("Preferences") {
                HStack{
                    Image(systemName: "globe")
                    Text("Language")
                }
                HStack{
                    Image(systemName: "moon")
                    Toggle(isOn: $isDarkModeEnabled) {
                        Text("Dark Mode")
                    }
                }
                HStack{
                    Image(systemName: "wifi")
                    Toggle(isOn: $downloadViaWifiEnabled) {
                        Text("Only Download via Wi-Fi")
                    }
                }
                HStack{
                    Image(systemName: "icloud")
                    Text("Play in Background")
                }

            }
        }
    }
}

#Preview {
    SettingsView()
}
