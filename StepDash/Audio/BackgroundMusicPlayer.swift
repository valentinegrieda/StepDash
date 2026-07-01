import AVFoundation

final class BackgroundMusicPlayer {
    static let shared = BackgroundMusicPlayer()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func startIfNeeded() {
        guard audioPlayer?.isPlaying != true else { return }

        do {
            try configureAudioSession()

            guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
                print("Background music file not found in app bundle.")
                return
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.4
            player.prepareToPlay()
            player.play()

            audioPlayer = player
        } catch {
            print("Failed to start background music: \(error)")
        }
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
    }
}
