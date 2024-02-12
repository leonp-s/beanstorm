import SwiftUI
import Charts

struct ChartPosition: Identifiable {
    let id: UUID
    let x: Double
    let y: Double
}

struct ProfileGraph: View {
    @State var positions: [ChartPosition]
    @State var cursorIndex: Int?
    
    @State var posX: Double = 0.0
    @State var posY: Double = 0.0
    
    @Environment(\.colorScheme) var colorScheme
    
    private var cursorColor: some ShapeStyle {
        return colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(positions) { pos in
                    AreaMark(
                        x: .value("Time", pos.x),
                        y: .value("Height", pos.y)
                    )
                }
                if let index = cursorIndex {
                    let position = positions[index]
                    RuleMark(x: .value("Time", position.x))
                        .foregroundStyle(cursorColor)
                    RuleMark(y: .value("Height", position.y))
                        .foregroundStyle(cursorColor)
                    PointMark(x: .value("Time", position.x), y: .value("Height", position.y))
                        .foregroundStyle(cursorColor)
                        .symbol(BasicChartSymbolShape.circle.strokeBorder(lineWidth: 3.0))
                        .symbolSize(250)
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(DragGesture().onChanged { value in updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy) })
                        .onTapGesture { location in updateCursorPosition(at: location, geometry: geometry, proxy: proxy) }
                }
            }
                
            Group {
                if cursorIndex != nil {
                    
                    Slider(
                        value: $posX,
                        in: 0...10
                    ) {
                        Text("Speed")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("10")
                    }
                    .onChange(of: posX) {
                        if let index = cursorIndex {
                            var poss = positions
                            let pos = poss[index]
                            positions[index] = ChartPosition(id: pos.id, x: posX, y: pos.y)
                        }
                    }
                    Slider(
                        value: $posY,
                        in: 0...1
                    ) {
                        Text("Speed")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("1")
                    }
                    .onChange(of: posY) {
                        if let index = cursorIndex {
                            var poss = positions
                            let pos = poss[index]
                            positions[index] = ChartPosition(id: pos.id, x: pos.x, y: posY)
                        }
                    }
                }
            }
            .animation(.spring, value: cursorIndex)
        }
        .padding()
    }
       
      func updateCursorPosition(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
          let data = positions
          let origin = geometry[proxy.plotAreaFrame].origin
          let pos = proxy.value(atX: at.x - origin.x, as: Double.self)
          let firstGreater = data.lastIndex(where: { $0.x < pos! })
          
          if let index = firstGreater {
              if cursorIndex == index {
                  cursorIndex = nil
              } else {
                  let pos = positions[index]
                  posX = pos.x
                  posY = pos.y
                  cursorIndex = index
              }
          }
      }
}

#Preview {
    ProfileGraph(positions: [ChartPosition(id: UUID(), x: 0.0, y: 1.0),
                    ChartPosition(id: UUID(), x: 4.0, y: 0.8),
                    ChartPosition(id: UUID(), x: 6.0, y: 0.3),
                    ChartPosition(id: UUID(), x: 10.0, y: 0.9)])
}
