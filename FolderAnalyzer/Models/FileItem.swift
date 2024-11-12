//
//  FileItem.swift
//  FolderAnalyzer
//
//  Created by Thilina Chamath Hewagama on 2024-11-12.
//

import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let path: String
    let size: Int64
    let name: String
    let url: URL
    
    var sizeString: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.path == rhs.path
    }
} 