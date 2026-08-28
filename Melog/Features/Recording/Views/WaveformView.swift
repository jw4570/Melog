//
//  WaveformView.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftUI

struct WaveformView: View {
    let samples: [CGFloat]

    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 3

    var body: some View {
        Canvas { context, size in
            let centerY = size.height / 2

            let maximumCount = Int(
                size.width
                    / (barWidth + barSpacing)
            )

            let visibleSamples = samples
                .suffix(maximumCount)

            let startX =
                size.width
                - CGFloat(visibleSamples.count)
                * (barWidth + barSpacing)

            for (index, sample) in
                visibleSamples.enumerated() {

                let normalizedSample = max(
                    sample,
                    0.04
                )

                let height =
                    max(
                        4,
                        size.height * normalizedSample
                    )

                let x =
                    startX
                    + CGFloat(index)
                    * (barWidth + barSpacing)

                let rectangle = CGRect(
                    x: x,
                    y: centerY - height / 2,
                    width: barWidth,
                    height: height
                )

                let path = Path(
                    roundedRect: rectangle,
                    cornerRadius: barWidth / 2
                )

                context.fill(
                    path,
                    with: .color(.blue)
                )
            }
        }
        .animation(
            .linear(duration: 0.04),
            value: samples
        )
    }
}
