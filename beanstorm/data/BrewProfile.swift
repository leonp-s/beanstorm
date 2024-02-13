import SwiftData
import Foundation

enum ControlType: Codable {
    case pressure, flow
}

@Model final class ControlPoint {
    var uuid: UUID
    var pressure: Double
    var flow: Double
    var time: Double
    
    init(pressure: Double, flow: Double, time: Double) {
        self.uuid = UUID()
        self.pressure = pressure
        self.flow = flow
        self.time = time
    }
}

@Model final class BrewProfile {
    var uuid: UUID
    var temperature: Double
    var name: String
    var controlType: ControlType
    var duration: Double
    
    init(temperature: Double, name: String, duration: Double, controlType: ControlType = .pressure) {
        self.uuid = UUID()
        self.temperature = temperature
        self.name = name
        self.duration = duration
        self.controlType = controlType
    }
}
