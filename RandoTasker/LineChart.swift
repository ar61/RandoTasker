//
//  LineChart.swift
//  RandoTasker
//
//  Created by Abhinav Rathod on 2/25/22.
//

import SwiftUI

struct LineChart: View {
    var dataPointsMap: [Int: [EndTime]] // 02/25,09
    
    private var dataPointsArray: [EndTime]
    private var widthPerIndex = [Int: CGFloat]()
    private var overallWidth: CGFloat = 0
    private let sizePerLine = 50
    
    init(dataPoints: [EndTime]) {
        self.dataPointsArray = dataPoints
        dataPointsMap = [Int: [EndTime]]()
        var j = 0
        var et = [EndTime]()
        for (i,v) in dataPoints.enumerated() {
            et.append(v)
            if (i+1)%10 == 0 {
                self.dataPointsMap[j] = et
                self.widthPerIndex[j] = CGFloat(et.count*self.sizePerLine)
                self.overallWidth += self.widthPerIndex[j]!
                j = j + 1
                et.removeAll()
            }
        }
        if !et.isEmpty {
            self.dataPointsMap[j] = et
            self.widthPerIndex[j] = CGFloat(et.count*self.sizePerLine)
            self.overallWidth += self.widthPerIndex[j]!
        }
    }
    
    let tempGradient = Gradient(colors: [
        .red,
        .orange,
        .blue,
        .purple,
    ])
    
    func getAMPM(hr: Int) -> String {
        if hr >= 12 {return "p"}
        return "a"
    }
    
    func getAMPMHour(hr: Int) -> String {
        var sHr = String(hr)
        if hr > 12 {
            sHr = String(hr - 12)
        }
        return sHr + ":"
    }
    
    func calculateXY(sz: CGSize, key: Int, idx: Int) -> CGPoint {
        let width = sz.width / CGFloat(self.dataPointsMap[key]!.count+1)
        let height = sz.height / CGFloat(24)
        let xOffset = width * CGFloat(idx+1)
        let yOffset = height * CGFloat(self.dataPointsMap[key]![idx].hour)
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(self.dataPointsMap.keys.sorted(), id:\.self) { key in
                    GeometryReader { fullView in
                        ForEach(self.dataPointsMap[key]!.indices, id:\.self) { index in
                            Path { p in
                                let pt = calculateXY(sz: fullView.size, key: key, idx: index)
                                p.move(to: .init(x: pt.x, y: fullView.size.height - 15))
                                p.addLine(to: .init(x: pt.x, y: fullView.size.height - 15 - pt.y))
                            }
                            .stroke(LinearGradient(
                                gradient: self.tempGradient,
                                startPoint: .init(x: 0.0, y: 1.0),
                                endPoint: .init(x: 0.0, y: 0.0)))
                        }
                        ForEach(self.dataPointsMap[key]!.indices, id:\.self) { index in
                            let pt = calculateXY(sz: fullView.size, key: key, idx: index)
                            let et = self.dataPointsMap[key]!
                            let hr = getAMPMHour(hr: et[index].hour)
                            let ampm = getAMPM(hr: et[index].hour)
                            let mins = hr + String(et[index].mins)
                            let time = mins + ampm
                            CustomText(time)
                                .offset(x: pt.x+2, y: fullView.size.height - 18 - pt.y)
                                .font(.system(size:10))
                        }
                        ForEach(self.dataPointsMap[key]!.indices, id:\.self) { index in
                            let et = self.dataPointsMap[key]!
                            let pt = calculateXY(sz: fullView.size, key: key, idx: index)
                            let m = String(et[index].month)
                            let mSlash = m + "/"
                            let md = mSlash + String(et[index].date)
                            CustomText(md)
                                .offset(x: pt.x - 2, y: fullView.size.height - 10)
                                .font(.system(size:10))
                        }
                    }
                    .frame(width: widthPerIndex[key])
                    
                }
            }
        }
    }
}


struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        let et = [ EndTime(date: 25, month: 2, hour: 10, mins: 3),
            EndTime(date: 26, month: 2, hour: 20, mins: 32),
            EndTime(date: 27, month: 2, hour: 13, mins: 44),
            EndTime(date: 28, month: 2, hour: 10, mins: 15),
            EndTime(date: 1, month: 3, hour: 22, mins: 22),
            EndTime(date: 10, month: 3, hour: 12, mins: 59),
            EndTime(date: 11, month: 3, hour: 10, mins: 3),
            EndTime(date: 12, month: 3, hour: 20, mins: 32),
            EndTime(date: 14, month: 3, hour: 13, mins: 44),
            EndTime(date: 15, month: 3, hour: 10, mins: 15),
            EndTime(date: 16, month: 3, hour: 10, mins: 15),
            EndTime(date: 17, month: 3, hour: 10, mins: 15),
            EndTime(date: 18, month: 3, hour: 10, mins: 15)
        ]
        LineChart(dataPoints: et)
    }
}
