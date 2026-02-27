//
//  AudioManager.swift
//  TorisExam
//
//  Created by Kartikay on 27/02/26.
//

import AVFoundation
import SwiftUI

@MainActor
class AudioManager: ObservableObject {
    static let shared = AudioManager()

    var player: AVAudioPlayer?

    @Published var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: "isMuted")
            updatePlaybackState()
        }
    }

    private init() {
        self.isMuted = UserDefaults.standard.bool(forKey: "isMuted")
        setupAudio()
    }

    private let maxVolume: Float = 0.5
    private let fadeDuration: TimeInterval = 0.8

    private func setupAudio() {
        guard
            let data = NSDataAsset(
                name: "Loyalty_Freak_Music_-_01_-_Go_to_the_Picnicchosic.com_(chosic.com)")?.data
        else {
            print("Failed to load audio asset")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(data: data)
            player?.numberOfLoops = -1
            player?.volume = isMuted ? 0 : maxVolume
            player?.prepareToPlay()

            if !isMuted {
                player?.play()
            }
        } catch {
            print("Failed to setup audio player: \(error.localizedDescription)")
        }
    }

    func playMusic() {
        guard !isMuted, let player = player else { return }

        if !player.isPlaying {
            player.volume = 0
            player.play()
            player.setVolume(maxVolume, fadeDuration: fadeDuration)
        } else if player.volume < maxVolume {
            player.setVolume(maxVolume, fadeDuration: fadeDuration)
        }
    }

    func pauseMusic() {
        guard let player = player, player.isPlaying else { return }

        player.setVolume(0, fadeDuration: fadeDuration)

        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
            if self.isMuted {
                player.pause()
            }
        }
    }

    func toggleMute() {
        isMuted.toggle()
    }
    private func updatePlaybackState() {
        if isMuted {
            pauseMusic()
        } else {
            playMusic()
        }
    }
}
