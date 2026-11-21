//
//  ContentView.swift
//  Tap Frenzy
//
//  Created by Amandi Sewmini Wickramasinghe on 2026-11-17.
//

import SwiftUI

struct ContentView: View {
    enum GameState {
        case idle
        case running
        case finished
    }

    @State private var gameState: GameState = .idle
    @State private var score: Int = 0
    @AppStorage("bestScore") private var bestScore: Int = 0

    @State private var timeRemaining: Int = 10
    @State private var timer: Timer?
    @State private var isTapping: Bool = false

    private let gameDuration: Int = 10

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Tap Frenzy")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 24)

                VStack(spacing: 8) {
                    Text("SCORE")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(score)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.green)
                }
                .padding(.top, 8)

                // Countdown / status
                Group {
                    switch gameState {
                    case .idle:
                        Text("tap to start")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(.subheadline, design: .rounded))
                    case .running:
                        Text("time: \(timeRemaining)s")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(.headline, design: .rounded))
                    case .finished:
                        VStack(spacing: 6) {
                            Text("time’s up")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(.headline, design: .rounded))
                            Text("best: \(bestScore)")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(.subheadline, design: .rounded))
                            Text("tap to try again")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(.footnote, design: .rounded))
                                .padding(.top, 4)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: gameState)
                .padding(.bottom, 8)

                Spacer()

                // Big circular TAP button
                Button {
                    handleTap()
                } label: {
                    ZStack {
                        // Glow
                        Circle()
                            .fill(Color.green.opacity(0.22))
                            .blur(radius: 24)
                            .scaleEffect(isTapping ? 1.05 : 1.0)
                            .animation(.easeOut(duration: 0.08), value: isTapping)

                        // Main button
                        Circle()
                            .fill(Color.green)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(0.08), lineWidth: 2)
                            )
                            .shadow(color: Color.green.opacity(0.35), radius: 18, x: 0, y: 10)

                        Text("TAP")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.black.opacity(0.85))
                    }
                    .frame(width: 220, height: 220)
                    .scaleEffect(isTapping ? 0.98 : 1.0)
                    .animation(.easeOut(duration: 0.08), value: isTapping)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 40)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
        }
        .onDisappear {
            invalidateTimer()
        }
    }

    private func handleTap() {
        // Brief press animation
        isTapping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTapping = false
        }

        switch gameState {
        case .idle:
            startGame()
        case .running:
            score += 1
        case .finished:
            resetAndIdle()
        }
    }

    private func startGame() {
        score = 0
        timeRemaining = gameDuration
        gameState = .running

        invalidateTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
            if timeRemaining == 0 {
                endGame()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func endGame() {
        invalidateTimer()
        if score > bestScore {
            bestScore = score
        }
        gameState = .finished
    }

    private func resetAndIdle() {
        invalidateTimer()
        timeRemaining = gameDuration
        score = 0
        gameState = .idle
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}
