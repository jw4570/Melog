//
//  MapView.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

import SwiftData
import SwiftUI

@MainActor
struct RecordView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \RecordingFolder.name)
    private var folders: [RecordingFolder]

    @State private var selectedFolderID: UUID?
    @State private var selectedVisualizationPage = 0

    @State
    private var viewModel =
        RecordingViewModel()

    var body: some View {
        VStack(spacing: 24) {
            folderPicker
            recordingCard

            Spacer()
        }
        .padding(.top)
        .navigationTitle("허밍")
        .navigationBarTitleDisplayMode(.large)
        .sheet(
            item: Binding(
                get: {
                    viewModel.savedRecord
                },
                set: { record in
                    if record == nil {
                        viewModel.clearSavedRecord()
                    }
                }
            )
        ) { record in
            NavigationStack {
                RecordingDetailView(record: record)
                    .toolbar {
                        ToolbarItem(
                            placement: .confirmationAction
                        ) {
                            Button("완료") {
                                viewModel.clearSavedRecord()
                            }
                        }
                    }
            }
        }
        .alert(
            "녹음 오류",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(
                viewModel.errorMessage ?? ""
            )
        }
    }

    private var selectedFolder: RecordingFolder? {
        folders.first { $0.id == selectedFolderID }
    }

    private var folderPicker: some View {
        Picker("저장 위치", selection: $selectedFolderID) {
            Text("Melog 루트").tag(UUID?.none)

            ForEach(folders) { folder in
                Text(folder.name).tag(Optional(folder.id))
            }
        }
        .pickerStyle(.menu)
        .disabled(viewModel.isRecording)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recordingCard: some View {
        ZStack {
            TabView(selection: $selectedVisualizationPage) {
                WaveformPitchCard(
                    rawPitch: viewModel.detectedPitch,
                    processedPitch: viewModel.processedPitch,
                    samples: viewModel.samples,
                    isRecording: viewModel.isRecording
                )
                .tag(0)

                PitchHeightCard(
                    rawPitch: viewModel.detectedPitch,
                    processedPitch: viewModel.processedPitch,
                    rawPitchSamples: viewModel.pitchHeightSamples,
                    processedPitchSamples: viewModel.processedPitchSamples,
                    isRecording: viewModel.isRecording
                )
                .tag(1)
            }
            .tabViewStyle(
                .page(indexDisplayMode: .never)
            )

            VStack(spacing: 4) {
                Text(
                    viewModel.isRecording
                        ? "녹음 중"
                        : "멜로디를 들려주세요"
                )
                .font(.title2.bold())

                Text(
                    formattedTime(
                        viewModel.elapsedTime
                    )
                )
                .font(
                    .system(
                        size: 40,
                        weight: .medium,
                        design: .monospaced
                    )
                )
            }
            .padding(.top, 24)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .allowsHitTesting(false)

            VStack {
                Spacer()

                HStack(spacing: 6) {
                    ForEach(0..<2, id: \.self) { index in
                        Capsule()
                            .fill(
                                selectedVisualizationPage == index
                                    ? Color.primary
                                    : Color.secondary.opacity(0.35)
                            )
                            .frame(
                                width: selectedVisualizationPage == index
                                    ? 18
                                    : 6,
                                height: 6
                            )
                    }
                }
                .animation(
                    .easeInOut(duration: 0.2),
                    value: selectedVisualizationPage
                )

                RecordButton(
                    isRecording: viewModel.isRecording
                ) {
                    Task { @MainActor in
                        await viewModel.toggleRecording(
                            modelContext: modelContext,
                            folder: selectedFolder
                        )
                    }
                }
            }
            .padding(.bottom, 18)
        }
        .frame(height: 500)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.2),
            radius: 12,
            y: 6
        )
        .padding(.horizontal, 32)
    }

    private func formattedTime(
        _ time: TimeInterval
    ) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }
}


private struct WaveformPitchCard: View {
    let rawPitch: DetectedPitch?
    let processedPitch: DetectedPitch?
    let samples: [CGFloat]
    let isRecording: Bool

    var body: some View {
        ZStack {
            Image(.recordBackground)
                .resizable()
                .allowsHitTesting(false)

            VStack(spacing: 14) {
                PitchIndicatorView(
                    rawPitch: rawPitch,
                    processedPitch: processedPitch,
                    isRecording: isRecording
                )

                WaveformView(samples: samples)
                    .frame(height: 90)
            }
            .padding(.horizontal, 20)
            .padding(.top, 130)
            .padding(.bottom, 110)
        }
    }
}

private struct PitchHeightCard: View {
    let rawPitch: DetectedPitch?
    let processedPitch: DetectedPitch?
    let rawPitchSamples: [CGFloat]
    let processedPitchSamples: [CGFloat]
    let isRecording: Bool

    var body: some View {
        ZStack {
            Image(.recordBackground)
                .resizable()
                .allowsHitTesting(false)

            Color.blue.opacity(0.05)
                .allowsHitTesting(false)

            VStack(spacing: 10) {
                PitchIndicatorView(
                    rawPitch: rawPitch,
                    processedPitch: processedPitch,
                    isRecording: isRecording
                )

                PianoPitchGraphView(
                    rawSamples: rawPitchSamples,
                    processedSamples: processedPitchSamples
                )
                .frame(height: 190)
            }
            .padding(.horizontal, 18)
            .padding(.top, 130)
            .padding(.bottom, 110)
        }
    }
}

private struct PianoPitchGraphView: View {
    let rawSamples: [CGFloat]
    let processedSamples: [CGFloat]

    private let minimumMIDINote: CGFloat = 48
    private let maximumMIDINote: CGFloat = 84

    var body: some View {
        HStack(spacing: 0) {
            PianoKeyboardView(
                minimumMIDINote: Int(minimumMIDINote),
                maximumMIDINote: Int(maximumMIDINote)
            )
            .frame(width: 48)

            PitchGridView(
                rawSamples: rawSamples,
                processedSamples: processedSamples,
                minimumMIDINote: minimumMIDINote,
                maximumMIDINote: maximumMIDINote
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.secondary.opacity(0.2))
        }
        .accessibilityLabel("피아노 건반과 실시간 음높이 그래프")
    }
}

private struct PianoKeyboardView: View {
    let minimumMIDINote: Int
    let maximumMIDINote: Int

    private var notes: [Int] {
        Array(
            stride(
                from: maximumMIDINote,
                through: minimumMIDINote,
                by: -1
            )
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let rowHeight = geometry.size.height
                / CGFloat(notes.count)

            ZStack(alignment: .topLeading) {
                Color.white

                ForEach(
                    Array(notes.enumerated()),
                    id: \.element
                ) { index, midiNote in
                    let noteIndex = (midiNote % 12 + 12) % 12
                    let isBlackKey = [1, 3, 6, 8, 10]
                        .contains(noteIndex)
                    let y = CGFloat(index) * rowHeight

                    Rectangle()
                        .fill(
                            isBlackKey
                                ? Color.black
                                : Color.white
                        )
                        .frame(
                            width: isBlackKey ? 31 : 48,
                            height: rowHeight
                        )
                        .overlay(alignment: .trailing) {
                            if noteIndex == 0 {
                                Text("C\(midiNote / 12 - 1)")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundStyle(.gray)
                                    .padding(.trailing, 2)
                            }
                        }
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(.gray.opacity(0.35))
                                .frame(height: 0.5)
                        }
                        .offset(y: y)
                }
            }
        }
    }
}

private struct PitchGridView: View {
    let rawSamples: [CGFloat]
    let processedSamples: [CGFloat]
    let minimumMIDINote: CGFloat
    let maximumMIDINote: CGFloat

    var body: some View {
        Canvas { context, size in
            drawSemitoneGrid(context: &context, size: size)
            drawPitchLine(
                samples: rawSamples,
                color: .blue,
                labelPrefix: "원음",
                labelXOffset: 58,
                lineWidth: 1.5,
                context: &context,
                size: size
            )
            drawPitchLine(
                samples: processedSamples,
                color: .orange,
                labelPrefix: "분석",
                labelXOffset: 20,
                lineWidth: 3,
                context: &context,
                size: size
            )
        }
        .background(.black.opacity(0.04))
        .overlay(alignment: .topLeading) {
            HStack(spacing: 8) {
                Label("원음", systemImage: "minus")
                    .foregroundStyle(.blue)
                Label("분석", systemImage: "minus")
                    .foregroundStyle(.orange)
            }
            .font(.system(size: 8, weight: .semibold))
            .padding(5)
        }
    }

    private func drawSemitoneGrid(
        context: inout GraphicsContext,
        size: CGSize
    ) {
        let noteCount = maximumMIDINote - minimumMIDINote

        for offset in 0...Int(noteCount) {
            let midiNote = maximumMIDINote - CGFloat(offset)
            let y = yPosition(for: midiNote, height: size.height)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            let isC = Int(midiNote) % 12 == 0
            context.stroke(
                path,
                with: .color(.secondary.opacity(isC ? 0.28 : 0.1)),
                lineWidth: isC ? 1 : 0.5
            )
        }
    }

    private func drawPitchLine(
        samples: [CGFloat],
        color: Color,
        labelPrefix: String,
        labelXOffset: CGFloat,
        lineWidth: CGFloat,
        context: inout GraphicsContext,
        size: CGSize
    ) {
        guard !samples.isEmpty else { return }
        var path = Path()

        for (index, sample) in samples.enumerated() {
            let progress = samples.count == 1
                ? 1
                : CGFloat(index) / CGFloat(samples.count - 1)
            let point = CGPoint(
                x: progress * size.width,
                y: yPosition(for: sample, height: size.height)
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round
            )
        )

        guard let lastSample = samples.last else { return }
        let currentPoint = CGPoint(
            x: size.width - labelXOffset,
            y: yPosition(for: lastSample, height: size.height)
        )
        let labelRect = CGRect(
            x: currentPoint.x - 25,
            y: currentPoint.y - 8,
            width: 50,
            height: 16
        )
        context.fill(
            Path(roundedRect: labelRect, cornerRadius: 5),
            with: .color(color)
        )
        context.draw(
            Text("\(labelPrefix) \(scientificName(for: lastSample))")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.white),
            at: currentPoint
        )
    }

    private func yPosition(
        for midiNote: CGFloat,
        height: CGFloat
    ) -> CGFloat {
        let clampedNote = min(
            max(midiNote, minimumMIDINote),
            maximumMIDINote
        )
        let noteCount = maximumMIDINote - minimumMIDINote + 1
        let offsetFromTop = maximumMIDINote - clampedNote
        return height * (offsetFromTop + 0.5) / noteCount
    }

    private func scientificName(
        for exactMIDINote: CGFloat
    ) -> String {
        let midiNote = Int(exactMIDINote.rounded())
        let names = [
            "C", "C♯", "D", "D♯", "E", "F",
            "F♯", "G", "G♯", "A", "A♯", "B"
        ]
        let index = (midiNote % 12 + 12) % 12
        return "\(names[index])\(midiNote / 12 - 1)"
    }
}

private struct PitchIndicatorView: View {
    let rawPitch: DetectedPitch?
    let processedPitch: DetectedPitch?
    let isRecording: Bool

    var body: some View {
        VStack(spacing: 2) {
            if let processedPitch, isRecording {
                Text(processedPitch.scientificName)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.orange)
                    .contentTransition(.numericText())

                if let rawPitch {
                    Text(
                        "분석 \(processedPitch.scientificName) · 원음 \(rawPitch.scientificName) · "
                        + String(format: "%.1f Hz", rawPitch.frequency)
                    )
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
            } else if let rawPitch, isRecording {
                Text("분석 중")
                    .font(.title3.bold())
                Text(
                    "원음 \(rawPitch.scientificName) · "
                    + String(format: "%.1f Hz", rawPitch.frequency)
                )
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            } else {
                Text(isRecording ? "음을 듣는 중" : "—")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 56)
        .animation(.easeOut(duration: 0.12), value: processedPitch)
        .accessibilityElement(children: .combine)
    }
}

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        isRecording
                            ? Color.red.opacity(0.2)
                            : Color.blue.opacity(0.2)
                    )
                    .frame(width: 88, height: 88)

                Circle()
                    .fill(
                        isRecording
                            ? Color.red
                            : Color.blue
                    )
                    .frame(
                        width: isRecording ? 42 : 62,
                        height: isRecording ? 42 : 62
                    )

                if isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isRecording
                ? "녹음 종료"
                : "녹음 시작"
        )
    }
}


#Preview {
    RecordView()
}
