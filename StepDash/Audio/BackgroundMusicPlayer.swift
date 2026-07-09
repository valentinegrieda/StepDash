import AVFoundation

final class BackgroundMusicPlayer {
    static let shared = BackgroundMusicPlayer()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureSession()

        // Auto-resume after any system interruption (calls, other audio, etc.).
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    /// Starts the looping track once. Safe to call repeatedly — it never recreates
    /// or restarts a track that already exists.
    func startIfNeeded() {
        if audioPlayer == nil {
            createPlayer()
        }
        resumeIfPaused()
    }

    /// Resumes the existing track from where it is (no reload, no restart) if it
    /// somehow got paused — e.g. an interruption or a view teardown deactivating
    /// the session. This is the "keep playing no matter what" hook.
    func resumeIfPaused() {
        guard let audioPlayer, !audioPlayer.isPlaying else { return }

        // Try a plain, seamless resume first; only re-activate the session if that
        // fails (which is the only case that can click).
        if !audioPlayer.play() {
            try? AVAudioSession.sharedInstance().setActive(true)
            audioPlayer.play()
        }
    }

    private func configureSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func createPlayer() {
        guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Background music file not found in app bundle.")
            return
        }

        do {
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

    @objc private func handleInterruption(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: raw)
        else { return }

        if type == .ended {
            resumeIfPaused()
        }
    }
}
