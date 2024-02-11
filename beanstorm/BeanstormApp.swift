import SwiftUI

@main
struct BeanstormApp: App {
    @StateObject private var dataController = DataController()
    @StateObject private var beanstormBLE = BeanstormBLE()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(beanstormBLE)
        }
    }
}
