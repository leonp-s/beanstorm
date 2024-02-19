import SwiftUI
import Charts

struct BrewData: Codable, Identifiable, Equatable {
    let id: UUID
    let shotTime: Double
    let temperature: Double
    let pressure: Double
    let flow: Double
}

struct BrewGraphOverlay: View {
    let data: [BrewData]
    let maxData: Int
    
    let minValue: Double = 0
    let maxValue: Double = 1
    
    @State private var timestep = 0

    func yGraphPosition(_ dataItem: Double, in size: CGSize) -> Double {
        let proportion = (dataItem - minValue) / (maxValue - minValue)
        let yValue: Double = size.height - proportion * size.height
        return yValue
    }

    func xGraphPosition(_ index: Int, in size: CGSize) -> Double {
        let increment = size.width / Double(maxData)
        let base = Double(maxData - data.count) * increment
        return base + Double(index) * increment
    }
    
    private let lineWidth = 4.0
    
    func strokeTemperaturePath(context: GraphicsContext, size: CGSize) {
        var temperaturePath = Path()
        temperaturePath.move(
            to: CGPoint(
                x: self.xGraphPosition(0, in: size),
                y: yGraphPosition(data[0].temperature, in: size))
        )
        
        for (index, dataPoint) in data.dropFirst().enumerated() {
            temperaturePath.addLine(
                to: CGPoint(
                    x: self.xGraphPosition(index, in: size),
                    y: self.yGraphPosition(dataPoint.temperature, in: size))
            )
        }

        context.stroke(temperaturePath, with: .color(.green), lineWidth: lineWidth)
    }
    
    var body: some View {
        Canvas { context, size in
            guard !data.isEmpty else { return }

            strokeTemperaturePath(
                context: context,
                size: size
            )
            
//            var flowPath = Path()
//            flowPath.move(to: CGPoint(x: self.xGraphPosition(0, in: size), y: yGraphPosition(data[0].flow, in: size)))
//            for (index, dataPoint) in data.dropFirst().enumerated() {
//                flowPath.addLine(to: CGPoint(x: self.xGraphPosition(index, in: size), y: self.yGraphPosition(dataPoint.flow, in: size)))
//            }
//            context.stroke(flowPath, with: .color(.yellow), lineWidth: lineWidth)
//
//            var pressurePath = Path()
//            pressurePath.move(to: CGPoint(x: self.xGraphPosition(0, in: size), y: yGraphPosition(data[0].pressure, in: size)))
//            for (index, dataPoint) in data.dropFirst().enumerated() {
//                pressurePath.addLine(to: CGPoint(x: self.xGraphPosition(index, in: size), y: self.yGraphPosition(dataPoint.pressure, in: size)))
//            }
//            context.stroke(pressurePath, with: .color(.blue), lineWidth: lineWidth)
        }
        .onChange(of: data, initial: false) { _,_  in
            timestep += 1
        }
    }
}


struct BrewGraph: View {
    @Binding var data: [BrewData]

    var body: some View {
        VStack(alignment: .leading) {
            let strideBy: Double = 8

            let temperatureMin = 64.0
            let temperatureMax = 110.0

            let pressureMin = 0.0
            let pressureMax = 12.0
            
            Chart(data) { _ in }
            .chartForegroundStyleScale([
                "Pressure": .blue,
                "Temperature": .green,
                "Flow": .yellow,
            ])
            .chartYScale(domain: 0...1)
            .chartXScale(domain: 0...40)
            .chartYAxis {
                let defaultStride = Array(stride(from: 0, to: 1, by: 1.0 / strideBy))
                let temperatureStride = Array(stride(from: temperatureMin,
                                               through: temperatureMax,
                                               by: (temperatureMax - temperatureMin) / strideBy))
                AxisMarks(position: .trailing, values: defaultStride) { axis in
                    AxisGridLine()
                    let value = temperatureStride[axis.index]
                    AxisValueLabel(centered: false) {
                        VStack(alignment: .leading) {
                            Text("\(String(format: "%.2F", value))")
                            Text("(°C)")
                        }
                    }
                }

                let pressureStride = Array(stride(from: pressureMin,
                                                     through: pressureMax,
                                                     by: (pressureMax - pressureMin) / strideBy))
                AxisMarks(position: .leading, values: defaultStride) { axis in
                    AxisGridLine()
                    let value = pressureStride[axis.index]
                    AxisValueLabel(centered: false) {
                        VStack(alignment: .trailing) {
                            Text("\(String(format: "%.2F", value))")
                            Text("(MPa, mls⁻¹)")
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    if let plotContainerFrame = proxy.plotContainerFrame {
                        let frame = geometry[plotContainerFrame]
                        BrewGraphOverlay(
                            data: data,
                            maxData: 800
                        )
                        .frame(
                            width: frame.width,
                            height: frame.height
                        )
                        .offset(
                            x: frame.origin.x,
                            y: frame.origin.y
                        )
                    }
                }
            }
        }
    }
}

class BrewGraphPreviewModel : ObservableObject {
    @Published var brewData: [BrewData] = []
    var timer: Timer?
    var shotTime = 0
    
    init() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.01,
            repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                self.brewData.append(BrewData(
                    id: UUID(),
                    shotTime: Double(self.shotTime),
                    temperature: ((sin(Double(self.shotTime) * 0.01) + 1.0) / 2.0) * 0.2 + 0.8,
                    pressure: ((sin(Double(self.shotTime) * 0.02) + 1.0) / 2.0) * 0.1 + 0.2,
                    flow: ((sin(Double(self.shotTime) * 0.04) + 1.0) / 2.0) * 0.4 + 0.2
                ))
                
                shotTime += 1
                
                if(self.brewData.count > 1000) {
                    brewData.removeFirst()
                }
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
