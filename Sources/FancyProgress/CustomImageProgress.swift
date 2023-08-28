//
//  File.swift
//  
//
//  Created by Cagri Gider on 28.08.2023.
//

import Foundation
import SwiftUI
import Combine

public struct CustomImageProgress: View {
    var progressImage: Image
    var widthHeightRatio: CGFloat
    var maxBarCount: Int
    var spaceBetweenBars: CGFloat
    var barColor: Color
    var backgroundColor: Color
    var interval: CGFloat

    @State private var stepCount: Int = 4
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>

    /// Progress view with given image
    /// - Parameters:
    ///   - progressImage: The image to show while continuing.
    ///   - widthHeightRatio: Width / Height ratio of the given image.
    ///   - maxBarCount: Number of bars.
    ///   - spaceBetweenBars: Spacing amount between each bars.
    ///   - barColor: Color of progress bars.
    ///   - backgroundColor: The color of the area on which the bars stand.
    ///   - interval: The date range over which the view should progress.
    public init(progressImage: Image,
         widthHeightRatio: CGFloat = 1.0,
         maxBarCount: Int = 10,
         spaceBetweenBars: CGFloat = 4.0,
         barColor: Color = .white,
         backgroundColor: Color = .black,
         interval: CGFloat = 0.3) {
        self.progressImage = progressImage
        self.widthHeightRatio = widthHeightRatio
        self.maxBarCount = maxBarCount
        self.spaceBetweenBars = spaceBetweenBars
        self.barColor = barColor
        self.backgroundColor = backgroundColor
        self.interval = interval
        self.timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }

    public var body: some View {
        GeometryReader { proxy in
            let widthValue = calculateWidth(proxy.size.width)
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    HStack(spacing: spaceBetweenBars) {
                        ForEach(0..<stepCount, id: \.self) { i in
                            progressImage
                                .resizable()
                                .frame(width: widthValue, height: widthValue / widthHeightRatio)
                                .foregroundColor(barColor)
                                .tint(.white)
                        }
                    }
                    if stepCount < maxBarCount {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .onReceive(timer) { input in
            let tempStepCount = stepCount + 1
            stepCount = tempStepCount <= maxBarCount ? tempStepCount : 1
        }
        .onAppear {
            timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }

    private func calculateWidth(_ totalWidth: CGFloat) -> Double {
        let totalSpaceWidth = spaceBetweenBars * CGFloat(maxBarCount - 1)
        return (totalWidth - totalSpaceWidth - 32) / CGFloat(maxBarCount)
    }
}
