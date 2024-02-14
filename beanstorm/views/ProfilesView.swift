import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    let profile: BrewProfile

    @State private var name: String = ""
    @State private var temperature: Double = 80.0
    @State private var duration: Double = 28.0
    @State private var controlType: ControlType = .pressure
    
    @State private var showingEditor: Bool = false
    
    var changed: Bool {
        profile.name != name ||
        profile.temperature != temperature ||
        profile.duration != duration ||
        profile.controlType != controlType
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Profile Name", text: $name)
                }
                Section(header: Text("Temperature")) {
                    VStack {
                        Slider(
                            value: $temperature,
                            in: 0...100,
                            step: 0.1
                        ) {
                            Text("Values from 0 to 100")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("100")
                        }
                        
                        Text(String(format: "%.1f", temperature))
                            .font(.headline)
                    }
                }
                
                Section(header: Text("Control Type")) {
                    Picker("Control Type", selection: $controlType) {
                        Text("Pressure").tag(ControlType.pressure)
                        Text("Flow").tag(ControlType.flow)
                    }
                }
                
                Section(header: Text("Profile")) {
                    ProfileGraph(
                        positions: [
                            ControlPoint(id: UUID(), time: 0.0, value: 1.0),
                            ControlPoint(id: UUID(), time: 4.0, value: 0.8),
                            ControlPoint(id: UUID(), time: 6.0, value: 0.3),
                            ControlPoint(id: UUID(), time: 10.0, value: 0.9)
                        ]
                    )
                    .frame(height: 280)
                    .listRowSeparator(.hidden)
                }
                .sheet(isPresented: $showingEditor) {
                    ProfileEditor(
                        positions: [
                            ControlPoint(id: UUID(), time: 0.0, value: 1.0),
                            ControlPoint(id: UUID(), time: 4.0, value: 0.8),
                            ControlPoint(id: UUID(), time: 6.0, value: 0.3),
                            ControlPoint(id: UUID(), time: 10.0, value: 0.9)
                        ]
                    )
                    .padding()
                    .presentationDetents([.fraction(0.8)])
                }
                Button("Open Profile Editor", systemImage: "square.and.pencil") {
                    showingEditor = true
                }
                Section(header: Text("Duration")) {
                    VStack {
                        Slider(
                            value: $duration,
                            in: 0...100,
                            step: 0.1
                        ) {
                            Text("Values from 0 to 100")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("100")
                        }
                        
                        Text(String(format: "%.1f", duration))
                            .font(.headline)
                    }
                }
            }
            
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Update") {
                    profile.name = name
                    profile.temperature = temperature
                    profile.duration = duration
                    profile.controlType = controlType
                    
                    dismiss()
                }
                .disabled(!changed)
            }
            .onAppear {
                name = profile.name
                temperature = profile.temperature
                duration = profile.duration
                controlType = profile.controlType
            }
        }
    }
}

#Preview("Edit Brew Profile") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BrewProfile.self, configurations: config)

    return EditProfileView(
        profile: BrewProfile(
            temperature: 88.0,
            name: "Profile # 1",
            duration: 36.0,
            controlType: .pressure
        )
    )
    .modelContainer(container)
}

struct NewBrewProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var temperature: Double = 80.0
    @State private var duration: Double = 28.0
    @State private var controlType: ControlType = .pressure

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Profile Name", text: $name)
                }
                Picker("Control Type", selection: $controlType) {
                    Text("Pressure").tag(ControlType.pressure)
                    Text("Flow").tag(ControlType.flow)
                }
                Section(header: Text("Temperature")) {
                    VStack {
                        Slider(
                            value: $temperature,
                            in: 0...100,
                            step: 0.1
                        ) {
                            Text("Values from 0 to 100")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("100")
                        }
                        
                        Text(String(format: "%.1f", temperature))
                            .font(.headline)
                    }
                }
                Section(header: Text("Duration")) {
                    VStack {
                        Slider(
                            value: $duration,
                            in: 0...100,
                            step: 0.1
                        ) {
                            Text("Values from 0 to 100")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("100")
                        }
                        
                        Text(String(format: "%.1f", duration))
                            .font(.headline)
                    }
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
            }
            .navigationTitle("New Brew Profile")
        }
    }
}

#Preview("New Brew Profile") {
    NewBrewProfileView()
}

struct ProfilesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BrewProfile.name) private var profiles: [BrewProfile]
    @State private var showingAddView = false

    var body: some View {
        NavigationStack {
            Group {
                if(profiles.isEmpty) {
                    ContentUnavailableView {
                        Label("No Brew Profiles", systemImage: "tropicalstorm")
                    } description: {
                        Text ("Get started by creating your first brew profile.")
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List {
                        ForEach(profiles) { profile in
                            NavigationLink(
                                destination: EditProfileView(
                                    profile: profile
                                )
                            ) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(profile.name)
                                        .bold()
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let profile = profiles[index]
                                context.delete(profile)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Brew Profiles")
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

#Preview("Profiles View") {
    ProfilesView()
        .modelContainer(for: BrewProfile.self)
}
