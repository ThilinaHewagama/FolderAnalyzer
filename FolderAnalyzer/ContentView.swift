//
//  ContentView.swift
//  FolderAnalyzer
//
//  Created by Thilina Chamath Hewagama on 2024-11-12.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var folderManager = FolderManager()
    @State private var showingFolderPicker = false
    
    var body: some View {
        VStack {
            // Folder selection section
            HStack {
                Text("Selected Folders:")
                    .font(.headline)
                Spacer()
                Button("Add Folders") {
                    showingFolderPicker = true
                }
            }
            .padding()
            
            // Selected folders list
            ScrollView(.horizontal) {
                HStack {
                    ForEach(folderManager.selectedFolders, id: \.self) { folder in
                        HStack {
                            Text(folder.lastPathComponent)
                            Button {
                                folderManager.removeFolder(folder)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            
            // Total size section
            HStack {
                Text("Total Size:")
                    .font(.headline)
                Text(folderManager.totalSizeString)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            
            if folderManager.isScanning {
                ProgressView("Scanning files...")
                    .padding()
            }
            
            // Files list
            List(folderManager.files) { file in
                HStack {
                    VStack(alignment: .leading) {
                        Text(file.name)
                            .font(.headline)
                        Text(file.path)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(file.sizeString)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    folderManager.addFolder(url)
                }
            case .failure(let error):
                print("Error selecting folders: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
