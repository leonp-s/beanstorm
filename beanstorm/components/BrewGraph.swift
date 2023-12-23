import SwiftUI
import Charts

struct BrewData: Codable, Identifiable {
    let id: UUID
    let shotTime: Double
    let temperature: Double
    let pressure: Double
}

struct BrewGraph: View {
    @Binding var data: [BrewData]

    var body: some View {
        VStack(alignment: .leading) {
            let strideBy: Double = 8

            let temperatureMin = 80.0
            let temperatureMax = 110.0
            let pressureMin = 0.0
            let pressureMax = 12.0
            
            Chart(data) { item in
                LineMark(
                    x: .value("Time", item.shotTime),
                    y: .value("Temperature",
                              Rescale(
                                from: (temperatureMin, temperatureMax),
                                to: (0, 1)
                              ).rescale(item.temperature)
                             )
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(by: .value("Value", "Temperature"))

                LineMark(
                    x: .value("Time", item.shotTime),
                    y: .value("Pressure",
                              Rescale(
                                from: (pressureMin, pressureMax),
                                to: (0, 1)
                              ).rescale(item.pressure)
                             )
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(by: .value("Value", "Pressure"))
            }
            .chartForegroundStyleScale([
                "Pressure": .blue,
                "Temperature": .green,
            ])
            .chartXScale(domain: 0...40)
            .chartYAxis {
                let defaultStride = Array(stride(from: 0, to: 1, by: 1.0 / strideBy))
                let costsStride = Array(stride(from: temperatureMin,
                                               through: temperatureMax,
                                               by: (temperatureMax - temperatureMin) / strideBy))
                AxisMarks(position: .trailing, values: defaultStride) { axis in
                    AxisGridLine()
                    let value = costsStride[axis.index]
                    AxisValueLabel("\(String(format: "%.2F", value)) (°C)", centered: false)
                }

                let consumptionStride = Array(stride(from: pressureMin,
                                                     through: pressureMax,
                                                     by: (pressureMax - pressureMin) / strideBy))
                AxisMarks(position: .leading, values: defaultStride) { axis in
                    AxisGridLine()
                    let value = consumptionStride[axis.index]
                    AxisValueLabel("\(String(format: "%.2F", value)) (MPa)", centered: false)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

class BrewGraphPreviewModel : ObservableObject {
    @Published var brewData: [BrewData] = []
    var timer: Timer?
    var shotTime = 0
    
    init() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.4,
            repeats: true) { [weak self] _ in
                guard let self = self else { return }
            
                if shotTime == 0 {
                    self.brewData = []
                }
                
                self.brewData.append(BrewData(
                    id: UUID(),
                    shotTime: Double(self.shotTime),
                    temperature: 4 * sin(Double(self.shotTime)).magnitude + 90,
                    pressure: 3 * sin(Double(self.shotTime) * 2.0).magnitude
                ))
                
                shotTime = (shotTime + 1) % 40
            }
    }
}

struct Container: View {
    @StateObject var viewModel = BrewGraphPreviewModel()
    var body: some View {
      BrewGraph(data: $viewModel.brewData)
            .padding()
    }
}

#Preview {
    Container()
}
