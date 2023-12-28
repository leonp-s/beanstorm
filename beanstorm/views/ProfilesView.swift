import SwiftUI

struct EditProfileView: View {
    var profile: FetchedResults<Profile>.Element
    
    var body: some View {
        Text("Edit Profile")
    }
}


struct ProfilesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: []) var profiles: FetchedResults<Profile>
    @State private var showingAddView = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    ForEach(profiles) { profile in
                        NavigationLink(destination: EditProfileView(profile: profile)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(profile.name!)
                                    .bold()
                            }
                        }
                    }
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
                Text("Add Profile")
            }
        }
    }
}

#Preview {
    ProfilesView()
}
