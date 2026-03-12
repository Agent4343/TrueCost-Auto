import SwiftUI

@main
struct TrueCostAutoApp: App {
    @State private var store = VehicleStore()
    @State private var viewModel = VehicleViewModel()
    @State private var storeKit = StoreKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(viewModel)
                .environment(storeKit)
                .preferredColorScheme(.dark)
        }
    }
}
