import Foundation
import SwiftUI

@Observable
final class VehicleStore {
    private static let storageKey = "truecost_saved_vehicles"
    private static let onboardingKey = "truecost_onboarding_shown"

    var savedVehicles: [Vehicle] = []
    var hasShownOnboarding: Bool = false

    init() {
        load()
        hasShownOnboarding = UserDefaults.standard.bool(forKey: Self.onboardingKey)
    }

    func save(_ vehicle: Vehicle) {
        if let index = savedVehicles.firstIndex(where: { $0.id == vehicle.id }) {
            savedVehicles[index] = vehicle
        } else {
            savedVehicles.append(vehicle)
        }
        persist()
    }

    func delete(_ vehicle: Vehicle) {
        savedVehicles.removeAll { $0.id == vehicle.id }
        persist()
    }

    func deleteAt(offsets: IndexSet) {
        savedVehicles.remove(atOffsets: offsets)
        persist()
    }

    func markOnboardingShown() {
        hasShownOnboarding = true
        UserDefaults.standard.set(true, forKey: Self.onboardingKey)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(savedVehicles) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let vehicles = try? JSONDecoder().decode([Vehicle].self, from: data) else {
            return
        }
        savedVehicles = vehicles
    }
}
