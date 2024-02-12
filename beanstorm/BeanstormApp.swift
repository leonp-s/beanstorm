import SwiftUI

@main
struct BeanstormApp: App {
    @StateObject private var dataController = DataController()
    @StateObject private var beanstormBLE = BeanstormBLEModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(beanstormBLE)
        }
    }
}
