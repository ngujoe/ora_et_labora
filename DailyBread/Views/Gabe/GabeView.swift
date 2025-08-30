//
//  Untitled.swift
//  DailyBread
//
//  Created by Joe on 7/29/25.
//

// TODO: https://blog.stackademic.com/integrate-whisper-cpp-in-ios-b2f2873c2c69 to incorporate TTS and then submit to chatgpt to summarize
import SwiftUI
import Speech
import AVFoundation

struct Memo: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var transcription: String
}

class GabeAIViewModel: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isRecording = false
    @Published var currentTranscription = ""
    @Published var memos: [Memo] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("memos.json")
    }
    
    override init() {
        super.init()
        loadMemos()
        speechRecognizer?.delegate = self
    }
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus != .authorized {
                    print("Speech recognition not authorized")
                }
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("Microphone access denied")
            }
        }
    }
    
    func startRecording() {
        guard !audioEngine.isRunning else { return }
        
        currentTranscription = ""
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.currentTranscription = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isRecording = false
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine couldn't start: \(error)")
        }
    }
    
    func stopRecording() {
        guard audioEngine.isRunning else { return }
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        // Save memo
        let memo = Memo(date: Date(), transcription: currentTranscription)
        memos.append(memo)
        saveMemos()
    }
    
    func saveMemos() {
        do {
            let data = try JSONEncoder().encode(memos)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save memos: \(error)")
        }
    }
    
    func loadMemos() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            memos = try JSONDecoder().decode([Memo].self, from: data)
        } catch {
            print("Failed to load memos: \(error)")
        }
    }
}

struct GabeView: View {
    @StateObject private var vm = GabeAIViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text(vm.isRecording ? "Listening..." : "Tap to start recording")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    Text(vm.currentTranscription)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding()
                }
                .frame(height: 150)
                
                Button(action: {
                    vm.isRecording ? vm.stopRecording() : vm.startRecording()
                }) {
                    Text(vm.isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(vm.isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                List(vm.memos) { memo in
                    VStack(alignment: .leading) {
                        Text(memo.transcription)
                            .font(.body)
                        Text(memo.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Gabe AI")
            .onAppear {
                vm.requestPermissions()
            }
        }
    }
}


#Preview{
    GabeView()
        .environmentObject(AppSettings())
}
