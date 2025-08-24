import Foundation
import AVFoundation
import SwiftUI

// MARK: - Voice Reader
@MainActor
class VoiceReader: NSObject, ObservableObject, @preconcurrency AVSpeechSynthesizerDelegate {
    @Published var isReading = false
    @Published var currentText = ""
    @Published var errorMessage: String?
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Main Reading Methods
    func readText(_ text: String, language: String = "en") {
        stopReading()
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "No text to read"
            return
        }
        
        do {
            let utterance = try createUtterance(text: text, language: language)
            currentUtterance = utterance
            currentText = text
            
            synthesizer.speak(utterance)
            isReading = true
            
            // Update state when reading finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !self.synthesizer.isSpeaking {
                    self.isReading = false
                    self.currentText = ""
                }
            }
        } catch {
            errorMessage = "Failed to create speech utterance: \(error.localizedDescription)"
        }
    }
    
    func readArticleSummary(_ article: Article, language: String = "en") {
        let text = "\(article.title). \(article.summary)"
        readText(text, language: language)
    }
    
    func readDailyDigest(_ digest: String, language: String = "en") {
        readText(digest, language: language)
    }
    
    // MARK: - Control Methods
    func stopReading() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isReading = false
        currentText = ""
        currentUtterance = nil
    }
    
    func pauseReading() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    func resumeReading() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }
    }
    
    // MARK: - Voice Settings
    func setVoiceSettings(rate: Float = 0.5, pitch: Float = 1.0, volume: Float = 1.0) {
        // These settings will be applied to future utterances
        UserDefaults.standard.set(rate, forKey: "voice_rate")
        UserDefaults.standard.set(pitch, forKey: "voice_pitch")
        UserDefaults.standard.set(volume, forKey: "voice_volume")
    }
    
    func getVoiceSettings() -> (rate: Float, pitch: Float, volume: Float) {
        let rate = UserDefaults.standard.float(forKey: "voice_rate")
        let pitch = UserDefaults.standard.float(forKey: "voice_pitch")
        let volume = UserDefaults.standard.float(forKey: "voice_volume")
        
        return (
            rate: rate > 0 ? rate : 0.5,
            pitch: pitch > 0 ? pitch : 1.0,
            volume: volume > 0 ? volume : 1.0
        )
    }
    
    // MARK: - Private Methods
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorMessage = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }
    
    private func createUtterance(text: String, language: String) throws -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        
        // Set voice based on language
        utterance.voice = getVoice(for: language)
        
        // Apply user settings
        let settings = getVoiceSettings()
        utterance.rate = settings.rate
        utterance.pitchMultiplier = settings.pitch
        utterance.volume = settings.volume
        
        return utterance
    }
    
    private func getVoice(for language: String) -> AVSpeechSynthesisVoice? {
        let languageCode = getLanguageCode(for: language)
        
        // Try to get a voice for the specific language
        if let voice = AVSpeechSynthesisVoice(language: languageCode) {
            return voice
        }
        
        // Fallback to system default voice
        return AVSpeechSynthesisVoice()
    }
    
    private func getLanguageCode(for language: String) -> String {
        switch language {
        case "et": return "et-EE" // Estonian
        case "lv": return "lv-LV" // Latvian
        case "lt": return "lt-LT" // Lithuanian
        case "fi": return "fi-FI" // Finnish
        default: return "en-US"   // English (US)
        }
    }
    
    // MARK: - Available Voices
    func getAvailableVoices(for language: String) -> [AVSpeechSynthesisVoice] {
        let languageCode = getLanguageCode(for: language)
        return AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.starts(with: languageCode.prefix(2))
        }
    }
    
    func getVoiceDisplayName(_ voice: AVSpeechSynthesisVoice) -> String {
        if voice.name.isEmpty {
            return "\(voice.language) Voice"
        }
        return voice.name
    }
}

// MARK: - AVSpeechSynthesizerDelegate Methods
extension VoiceReader {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            Task { @MainActor in
                self.isReading = true
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            Task { @MainActor in
                self.isReading = false
                self.currentText = ""
                self.currentUtterance = nil
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            Task { @MainActor in
                self.isReading = false
                self.currentText = ""
                self.currentUtterance = nil
            }
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        // Handle pause if needed
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        // Handle resume if needed
    }
}

// MARK: - Voice Reader View
struct VoiceReaderView: View {
    @StateObject private var voiceReader = VoiceReader()
    @State private var textToRead = ""
    @State private var selectedLanguage = "en"
    @State private var showingSettings = false
    
    private let languages = [
        ("en", "🇺🇸", "English"),
        ("et", "🇪🇪", "Eesti"),
        ("lv", "🇱🇻", "Latviešu"),
        ("lt", "🇱🇹", "Lietuvių"),
        ("fi", "🇫🇮", "Suomi")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Language Selector
            Picker("Language", selection: $selectedLanguage) {
                ForEach(languages, id: \.0) { language in
                    HStack {
                        Text(language.1)
                        Text(language.2)
                    }
                    .tag(language.0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Text Input
            TextField("Enter text to read aloud...", text: $textToRead, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .padding(.horizontal)
            
            // Control Buttons
            HStack(spacing: 20) {
                Button(action: {
                    voiceReader.readText(textToRead, language: selectedLanguage)
                }) {
                    HStack {
                        Image(systemName: voiceReader.isReading ? "stop.fill" : "play.fill")
                        Text(voiceReader.isReading ? "Stop" : "Read")
                    }
                    .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                .disabled(textToRead.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Button("Settings") {
                    showingSettings = true
                }
                .buttonStyle(.bordered)
            }
            
            // Status Display
            if voiceReader.isReading {
                VStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Reading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let errorMessage = voiceReader.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Voice Reader")
        .sheet(isPresented: $showingSettings) {
            VoiceSettingsView(voiceReader: voiceReader)
        }
    }
}

// MARK: - Voice Settings View
struct VoiceSettingsView: View {
    @ObservedObject var voiceReader: VoiceReader
    @Environment(\.dismiss) private var dismiss
    
    @State private var rate: Float = 0.5
    @State private var pitch: Float = 1.0
    @State private var volume: Float = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Voice Settings") {
                    VStack(alignment: .leading) {
                        Text("Speed: \(String(format: "%.1f", rate))x")
                        Slider(value: $rate, in: 0.1...1.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Pitch: \(String(format: "%.1f", pitch))x")
                        Slider(value: $pitch, in: 0.5...2.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Volume: \(String(format: "%.1f", volume))")
                        Slider(value: $volume, in: 0.0...1.0, step: 0.1)
                    }
                }
                
                Section("Test Voice") {
                    Button("Test Current Settings") {
                        voiceReader.setVoiceSettings(rate: rate, pitch: pitch, volume: volume)
                        voiceReader.readText("This is a test of the voice settings.", language: "en")
                    }
                    .disabled(voiceReader.isReading)
                }
            }
            .navigationTitle("Voice Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        voiceReader.setVoiceSettings(rate: rate, pitch: pitch, volume: volume)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            let settings = voiceReader.getVoiceSettings()
            rate = settings.rate
            pitch = settings.pitch
            volume = settings.volume
        }
    }
}
