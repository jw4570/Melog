//
//  ContentView.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

import SwiftUI

struct HomeView: View {
    @State var isFolderAlertPresented = false
    @State var myFolderList: [FolderListComponent] = []
    @State private var newFolderName: String = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Content(
                    isFolderAlertPresented: $isFolderAlertPresented,
                    myFolderList: myFolderList
                )
                    .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("보관함")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFolderAlertPresented = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
            
            ToolbarSpacer(
                .fixed,
                placement: .topBarTrailing
            )
            
            ToolbarItem(placement: .topBarTrailing) {
                Text("편집")
                    .padding(.horizontal, 16)
            }
        }
        .alert(
            "나의 폴더",
            isPresented: $isFolderAlertPresented
        ) {
            TextField(
                "폴더 이름",
                text: $newFolderName
            )

            Button("취소", role: .cancel) {
                newFolderName = ""
            }

            Button("추가") {
                if(!newFolderName.isEmpty) { addFolder() }
            }
            
        } message: {
            Text("새 폴더의 이름을 입력하세요.")
        }
    }
    
    private func addFolder() {
        let trimmedName = newFolderName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedName.isEmpty else {
            return
        }

        guard !myFolderList.contains(where: {
            $0.name == trimmedName
        }) else {
            return
        }

        myFolderList.append(FolderListComponent(
            name: trimmedName,
            icon: Image(systemName: "folder"),
            count: 0
        ))
        newFolderName = ""
    }
}

enum BasicFolders {
    case allMelodies
    case favorites
    
    var component: FolderListComponent {
        switch self {
        case .allMelodies:
            FolderListComponent(
                name: "모든 멜로디",
                icon: Image(systemName: "waveform"),
                count: 0
            )
        case .favorites:
            FolderListComponent(
                name: "즐겨찾기",
                icon: Image(systemName: "star"),
                count: 0
            )
        }
    }
}

private struct Content: View {
    @Binding var isFolderAlertPresented: Bool
    let myFolderList: [FolderListComponent]
    
    var body: some View {
        HStack {
            Text(.melog)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(.primaryText)
            
            Spacer()
        }
        
        VStack(spacing: 8) {
            ListView(list: [BasicFolders.allMelodies.component,
                            BasicFolders.favorites.component]
            )
            
            Text("나의 폴더")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondaryText)
                .padding(.top, 10)
            
            if(!myFolderList.isEmpty) {
                ListView(list: myFolderList)
            } else {
                HStack {
                    Text("폴더를 생성하세요")
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            isFolderAlertPresented = true
                        }
                    Spacer()
                }
            }
        }
            
    }
}

#Preview {
    HomeView()
}
