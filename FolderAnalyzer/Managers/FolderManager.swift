//
//  FolderManager.swift
//  FolderAnalyzer
//
//  Created by Thilina Chamath Hewagama on 2024-11-12.
//

import Foundation

class FolderManager: ObservableObject {
    @Published var selectedFolders: [URL] = []
    @Published var files: [FileItem] = []
    @Published var isScanning = false
    private var accessedResources: [URL: Bool] = [:]
    
    var totalSize: Int64 {
        files.reduce(0) { $0 + $1.size }
    }
    
    var totalSizeString: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    func addFolder(_ url: URL) {
        if !selectedFolders.contains(url) {
            if url.startAccessingSecurityScopedResource() {
                accessedResources[url] = true
                selectedFolders.append(url)
                scanFolder(url)
            } else {
                print("Failed to access folder: \(url)")
            }
        }
    }
    
    func scanFolder(_ url: URL) {
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fileManager = FileManager.default
            var newFiles: [FileItem] = []
            
            if let enumerator = fileManager.enumerator(
                at: url,
                includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
                options: [.skipsHiddenFiles, .skipsPackageDescendants]
            ) {
                for case let fileURL as URL in enumerator {
                    autoreleasepool {
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
                            
                            if resourceValues.isRegularFile == true,
                               let fileSize = resourceValues.fileSize {
                                let fileItem = FileItem(
                                    path: fileURL.path,
                                    size: Int64(fileSize),
                                    name: fileURL.lastPathComponent,
                                    url: fileURL
                                )
                                newFiles.append(fileItem)
                            }
                        } catch {
                            print("Error getting file attributes: \(error)")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.files.append(contentsOf: newFiles)
                self?.files.sort { $0.size > $1.size }
                self?.isScanning = false
            }
        }
    }
    
    func removeFolder(_ url: URL) {
        selectedFolders.removeAll { $0 == url }
        if accessedResources[url] == true {
            url.stopAccessingSecurityScopedResource()
            accessedResources.removeValue(forKey: url)
        }
        files.removeAll()
        selectedFolders.forEach { scanFolder($0) }
    }
    
    deinit {
        // Clean up any remaining security-scoped resource access
        for (url, accessed) in accessedResources where accessed {
            url.stopAccessingSecurityScopedResource()
        }
    }
} 