import Foundation
import AVFoundation

final class SpeechAnnouncerService {
    private let synthesizer = AVSpeechSynthesizer()

    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // .duckOthers lowers any music playing instead of fighting it.
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("SpeechAnnouncerService: failed to configure audio session: \(error)")
        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        synthesizer.speak(utterance)
    }
}
