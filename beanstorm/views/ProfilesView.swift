import SwiftUI
import SwiftData

let previewProfile = BrewProfile(
    temperature: 88.0,
    name: "Profile # 1",
    controlType: .pressure,
    controlPoints: [
        ControlPoint(id: UUID(), time: 0.0, value: 1.0),
        ControlPoint(id: UUID(), time: 4.0, value: 0.8),
        ControlPoint(id: UUID(), time: 6.0, value: 0.3),
        ControlPoint(id: UUID(), time: 10.0, value: 0.9)
    ]
)

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    let profile: BrewProfile

    @State private var name: String = ""
    @State private var temperature: Double = 80.0
    @State private var controlType: ControlType = .pressure
    @State private var controlPoints: [ControlPoint] = []
    @State private var showingEditor: Bool = false
    
    var changed: Bool {
        profile.name != name ||
        profile.temperature != temperature ||
        profile.controlType != controlType ||
        profile.controlPoints != controlPoints
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Profile Name", text: $name)
                }
                Section(header: Label("Temperature", systemImage: "thermometer")) {
                    VStack {
                        Slider(
                            value: $temperature,
                            in: 0...110,
                            step: 0.1
                        ) {
                            Text("Values from 0 to 110")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("110")
                        }
                        
                        Text("\(String(format: "%.1f", temperature)) °C")
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
                        controlType: $controlType,
                        controlPoints: $controlPoints
                    )
                    .frame(height: 280)
                    Button("Open Profile Editor", systemImage: "square.and.pencil") {
                        showingEditor = true
                    }
                }
                Section(header: Text("Shot Duration")) {
                    Text(String(format: "%.1f", getShotDuration(controlPoints: controlPoints)) + " s")
                        .font(.headline)
                }
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Update") {
                    profile.name = name
                    profile.temperature = temperature
                    profile.controlType = controlType
                    profile.controlPoints = controlPoints
                    dismiss()
                }
                .disabled(!changed)
            }
            .onAppear {
                name = profile.name
                temperature = profile.temperature
                controlType = profile.controlType
                controlPoints = profile.controlPoints
            }
        }
        .sheet(isPresented: $showingEditor) {
            ProfileEditor(
                controlType: $controlType,
                controlPoints: $controlPoints
            )
            .padding()
            .presentationDetents([.fraction(0.8)])
        }
    }
}

#Preview("Edit Brew Profile") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BrewProfile.self, configurations: config)

    return EditProfileView(
        profile: previewProfile
    )
    .modelContainer(container)
}

struct NewBrewProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @State private var showingEditor: Bool = false

    @State private var name: String = ""
    @State private var temperature: Double = 80.0
    @State private var controlType: ControlType = .pressure
    @State private var controlPoints: [ControlPoint] = [
        ControlPoint(id: UUID(), time: 0.0, value: 8.0),
        ControlPoint(id: UUID(), time: 40.0, value: 8.0)
    ]

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
                Section(header: Label("Temperature", systemImage: "thermometer")) {
                    VStack {
                        Slider(
                            value: $temperature,
                            in: 0...110,
                            step: 0.1
                        ) {
                            Text("Values from 0 to 110")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("110")
                        }
                        
                        Text("\(String(format: "%.1f", temperature)) °C")
                            .font(.headline)
                    }
                }

                Section(header: Text("Profile")) {
                    ProfileGraph(
                        controlType: $controlType,
                        controlPoints: $controlPoints
                    )
                    .frame(height: 280)
                    Button("Open Profile Editor", systemImage: "square.and.pencil") {
                        showingEditor = true
                    }
                }
                Section(header: Text("Shot Duration")) {
                    Text(String(format: "%.1f", getShotDuration(controlPoints: controlPoints)) + " s")
                        .font(.headline)
                }
                Button("Create") {
                    let newProfile = BrewProfile(
                        temperature: temperature,
                        name: name,
                        controlType: .pressure,
                        controlPoints: controlPoints
                    )
                    context.insert(newProfile)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
            .navigationTitle("New Brew Profile")
        }
        .sheet(isPresented: $showingEditor) {
            ProfileEditor(
                controlType: $controlType,
                controlPoints: $controlPoints
            )
            .padding()
            .presentationDetents([.fraction(0.8)])
        }
    }
}

#Preview("New Brew Profile") {
    NewBrewProfileView()
}

struct TransferProfileView: View {
    @Binding var brewProfile: BrewProfile
    @StateObject var peripheralModel: BeanstormPeripheralModel

    var body: some View {
        VStack {
            Image(systemName: "network")
                .font(.largeTitle)
                .padding()
            Divider()
            if peripheralModel.brewProfileTransfer == .finished {
                VStack (alignment: .center, spacing: 8) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 48, weight: .regular))
                        .padding(EdgeInsets(top: 20, leading: 5, bottom: 5, trailing: 5))
                    Text("Transfer Finished")
                        .foregroundColor(.white)
                        .font(.callout)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                }
            } else {
                Group {
                    Text("This will transfer the brew profile to the machine via BLE so it can be reproduced. This may take a second.")
                        .multilineTextAlignment(.center)
                    
                    if peripheralModel.brewProfileTransfer != .transfer {
                        Button(action: {
                            peripheralModel.dataService.sendBrewProfile(
                                brewProfile: PBrewProfile(brewProfile)
                            )
                        }) {
                            Text("Transfer Profile")
                            Image(systemName: "network")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if case .failed(let error) = peripheralModel.brewProfileTransfer {
                            Divider()
                            Text(error)
                                .font(.title)
                                .foregroundStyle(.red)
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
            Spacer()
            HStack {
                Section(header: Text("Name")) {
                    Text(brewProfile.name)
                        .font(.headline)
                }
                Section(header: Text("Duration")) {
                    Text(String(format: "%.1f", getShotDuration(controlPoints: brewProfile.controlPoints)) + " s")
                        .font(.headline)
                }
            }
            ProfileGraph(
                controlType: $brewProfile.controlType,
                controlPoints: $brewProfile.controlPoints
            )
            .frame(height: 280)
        }
        .animation(.easeInOut(duration: 0.4), value: peripheralModel.brewProfileTransfer)
        .padding()
    }
}

#Preview("Transfer Profile View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BrewProfile.self, configurations: config)
    
    return TransferProfileView(
        brewProfile: .constant(previewProfile),
        peripheralModel: BeanstormPeripheralModel(
            dataService: MockDataService()
        )
    )
    .modelContainer(container)
}

struct ProfilesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BrewProfile.name) private var profiles: [BrewProfile]
    @EnvironmentObject private var beanstormBLE: BeanstormBLEModel
    
    @State private var showingAddView = false
    @State private var transferProfile: BrewProfile? = nil

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
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    transferProfile = profile
                                } label: {
                                    Label("Upload Profile", systemImage: "network")
                                }
                                .tint(.blue)
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
            .sheet(isPresented: $transferProfile.mappedToBool(), onDismiss: {
                transferProfile = nil
                beanstormBLE.service.connectedPeripheral?.stopSendingBrewProfile()
            }, content: {
                NavigationStack {
                    Group {
                        if(beanstormBLE.isConnected) {
                            if let brewProfile = Binding($transferProfile) {
                                TransferProfileView(
                                    brewProfile: brewProfile,
                                    peripheralModel: .init(
                                        dataService: beanstormBLE.service.connectedPeripheral!
                                    )
                                )
                            }
                        } else {
                            Text("Connect to a machine to transfer a profile!")
                        }
                    }
                    .navigationTitle("Transfer Profile")
                }
                .presentationDetents([.large])
            })
        }
    }
}

#Preview("Profiles View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BrewProfile.self, configurations: config)
    container.mainContext.insert(previewProfile)
    return ProfilesView()
        .modelContainer(container)
        .environmentObject(BeanstormBLEModel())
}
