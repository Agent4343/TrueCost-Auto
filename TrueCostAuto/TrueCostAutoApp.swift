import SwiftUI

@main
struct TrueCostAutoApp: App {
    @State private var store = VehicleStore()
    @State private var viewModel = VehicleViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
