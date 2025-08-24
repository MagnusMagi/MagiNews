//
//  AvatarView.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import SwiftUI
import PhotosUI

struct AvatarView: View {
    let size: CGFloat
    @Binding var avatarData: Data
    let onTap: () -> Void
    
    @State private var showingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    init(size: CGFloat = 80, avatarData: Binding<Data>, onTap: @escaping () -> Void) {
        self.size = size
        self._avatarData = avatarData
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            showingPhotoPicker = true
        }) {
            ZStack {
                // Avatar Circle
                Circle()
                    .fill(avatarGradient)
                    .frame(width: size, height: size)
                    .overlay(
                        avatarContent
                    )
                
                // Edit Overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.blue))
                            .offset(x: 8, y: 8)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { oldValue, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        avatarData = data
                        onTap()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var avatarGradient: LinearGradient {
        if !avatarData.isEmpty, let uiImage = UIImage(data: avatarData) {
            return LinearGradient(
                colors: [Color.clear, Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var avatarContent: some View {
        Group {
            if !avatarData.isEmpty, let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    @Binding var userName: String
    @Binding var avatarData: Data
    let userRegion: String
    let onAvatarTap: () -> Void
    let onNameEdit: (String) -> Void
    
    @State private var isEditingName = false
    @State private var tempUserName: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Avatar
            AvatarView(size: 100, avatarData: $avatarData, onTap: onAvatarTap)
            
            // User Info
            VStack(spacing: 12) {
                // Editable Name
                if isEditingName {
                    HStack {
                        TextField("Enter name", text: $tempUserName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Save") {
                            onNameEdit(tempUserName)
                            isEditingName = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        
                        Button("Cancel") {
                            tempUserName = userName
                            isEditingName = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                } else {
                    HStack {
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            tempUserName = userName
                            isEditingName = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Region Display
                HStack(spacing: 8) {
                    Text(regionFlag(for: userRegion))
                        .font(.title3)
                    
                    Text(userRegion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private func regionFlag(for region: String) -> String {
        switch region {
        case "Estonia": return "🇪🇪"
        case "Latvia": return "🇱🇻"
        case "Lithuania": return "🇱🇹"
        case "Finland": return "🇫🇮"
        case "Nordic": return "🌍"
        default: return "🌍"
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        ProfileHeaderView(
            userName: .constant("John Doe"),
            avatarData: .constant(Data()),
            userRegion: "Estonia",
            onAvatarTap: {},
            onNameEdit: { _ in }
        )
        
        AvatarView(size: 60, avatarData: .constant(Data()), onTap: {})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
