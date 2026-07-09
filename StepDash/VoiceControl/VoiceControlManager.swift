import AVFoundation
import Combine
import Foundation
import Speech

enum VoiceCommand: Equatable {
    case destination(ToolbarDestination)
    case openMissions
    case openHistory
    case openAchievements
    case closePopup
    case acceptDelivery
    case claimDelivery
    case claimMission
}

final class VoiceControlManager: NSObject, ObservableObject {
    @Published private(set) var isListening = false
    @Published private(set) var isAuthorized = false
    @Published private(set) var transcript = ""
    @Published private(set) var statusText = "Voice off"
    var onCommand: ((VoiceCommand) -> Void)?

    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale.current) ?? SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var lastHandledPhrase = ""
    private var shouldRestartAfterFinalResult = false

    var isAvailable: Bool {
        recognizer?.isAvailable == true
    }

    override init() {
        super.init()
        recognizer?.delegate = self
    }

    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            requestAuthorizationAndStart()
        }
    }

    func requestAuthorizationAndStart() {
        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            guard let self else { return }

            AVAudioApplication.requestRecordPermission { microphoneAllowed in
                DispatchQueue.main.async {
                    self.isAuthorized = speechStatus == .authorized && microphoneAllowed

                    guard self.isAuthorized else {
                        self.statusText = "Mic permission needed"
                        return
                    }

                    self.startListening()
                }
            }
        }
    }

    func stopListening() {
        shouldRestartAfterFinalResult = false
        isListening = false
        statusText = "Voice off"
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }

    private func startListening() {
        guard !audioEngine.isRunning else { return }
        guard isAvailable else {
            statusText = "Voice unavailable"
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            statusText = "Mic setup failed"
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isListening = true
            shouldRestartAfterFinalResult = true
            transcript = ""
            lastHandledPhrase = ""
            statusText = "Listening..."
        } catch {
            statusText = "Voice failed to start"
            return
        }

        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }

            DispatchQueue.main.async {
                if let result {
                    let phrase = result.bestTranscription.formattedString
                    self.transcript = phrase
                    self.handleTranscript(phrase)

                    if result.isFinal {
                        self.restartIfNeeded()
                    }
                }

                if error != nil {
                    self.restartIfNeeded()
                }
            }
        }
    }

    private func restartIfNeeded() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest = nil
        recognitionTask = nil

        guard shouldRestartAfterFinalResult else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self, self.isListening else { return }
            self.startListening()
        }
    }

    private func handleTranscript(_ phrase: String) {
        let normalized = phrase.normalizedForVoiceCommand
        guard normalized != lastHandledPhrase else { return }
        guard let command = VoiceCommandParser.command(from: normalized) else { return }

        lastHandledPhrase = normalized
        statusText = "Command: \(VoiceCommandParser.label(for: command))"
        onCommand?(command)
    }
}

extension VoiceControlManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available, self.isListening {
                self.stopListening()
                self.statusText = "Voice unavailable"
            }
        }
    }
}

private enum VoiceCommandParser {
    static func command(from phrase: String) -> VoiceCommand? {
        if containsAny(phrase, ["close", "dismiss", "back", "tutup", "kembali"]) {
            return .closePopup
        }

        if containsAny(phrase, ["accept delivery", "accept package", "terima delivery", "terima paket"]) {
            return .acceptDelivery
        }

        if containsAny(phrase, ["claim delivery", "claim package", "ambil delivery", "ambil paket"]) {
            return .claimDelivery
        }

        if containsAny(phrase, ["claim mission", "claim missions", "ambil mission", "ambil misi"]) {
            return .claimMission
        }

        if containsAny(phrase, ["mission", "missions", "misi"]) {
            return .openMissions
        }

        if containsAny(phrase, ["history", "riwayat"]) {
            return .openHistory
        }

        if containsAny(phrase, ["achievement", "achievements", "pencapaian"]) {
            return .openAchievements
        }

        if containsAny(phrase, ["home", "rumah", "beranda"]) {
            return .destination(.home)
        }

        if containsAny(phrase, ["stats", "stat", "statistics", "statistik"]) {
            return .destination(.stats)
        }

        if containsAny(phrase, ["shop", "store", "toko"]) {
            return .destination(.shop)
        }

        if containsAny(phrase, ["profile", "profil"]) {
            return .destination(.profile)
        }

        return nil
    }

    static func label(for command: VoiceCommand) -> String {
        switch command {
        case .destination(let destination):
            return destination.title
        case .openMissions:
            return "Missions"
        case .openHistory:
            return "History"
        case .openAchievements:
            return "Achievements"
        case .closePopup:
            return "Close"
        case .acceptDelivery:
            return "Accept delivery"
        case .claimDelivery:
            return "Claim delivery"
        case .claimMission:
            return "Claim mission"
        }
    }

    private static func containsAny(_ phrase: String, _ needles: [String]) -> Bool {
        needles.contains { phrase.contains($0) }
    }
}

private extension String {
    var normalizedForVoiceCommand: String {
        lowercased()
            .replacingOccurrences(of: "[^a-z0-9 ]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
