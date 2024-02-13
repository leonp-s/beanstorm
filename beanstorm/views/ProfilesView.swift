import SwiftUI

struct EditProfileView: View {
//    var profile: FetchedResults<BrewProfile>.Element
    
    var body: some View {
        Text("Edit Profile")
    }
}

struct NewBrewProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var temperature: Double = 80.0
    @State private var duration: Double = 28.0

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Profile Name", text: $name)
                }
                Section(header: Text("Temperature")) {
                    Slider(value: $temperature, in: 0...100, step: 0.1)
                }
                Section(header: Text("Duration")) {
                    Slider(value: $duration, in: 0...100, step: 0.1)
                }
                
                Button("Create") {
                    let newProfile = BrewProfile(
                        temperature: temperature,
                        name: name,
                        duration: duration,
                        controlType: .pressure
                    )
                    context.insert(newProfile)
                    dismiss()
                }
                .disabled(name.isEmpty)
                .navigationTitle("New Brew Profile")
            }
        }
    }
}

#Preview {
    NewBrewProfileView()
}



struct ProfilesView: View {
    @Environment(\.modelContext) private var context
//    @FetchRequest(sortDescriptors: []) var profiles: FetchedResults<BrewProfile>
    @State private var showingAddView = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
//                    ForEach(profiles) { profile in
//                        NavigationLink(destination: EditProfileView()) {
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text(profile.name!)
//                                    .bold()
//                            }
//                        }
//                    }
//                    .onDelete(perform: deleteFood)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Profiles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddView.toggle()
                    } label: {
                        Label("Add Profile", systemImage: "plus.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddView) {
                NewBrewProfileView()
            }
        }
    }
}

#Preview {
    ProfilesView()
}
