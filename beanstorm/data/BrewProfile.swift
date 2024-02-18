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
    var controlPoints: [ControlPoint]
    
    init(temperature: Double, name: String, controlType: ControlType = .pressure, controlPoints: [ControlPoint]) {
        self.uuid = UUID()
        self.temperature = temperature
        self.name = name
        self.controlType = controlType
        self.controlPoints = controlPoints
    }
}
