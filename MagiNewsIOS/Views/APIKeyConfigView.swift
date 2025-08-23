import SwiftUI

struct APIKeyConfigView: View {
    @State private var apiKey = ""
    @State private var isKeyValid = false
    @State private var isTesting = false
    @State private var testResult: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    private let userDefaultsKey = "openai_api_key"
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("OpenAI API Key")
                            .font(.headline)
                        
                        Text("Enter your OpenAI API key to enable AI-powered features like article summarization, translation, and sentiment analysis.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        SecureField("sk-...", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: apiKey) { _ in
                                validateAPIKey()
                            }
                        
                        if !apiKey.isEmpty {
                            HStack {
                                Image(systemName: isKeyValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(isKeyValid ? .green : .red)
                                Text(isKeyValid ? "Valid format" : "Invalid format")
                                    .font(.caption)
                                    .foregroundColor(isKeyValid ? .green : .red)
                            }
                        }
                    }
                }
                
                Section("How to Get Your API Key") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Visit OpenAI's website")
                        Text("2. Sign in to your account")
                        Text("3. Go to API Keys section")
                        Text("4. Create a new secret key")
                        Text("5. Copy and paste it here")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Section("Security Note") {
                    Text("Your API key is stored locally on your device and never shared. It's used only for AI features within this app.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button(action: testAPIKey) {
                        HStack {
                            if isTesting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "play.circle.fill")
                            }
                            Text(isTesting ? "Testing..." : "Test API Key")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(apiKey.isEmpty || !isKeyValid || isTesting)
                    .buttonStyle(.borderedProminent)
                    
                    if let testResult = testResult {
                        HStack {
                            Image(systemName: testResult.contains("Success") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(testResult.contains("Success") ? .green : .red)
                            Text(testResult)
                                .font(.caption)
                        }
                    }
                }
                
                Section {
                    Button("Save API Key") {
                        saveAPIKey()
                    }
                    .disabled(apiKey.isEmpty || !isKeyValid)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("AI Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(apiKey.isEmpty || !isKeyValid)
                }
            }
            .onAppear {
                loadAPIKey()
            }
            .alert("API Key Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadAPIKey() {
        if let savedKey = UserDefaults.standard.string(forKey: userDefaultsKey) {
            apiKey = savedKey
            validateAPIKey()
        }
    }
    
    private func saveAPIKey() {
        UserDefaults.standard.set(apiKey, forKey: userDefaultsKey)
        
        alertMessage = "API key saved successfully!"
        showingAlert = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
    
    private func validateAPIKey() {
        // Basic validation: OpenAI keys start with "sk-" and are typically 51 characters long
        isKeyValid = apiKey.hasPrefix("sk-") && apiKey.count >= 20
    }
    
    private func testAPIKey() {
        guard !apiKey.isEmpty && isKeyValid else { return }
        
        isTesting = true
        testResult = nil
        
        Task {
            do {
                let result = try await testOpenAIAPI(apiKey: apiKey)
                await MainActor.run {
                    testResult = result
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = "Error: \(error.localizedDescription)"
                    isTesting = false
                }
            }
        }
    }
    
    private func testOpenAIAPI(apiKey: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/models")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return "Success! API key is valid."
        } else if httpResponse.statusCode == 401 {
            return "Error: Invalid API key"
        } else {
            let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let errorMessage = errorData?["error"] as? [String: Any]
            let message = errorMessage?["message"] as? String ?? "Unknown error"
            return "Error: \(message)"
        }
    }
}

// MARK: - Supporting Types
enum APIError: LocalizedError {
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        }
    }
}

#Preview {
    APIKeyConfigView()
}
