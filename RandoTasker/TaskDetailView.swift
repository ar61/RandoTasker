//
//  TaskDetailView.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/24/22.
//

import SwiftUI

struct TaskDetailView: View {
    var taskStatistic: FetchedResults<TaskStatistics>.Element
    
    private var totalGraphData = [EndTime]()
    
    init(taskStatistic: FetchedResults<TaskStatistics>.Element) {
        self.taskStatistic = taskStatistic
        totalData()
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                CustomText(taskStatistic.value!)
                    .font(.largeTitle)
            }
            CustomText("Timeline of total times done in last 30 days:")
                .font(.subheadline)
            LineChart(dataPoints: totalGraphData)
            if taskStatistic.consecutive > 1 {
                CustomText("Good job, you did this task consecutively \(taskStatistic.consecutive) times since \(taskStatistic.startdate!.formatted(date: .abbreviated, time: .omitted))!")
                    .font(.subheadline)
            }
        }
        .padding()
    }
    
    mutating func totalData() {
        if let array = taskStatistic.endHrfor30Days?.split(separator: "|") {
            for i in array {
                // 02/25,09:44
                let sMonthDate = i.split(separator: ",")[0].split(separator: "/")
                let sHour = i.split(separator: ",")[1].split(separator: ":")[0]
                let sMins = i.split(separator: ",")[1].split(separator: ":")[1]
                var endTime = EndTime(date: 0, month: 0, hour: 0, mins: 0)
                if let n = NumberFormatter().number(from: String(sMonthDate[0])),
                   let m = NumberFormatter().number(from: String(sMonthDate[1])),
                   let o = NumberFormatter().number(from: String(sHour)),
                   let p = NumberFormatter().number(from: String(sMins)) {
                    endTime.month = Int(truncating: n)
                    endTime.date = Int(truncating: m)
                    endTime.hour = Int(truncating: o)
                    endTime.mins = Int(truncating: p)
                    totalGraphData.append(endTime)
                }
            }
        }
    }
}

struct LineGraph: Shape {
    var dataPoints: [CGFloat]
    
    func path(in rect: CGRect) -> Path {
        
        func point(ix: Int) -> CGPoint {
            let point = dataPoints[ix]
            let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
            let y = (point-1) * rect.height
            return CGPoint(x: x, y: y)
            
        }
        
        return Path { p in
            guard dataPoints.count > 1 else {return}
            let start = dataPoints[0]
            p.move(to: CGPoint(x: 0, y: (1-start)*rect.height))
            for idx in dataPoints.indices {
                p.addLine(to: point(ix: idx))
            }
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(taskStatistic: FetchedResults<TaskStatistics>.Element())
    }
}
