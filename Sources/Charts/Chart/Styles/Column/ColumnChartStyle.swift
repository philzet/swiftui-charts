import SwiftUI
import Shapes

public class SharedState: ObservableObject {
    @Published var activeText: String = ""
    
    public init() {}
}

@available(iOS 13.4, *)
public struct ColumnChartStyle<Column: View>: ChartStyle {
    private let column: Column
    private let spacing: CGFloat
//    public let state: SharedState = .init()
    
    @State private var state = SharedState()
    
    public func makeBody(configuration: Self.Configuration) -> some View {

        let strings: [String] = configuration.dataLabels
        let data: [ColumnData] = configuration.dataMatrix
            .map {
                $0.reduce(0, +)
        }
            .enumerated()
        .map { ColumnData(id: $0.offset, data: $0.element, label: strings[$0.offset]) }
        
        return GeometryReader { geometry in
            self.columnChart(in: geometry, data: data)
        }
    }
    
    private func columnChart(in geometry: GeometryProxy, data: [ColumnData]) -> some View {
        let columnWidth = (geometry.size.width - (CGFloat(data.count - 1) * spacing)) / CGFloat(data.count)
    
        return ZStack(alignment: .bottomLeading) {
            ForEach(data) { element in
                self.column
                    .alignmentGuide(.leading, computeValue: { _ in self.leadingAlignmentGuide(for: element.id, in: geometry.size.width, dataCount: data.count) })
                    .alignmentGuide(.bottom, computeValue: { _ in self.columnHeight(data: element.data, in: geometry.size.height) })
                    .frame(width: columnWidth, height: self.columnHeight(data: element.data, in: geometry.size.height))
                    .onHover { (hover) in
                        if hover {
                            self.state.activeText = element.label
                        }
                }
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
    }
    
    private func columnHeight(data: CGFloat, in availableHeight: CGFloat) -> CGFloat {
        availableHeight * data
    }
    
    private func leadingAlignmentGuide(for index: Int, in availableWidth: CGFloat, dataCount: Int) -> CGFloat {
        let columnWidth = (availableWidth - (CGFloat(dataCount - 1) * spacing)) / CGFloat(dataCount)
        return (CGFloat(index) * columnWidth) + (CGFloat(index - 1) * spacing)
    }
    
    public init(column: Column, spacing: CGFloat = 8) {
        self.column = column
        self.spacing = spacing
    }
}

struct ColumnData: Identifiable {
    let id: Int
    let data: CGFloat
    let label: String
}

public struct DefaultColumnView: View {
    public var body: some View {
        Rectangle().foregroundColor(.accentColor)
    }
}

@available(iOS 13.4, *)
public extension ColumnChartStyle where Column == DefaultColumnView {
    init(spacing: CGFloat = 8) {
        self.init(column: DefaultColumnView(), spacing: spacing)
    }
}
