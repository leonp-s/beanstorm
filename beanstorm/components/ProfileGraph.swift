import SwiftUI
import Charts

struct ControlPoint: Identifiable {
    let id: UUID
    let time: Double
    let value: Double
}

struct ProfileGraph: View {
    @State var positions: [ControlPoint]
    @State var cursorIndex: Int?
    
    @State var posX: Double = 0.0
    @State var posY: Double = 0.0
    
    @Environment(\.colorScheme) var colorScheme
    
    private var cursorColor: some ShapeStyle {
        return colorScheme == .dark ? .white : .black
    }
    
    func selectControlPoint(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        let origin = geometry[proxy.plotFrame!].origin
        let pos = proxy.value(atX: at.x - origin.x, as: Double.self)!
        let closest = positions
                        .enumerated()
                        .min( by: { abs($0.element.time - pos) < abs($1.element.time - pos) } )!
        

        let index = closest.offset
        if cursorIndex == index {
            cursorIndex = nil
        } else {
            let pos = positions[index]
            posX = pos.time
            posY = pos.value
            cursorIndex = index
        }
    }
    
    func updateCursor(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        let origin = geometry[proxy.plotFrame!].origin

        let time = proxy.value(atX: at.x - origin.x, as: Double.self)!
        let value = proxy.value(atY: at.y - origin.y, as: Double.self)!

        if let index = cursorIndex {
            let pos = positions[index]
            positions[index] = ControlPoint(id: pos.id, time: time, value: value)
            posX = time
            posY = value
        }
    }
    
    private var controlPointEditor: some View {
        Group {
            if cursorIndex != nil {
                Form {
                    Section(header: Text("Time")) {
                        VStack {
                            Slider(
                                value: $posX,
                                in: 0...10
                            ) {
                                Text("Values from 0 to 10")
                            } minimumValueLabel: {
                                Text("0")
                            } maximumValueLabel: {
                                Text("10")
                            }
                            .onChange(of: posX) {
                                if let index = cursorIndex {
                                    let pos = positions[index]
                                    positions[index] = ControlPoint(id: pos.id, time: posX, value: pos.value)
                                }
                            }
                            
                            Text(String(format: "%.1f", posX))
                                .font(.headline)
                        }
                    }
                    
                    Section(header: Text("Value")) {
                        VStack {
                            Slider(
                                value: $posY,
                                in: 0...1
                            ) {
                                Text("Values from 0 to 1")
                            } minimumValueLabel: {
                                Text("0")
                            } maximumValueLabel: {
                                Text("1")
                            }
                            .onChange(of: posY) {
                                if let index = cursorIndex {
                                    let pos = positions[index]
                                    positions[index] = ControlPoint(id: pos.id, time: pos.time, value: posY)
                                }
                            }
                            
                            Text(String(format: "%.1f", posY))
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .animation(.spring, value: cursorIndex)
    }
    
    var profileGraph: some View {
        Chart {
            ForEach(positions) { pos in
                AreaMark(
                    x: .value("Time", pos.time),
                    y: .value("Height", pos.value)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                            .linearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.4)],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                .alignsMarkStylesWithPlotArea()

                LineMark(
                    x: .value("Time", pos.time),
                    y: .value("Height", pos.value)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .bottom, endPoint: .top
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 4))
                .alignsMarkStylesWithPlotArea()
            }
            if let index = cursorIndex {
                let position = positions[index]
                RuleMark(x: .value("Time", position.time))
                    .foregroundStyle(cursorColor)
                RuleMark(y: .value("Height", position.value))
                    .foregroundStyle(cursorColor)
                PointMark(x: .value("Time", position.time), y: .value("Height", position.value))
                    .foregroundStyle(cursorColor)
                    .symbol(BasicChartSymbolShape.circle.strokeBorder(lineWidth: 3.0))
                    .symbolSize(250)
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture().onChanged { value in
                            if(cursorIndex != nil) {
                                updateCursor(
                                    at: value.location,
                                    geometry: geometry,
                                    proxy: proxy
                                )
                            }
                        }
                    )
                    .onTapGesture { location in
                        selectControlPoint(
                            at: location,
                            geometry: geometry,
                            proxy: proxy
                        )
                    }
            }
        }
    }
    
    var body: some View {
        VStack {
            profileGraph
            controlPointEditor
        }
    }
}

#Preview {
    ProfileGraph(
        positions: [
            ControlPoint(id: UUID(), time: 0.0, value: 1.0),
            ControlPoint(id: UUID(), time: 4.0, value: 0.8),
            ControlPoint(id: UUID(), time: 6.0, value: 0.3),
            ControlPoint(id: UUID(), time: 10.0, value: 0.9)
        ]
    )
    .padding()
}

