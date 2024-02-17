import SwiftData
import Foundation

enum ControlType: Int, Codable {
    case pressure
    case flow
}

struct ControlPoint: Identifiable, Codable, Equatable {
    let id: UUID
    let time: Double
    let value: Double
}

@Model 
class BrewProfile {
    var uuid: UUID
    var temperature: Double
    var name: String
    var controlType: ControlType
    var duration: Double
    var controlPoints: [ControlPoint]
    
    init(temperature: Double, name: String, duration: Double, controlType: ControlType = .pressure, controlPoints: [ControlPoint]) {
        self.uuid = UUID()
        self.temperature = temperature
        self.name = name
        self.duration = duration
        self.controlType = controlType
        self.controlPoints = controlPoints
    }
}
