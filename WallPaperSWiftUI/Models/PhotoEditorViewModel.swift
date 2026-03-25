//
//  PhotoEditorViewModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 25/03/26.
//

import SwiftUI
import UIKit
import Combine

class PhotoEditorViewModel: ObservableObject {
    
    @Published var showSuccessMessage = false
    @Published var editedPhotos: [EditedPhoto] = []
    
    private let userDefaults = UserDefaults.standard
    private let editedPhotosKey = "editedPhotos"
    
    init() {
        loadEditedPhotos()
    }
    
    func saveEditedPhoto(_ image: UIImage) {
        // Save to documents directory
        let fileName = "edited_\(Date().timeIntervalSince1970).jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 0.9) {
            do {
                try data.write(to: fileURL)
                
                let editedPhoto = EditedPhoto(
                    id: UUID(),
                    fileName: fileName,
                    fileURL: fileURL,
                    createdAt: Date()
                )
                
                editedPhotos.insert(editedPhoto, at: 0) // Add at the beginning
                saveEditedPhotosToUserDefaults()
                
                print("✅ Saved edited photo: \(fileName)")
            } catch {
                print("❌ Failed to save edited photo: \(error)")
            }
        }
    }
    
    func deleteEditedPhoto(_ photo: EditedPhoto) {
        // Remove from array
        editedPhotos.removeAll { $0.id == photo.id }
        
        // Delete file from documents
        do {
            try FileManager.default.removeItem(at: photo.fileURL)
            print("✅ Deleted file: \(photo.fileName)")
        } catch {
            print("❌ Failed to delete file: \(error)")
        }
        
        // Update UserDefaults
        saveEditedPhotosToUserDefaults()
    }
    
    func loadEditedPhotos() {
        guard let data = userDefaults.data(forKey: editedPhotosKey) else { return }
        
        do {
            let photos = try JSONDecoder().decode([EditedPhoto].self, from: data)
            editedPhotos = photos
        } catch {
            print("❌ Failed to load edited photos: \(error)")
        }
    }
    
    private func saveEditedPhotosToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(editedPhotos)
            userDefaults.set(data, forKey: editedPhotosKey)
        } catch {
            print("❌ Failed to save edited photos: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct EditedPhoto: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case fileName
        case fileURL
        case createdAt
    }
    
    init(id: UUID, fileName: String, fileURL: URL, createdAt: Date) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        let urlString = try container.decode(String.self, forKey: .fileURL)
        fileURL = URL(string: urlString) ?? EditedPhoto.getDocumentsDirectory().appendingPathComponent(fileName)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileURL.absoluteString, forKey: .fileURL)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
