import SwiftUI
import UniformTypeIdentifiers
import AppKit

// This class handles image document operations
class ImageDocumentHandler: ObservableObject {
    @Published var isExporting = false
    
    func saveImage(_ image: NSImage?, filename: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let image = image else {
            completion(.failure(CocoaError(.fileNoSuchFile)))
            return
        }
        
        // Use NSOpenPanel which doesn't require Sendable conformance
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = filename
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.exportImage(image, to: url, completion: completion)
            } else {
                completion(.failure(CocoaError(.userCancelled)))
            }
        }
    }
    
    private func exportImage(_ image: NSImage, to url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // Convert to PNG data
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            completion(.failure(CocoaError(.fileWriteUnknown)))
            return
        }
        
        // Write to file
        do {
            try pngData.write(to: url)
            completion(.success(url))
        } catch {
            completion(.failure(error))
        }
    }
}
