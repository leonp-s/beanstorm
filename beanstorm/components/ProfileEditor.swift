import SwiftUI
import Charts

private let maxPointValue = 11.0
private let yAxisMax = maxPointValue + 1;
private let timeLabel = "Time (s)"
private let xAxisMin = 1.0;
private let maxShotDuration = 120.0;

func getControlTypeLabel(controlType: ControlType) -> String {
    switch(controlType) {
    case .pressure:
        return "Pressure (MPa)"
    case .flow:
        return "Flow (mls⁻¹)"
    }
}

func getShotDuration(controlPoints: [ControlPoint]) -> Double {
    return controlPoints.max(by: {
        $0.time < $1.time
    })?.time ?? 0.0
}

func getXAxisMax(shotDuration: Double) -> Double {
    return min(max(shotDuration + (shotDuration / 10), xAxisMin), maxShotDuration)
}

struct ControlPointAreaMark: ChartContent {
    @State var controlPoint: ControlPoint
    var body: some ChartContent {
        AreaMark(
            x: .value("Time", controlPoint.time),
            y: .value("Height", controlPoint.value)
        )
        .interpolationMethod(.monotone)
        .foregroundStyle(
                    .linearGradient(
                        colors: [.blue.opacity(0.2), .purple.opacity(0.4)],
                        startPoint: .bottom, endPoint: .top
                    )
                )
        .alignsMarkStylesWithPlotArea()
    }
}

struct ControlPointLineMark: ChartContent {
    @State var controlPoint: ControlPoint
    var body: some ChartContent {
        LineMark(
            x: .value("Time", controlPoint.time),
            y: .value("Height", controlPoint.value)
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

struct ProfileGraphChartModifier : ViewModifier {
    @Binding var xAxisMax: Double
    @Binding var controlType: ControlType

    func body(content: Content) -> some View {
        content
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 12))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 12))
            }
            .chartYScale(domain: 0...yAxisMax)
            .chartXScale(domain: 0...xAxisMax)
            .animation(.smooth, value: xAxisMax)
            .chartXAxisLabel(timeLabel)
            .chartYAxisLabel(
                getControlTypeLabel(
                    controlType: controlType
                )
            )
    }
}

struct ProfileGraph: View {
    @Binding var controlType: ControlType
    @Binding var controlPoints: [ControlPoint]

    @State private var xAxisMax: Double = 0.0
    
    var body: some View {
        Chart {
            ForEach(controlPoints) { controlPoint in
                ControlPointAreaMark(controlPoint: controlPoint)
                ControlPointLineMark(controlPoint: controlPoint)
            }
        }
        .profileGraphChart(
            xAxisMax: $xAxisMax,
            controlType: $controlType
        )
        .onChange(of: controlPoints, initial: true) {
            xAxisMax = getXAxisMax(
                shotDuration: getShotDuration(
                    controlPoints: controlPoints
                )
            )
        }
    }
}

#Preview("Profile Graph") {
    ProfileGraph(
        controlType: .constant(.flow),
        controlPoints: .constant([
            ControlPoint(id: UUID(), time: 0.0, value: 1.0),
            ControlPoint(id: UUID(), time: 4.0, value: 0.8),
            ControlPoint(id: UUID(), time: 6.0, value: 0.3),
            ControlPoint(id: UUID(), time: 10.0, value: 0.9)
        ])
    )
    .padding()
}

enum ProfileEditorTool {
    case drag
    case edit
    case add
}

struct ProfileEditor: View {
    private let maxNumPoints = 20;
    
    @Binding var controlType: ControlType
    @Binding var controlPoints: [ControlPoint]

    @State var controlPointSelection: UUID?
    @State private var toolSelection: ProfileEditorTool = .drag
    
    @State var initialPos: CGPoint?

    @State var posX: Double = 0.0
    @State var posY: Double = 0.0
    
    @State var xAxisMax: Double = 0.0
        
    @Environment(\.colorScheme) var colorScheme
    
    private var cursorColor: some ShapeStyle {
        return colorScheme == .dark ? .white : .black
    }
    
    func handleTapGesture(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        switch(toolSelection) {
        case .edit, .drag:
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
    
    func sortPoints() {
        let firstPoint = controlPoints[0]

        controlPoints.sort(by: {a, b in
            if(a.time < b.time) {
                return true
            }
            else if (a.time == b.time) {
                return a.value > b.value
            }
            
            return false
        })
        
        // Never move the first point so it can always be locked at zero by index, bit hacky
        if let rearrangedPointIndex = controlPoints.firstIndex(where: { controlPoint in
            controlPoint.id == firstPoint.id
        }) {
            
            controlPoints.remove(at: rearrangedPointIndex)
            controlPoints.insert(firstPoint, at: 0)
        }
    }
    
    func addControlPoint(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        if(controlPoints.count >= maxNumPoints) {
            return
        }
        
        let origin = geometry[proxy.plotFrame!].origin
        
        let time = proxy.value(atX: at.x - origin.x, as: Double.self)!
        let value = proxy.value(atY: at.y - origin.y, as: Double.self)!

        let new_point_uuid = UUID()
        
        if(controlPoints.first(where: { controlPoint in controlPoint.time == time }) != nil) {
            return
        }
        
        if(controlPoints.first(where: { controlPoint in controlPoint.value == value }) != nil) {
            return
        }
        
        controlPoints.append(
            ControlPoint(
                id: new_point_uuid,
                time: time,
                value: value
            )
        )
                
        sortPoints()
    }
    
    func selectControlPoint(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
        let origin = geometry[proxy.plotFrame!].origin
        let pos = proxy.value(atX: at.x - origin.x, as: Double.self)!
        let closest = controlPoints
                        .enumerated()
                        .min( by: { abs($0.element.time - pos) <= abs($1.element.time - pos) } )!
        

        let index = closest.offset
        let closest_point = controlPoints[index]

        if controlPointSelection == closest_point.id {
            controlPointSelection = nil
        } else {
            posX = closest_point.time
            posY = closest_point.value
            controlPointSelection = closest_point.id
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
        
        if let pointSelection = controlPointSelection {
            guard let editing_point_index = controlPoints.firstIndex(
                where: { point in
                    point.id == pointSelection
                }
            ) else { return }
            
            let editing_point = controlPoints[editing_point_index]

            if(initialPos == nil) {
                initialPos = CGPoint(x: editing_point.time, y: editing_point.value)
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
            
            if(newTime > maxShotDuration){
                newTime = maxShotDuration
            }
            
            if(editing_point_index == 0)
            {
                newTime = 0.0
            }
            
            if(newValue > maxPointValue){
                newValue = maxPointValue
            }

            controlPoints[editing_point_index] = ControlPoint(
                id: editing_point.id,
                time: newTime,
                value: newValue
            )
            
            posX = newTime
            posY = newValue
        
            sortPoints()
        }
    }
    
    func isFirstPointSelected() -> Bool {
        return controlPoints.first?.id == controlPointSelection
    }
    
    func canRemoveControlPoint() -> Bool {
        return controlPoints.count > 2 && !isFirstPointSelected()
    }
    
    func removeControlPoint() {
        if(!canRemoveControlPoint()) {
            return
        }
        
        if let pointSelection = controlPointSelection {
            guard let editing_point_index = controlPoints.firstIndex(
                where: { point in
                    point.id == pointSelection
                }
            ) else { return }
            
            controlPoints.remove(at: editing_point_index)
            self.controlPointSelection = nil
        }
    }
    
    private func updatePosition() {
        if let pointSelection = controlPointSelection {
            guard let editing_point_index = controlPoints.firstIndex(
                where: { point in
                    point.id == pointSelection
                }
            ) else { return }
            
            let editing_point = controlPoints[editing_point_index]
            
            controlPoints[editing_point_index] = ControlPoint(
                id: editing_point.id,
                time: posX,
                value: posY
            )
            sortPoints()
        }
    }
    
    private var controlPointEditor: some View {
        Form {
            Section(header: Text("Controls")) {
                Text("Time (s), " + String(format: "%.1f", posX))
                    .font(.headline)
                    .listRowSeparator(.hidden)
                Slider(
                    value: $posX,
                    in: 0...maxShotDuration
                )
                .disabled(isFirstPointSelected())
                Text(getControlTypeLabel(controlType: controlType) + String(format: ", %.1f", posY))
                    .font(.headline)
                    .listRowSeparator(.hidden)
                Slider(
                    value: $posY,
                    in: 0...maxPointValue
                )
            }
            Button("Remove Point",
                   systemImage: "trash",
                   role: .destructive
            ) {
                removeControlPoint()
            }
            .disabled(!canRemoveControlPoint())
            
        }
        .onChange(of: posX) {
            updatePosition()
        }
        .onChange(of: posY) {
            updatePosition()
        }
    }

    var profileGraph: some View {
        Chart {
            ForEach(controlPoints) { controlPoint in
                ControlPointAreaMark(controlPoint: controlPoint)
                ControlPointLineMark(controlPoint: controlPoint)
                
                PointMark(
                    x: .value("Time", controlPoint.time),
                    y: .value("Height", controlPoint.value)
                )
                .foregroundStyle(.white)
            }
            if controlPointSelection != nil {
                if let editing_point_index = controlPoints.firstIndex(
                    where: { point in
                        point.id == controlPointSelection
                    }
                ) {
                    let editing_point = controlPoints[editing_point_index]
                    
                    RuleMark(x: .value("Time", editing_point.time))
                        .foregroundStyle(cursorColor)
                    RuleMark(y: .value("Height", editing_point.value))
                        .foregroundStyle(cursorColor)
                    PointMark(x: .value("Time", editing_point.time), y: .value("Height", editing_point.value))
                        .foregroundStyle(cursorColor)
                        .symbol(BasicChartSymbolShape.circle.strokeBorder(lineWidth: 3.0))
                        .symbolSize(250)
                }
            }
        }
        .profileGraphChart(
            xAxisMax: $xAxisMax,
            controlType: $controlType
        )
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if(controlPointSelection != nil) {
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
                toolSelection = .drag
            } label: {
                VStack {
                    Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                        .frame(width: 52, height: 52)
                        .foregroundColor(.white)
                        .background(.bar)
                        .cornerRadius(8)
                    if(toolSelection == .drag) {
                        Circle()
                            .fill(.primary)
                            .frame(width: 8)
                    }
                }
            }
            .animation(.bouncy, value: toolSelection)
            Button {
                if(toolSelection == .edit) {
                    toolSelection = .drag
                } else {
                    toolSelection = .edit
                }
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
                controlPointSelection = nil
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
            if controlPointSelection != nil && toolSelection == .edit {
                controlPointEditor
            }
            toolBar
        }
        .onChange(of: controlPoints, initial: true) {
            xAxisMax = getXAxisMax(
                shotDuration: getShotDuration(
                    controlPoints: controlPoints
                )
            )
        }
    }
}


struct ProfileEditorPreview: View {
    @State var controlPoints: [ControlPoint] = [
        ControlPoint(id: UUID(), time: 0.0, value: 1.0),
        ControlPoint(id: UUID(), time: 4.0, value: 0.8),
        ControlPoint(id: UUID(), time: 6.0, value: 0.3),
        ControlPoint(id: UUID(), time: 10.0, value: 8.0)
    ]
    
    var body: some View {
        ProfileEditor(
            controlType: .constant(.pressure),
            controlPoints: $controlPoints
        )
        .padding()
    }
}

#Preview("Profile Editor") {
    ProfileEditorPreview()
}
