import AVFoundation
import SwiftUI

class MusicManager {
    static let shared = MusicManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private let backgroundTracks = ["lofi1", "lofi2", "lofi3", "lofi4"]
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMuteSettingChanged),
            name: .muteSettingChanged,
            object: nil
        )
    }
    
    func startBackgroundMusic() {
        guard backgroundMusicPlayer == nil else { return }
        
        playRandomTrack()
    }
    
    private func playRandomTrack() {
        if let trackName = backgroundTracks.randomElement(),
           let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = UserDefaults.standard.bool(forKey: "isMusicMuted") ? 0.0 : 0.5
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Error loading music: \(error.localizedDescription)")
            }
        }
    }
    
    func stopMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    func setVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = volume
    }

    
    @objc private func handleMuteSettingChanged() {
        let isMuted = UserDefaults.standard.bool(forKey: "isMusicMuted")
        backgroundMusicPlayer?.volume = isMuted ? 0.0 : 0.5
    }
}
