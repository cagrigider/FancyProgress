//
//  File.swift
//  
//
//  Created by Cagri Gider on 28.08.2023.
//

import Foundation
import SwiftUI
import Combine

public struct KITTProgress: View {
    var maxBarCount: Int = 10
    var barColor: Color = .white
    var backgroundColor: Color = .black
    var remainingOpacity: CGFloat = 0.5
    var showingDotCount: Int = 5
    var interval: CGFloat = 0.3

    @State private var stepCount: Int = 0
    @State private var step = 1
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>

    public init(maxBarCount: Int = 10,
         barColor: Color = .red,
         backgroundColor: Color = .black,
         remainingOpacity: CGFloat = 0.5,
         showingDotCount: Int = 5,
         interval: CGFloat = 0.3) {
        self.maxBarCount = maxBarCount
        self.barColor = barColor
        self.backgroundColor = backgroundColor
        self.remainingOpacity = remainingOpacity
        self.showingDotCount = showingDotCount
        self.interval = interval
        self.timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }

    public var body: some View {
        GeometryReader { proxy in
            let widthValue = calculateWidth(proxy.size.width)
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    HStack(spacing: 0) {
                        ForEach(0..<maxBarCount, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: widthValue, height: widthValue/2.5)
                                .foregroundColor(barColor.opacity(opacityValue(index)))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .background(Gradient(colors: [
            Color.init(red: 94/255, green: 75/255, blue: 48/255),
            Color.init(red: 20/255, green: 14/255, blue: 9/255),
        ]))
        .onReceive(timer) { input in
            let tempStepCount = stepCount + step
            stepCount = tempStepCount <= maxBarCount ? tempStepCount : 1
            if stepCount == maxBarCount || stepCount == 0 {
                step = stepCount == 0 ? 1 : -1
            }
        }
        .onAppear {
            timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }

    private func calculateWidth(_ totalWidth: CGFloat) -> CGFloat {
        (totalWidth - 32) / CGFloat(maxBarCount)
    }

    private func opacityValue(_ index: Int) -> Double {
        let opacityValue = 1.0 - (abs(Double(stepCount - index)) / Double(showingDotCount)) + remainingOpacity
        return opacityValue > remainingOpacity ? opacityValue : remainingOpacity
    }
}
