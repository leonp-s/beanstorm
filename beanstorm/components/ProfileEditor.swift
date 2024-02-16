import SwiftUI
import Charts

struct ControlPoint: Identifiable {
    let id: UUID
    let time: Double
    let value: Double
}

struct ProfileGraph: View {
    @State var positions: [ControlPoint]
    
    var body: some View {
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
        }
        .chartXAxisLabel("Time (s)")
        .chartYAxisLabel("Pressure (MPa)")
    }
}

#Preview("Profile Graph") {
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

enum ProfileEditorTool {
    case delete
    case edit
    case add
}

struct ProfileEditor: View {
    @State var positions: [ControlPoint]
    @State var cursorIndex: Int?
    @State private var toolSelection: ProfileEditorTool = .edit
    
    @State var posX: Double = 0.0
    @State var posY: Double = 0.0
    
    @State var initialPos: CGPoint?
    
    @Environment(\.colorScheme) var colorScheme
    
    private var cursorColor: some ShapeStyle {
        return colorScheme == .dark ? .white : .black
    }
    
    func handleTapGesture(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        switch(toolSelection) {
        case .edit, .delete:
            selectControlPoint(
                at: at,
                geometry: geometry,
                proxy: proxy
            )
        case .add:
            addControlPoint(
                at: at,
                geometry: geometry,
                proxy: proxy
            )
        }
    }
    
    func addControlPoint(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        let origin = geometry[proxy.plotFrame!].origin
        
        let time = proxy.value(atX: at.x - origin.x, as: Double.self)!
        let value = proxy.value(atY: at.y - origin.y, as: Double.self)!

        positions.append(
            ControlPoint(
                id: UUID(),
                time: time,
                value: value
            )
        )
        
        positions.sort(by: {a, b in
            a.time > b.time
        })
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
    
    func updateCursor(value: DragGesture.Value, geometry: GeometryProxy, proxy: ChartProxy) {
        let origin = geometry[proxy.plotFrame!].origin
        
        let startTime = proxy.value(atX: value.startLocation.x - origin.x, as: Double.self)!
        let startValue = proxy.value(atY: value.startLocation.y - origin.y, as: Double.self)!
        
        let dragTime = proxy.value(atX: value.location.x - origin.x, as: Double.self)!
        let dragValue = proxy.value(atY: value.location.y - origin.y, as: Double.self)!

        let timeDelta = dragTime - startTime;
        let valueDelta = dragValue - startValue;
        
        if let index = cursorIndex {
            let pos = positions[index]

            if(initialPos == nil) {
                initialPos = CGPoint(x: pos.time, y: pos.value)
            }
            
            var newTime = initialPos!.x + timeDelta
            var newValue = initialPos!.y + valueDelta
            
            if(newTime < 0.0)
            {
                newTime = 0.0
            }
            
            if(newValue < 0.0)
            {
                newValue = 0.0
            }
            
            positions[index] = ControlPoint(
                id: pos.id,
                time: newTime,
                value: newValue
            )
            
            posX = newTime
            posY = newValue
        
        }
    }
    
    private var controlPointEditor: some View {
        VStack {
            HStack {
                Slider(
                    value: $posX,
                    in: 0...10
                )
                .onChange(of: posX) {
                    if let index = cursorIndex {
                        let pos = positions[index]
                        positions[index] = ControlPoint(id: pos.id, time: posX, value: pos.value)
                    }
                }
                Text(String(format: "%.1f", posX))
                    .font(.headline)
            }
        
            HStack {
                Slider(
                    value: $posY,
                    in: 0...1
                )
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
                
                PointMark(
                    x: .value("Time", pos.time),
                    y: .value("Height", pos.value)
                )
                .foregroundStyle(.white)
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
        .chartXAxisLabel("Time (s)")
        .chartYAxisLabel("Pressure (MPa)")
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if(cursorIndex != nil) {
                                    updateCursor(
                                        value: value,
                                        geometry: geometry,
                                        proxy: proxy
                                    )
                                }
                            }
                            .onEnded { _ in
                                initialPos = nil
                            }
                    )
                    .onTapGesture { location in
                        handleTapGesture(
                            at: location,
                            geometry: geometry,
                            proxy: proxy
                        )
                    }
            }
        }
    }
    
    var toolBar: some View {
        HStack {
            Button {
                toolSelection = .delete
            } label: {
                VStack {
                    Image(systemName: "minus.circle")
                        .frame(width: 52, height: 52)
                        .foregroundColor(.red)
                        .background(.bar)
                        .cornerRadius(8)
                    if(toolSelection == .delete) {
                        Circle()
                            .fill(.primary)
                            .frame(width: 8)
                    }
                }
            }
            .animation(.bouncy, value: toolSelection)
            Button {
                toolSelection = .edit
            } label: {
                VStack {
                    Image(systemName: "pencil")
                        .frame(width: 52, height: 52)
                        .foregroundColor(.white)
                        .background(.bar)
                        .cornerRadius(8)
                    if(toolSelection == .edit) {
                        Circle()
                            .fill(.primary)
                            .frame(width: 8)
                    }
                }
            }
            .animation(.bouncy, value: toolSelection)
            Button {
                toolSelection = .add
            } label: {
                VStack {
                    Image(systemName: "plus.circle")
                        .frame(width: 52, height: 52)
                        .foregroundColor(.green)
                        .background(.bar)
                        .cornerRadius(8)
                    if(toolSelection == .add) {
                        Circle()
                            .fill(.primary)
                            .frame(width: 8)
                    }
                }
            }
            .animation(.bouncy, value: toolSelection)
        }
    }
    
    
    var body: some View {
        VStack {
            profileGraph
            if cursorIndex != nil {
                controlPointEditor
            } else {
                toolBar
            }
        }
    }
}

#Preview("Profile Editor") {
    ProfileEditor(
        positions: [
            ControlPoint(id: UUID(), time: 0.0, value: 1.0),
            ControlPoint(id: UUID(), time: 4.0, value: 0.8),
            ControlPoint(id: UUID(), time: 6.0, value: 0.3),
            ControlPoint(id: UUID(), time: 10.0, value: 0.9)
        ]
    )
    .padding()
}
