import SwiftData
import Foundation

enum ControlType: Int, Codable {
    case pressure
    case flow
}

extension PControlType {
    public init(_ controlType: ControlType) {
        switch(controlType) {
        case .pressure:
            self = .pressure
        case .flow:
            self = .flow
        }
    }
}

struct ControlPoint: Identifiable, Codable, Equatable {
    let id: UUID
    let time: Double
    let value: Double
}

extension PControlPoint {
    public init (_ controlPoint: ControlPoint) {
        self.time = Float(controlPoint.time)
        self.value = Float(controlPoint.value)
    }
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

extension PBrewProfile {
    public init (_ brewProfile: BrewProfile) {
        self.uuid = brewProfile.uuid.uuidString
        self.temperature = Float(brewProfile.temperature)
        self.controlType = PControlType(brewProfile.controlType)
        self.controlPoints = brewProfile.controlPoints.map { return PControlPoint($0) }
    }
}
