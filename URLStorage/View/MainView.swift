//
//  MainView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

struct MainView: View {
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    @Environment(\.managedObjectContext) var context
    @State var path: [Groups] = []
    @State var searchText: String = ""
    
    //    @Environment(\.managedObjectContext) private var viewContext
    //    @FetchRequest(
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Groups.timestamp, ascending: false)],
    //        animation: .default
    //      )
    //      var groups: FetchedResults<Groups>
    @State var groups: [Groups] = []
    let helper = CoreDataHelper()
    
    @State var isAdd: Bool = false
    @State var isEdit: Bool = false
    @State var editGroup: Groups?
    @State var deleteAlert: Bool = false
    //Grid関係
    @State var columns = Array(repeating: GridItem(.flexible()), count: 2)
    @State var columnsNumber: CGFloat = 2
    var gridWidth: CGFloat { (UIScreen.main.bounds.width / columnsNumber)}
    
    @State var currentGrid: Groups?
    @State var currentFolder: Groups?
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(groups) { group in
                        NavigationLink(value: group) {
                            gridView(groups: group)
                                .padding()
                                .frame(width: gridWidth, height: gridWidth)
                                .contextMenu {
                                    Button(action: {
                                        editGroup = group
                                        guard editGroup == nil else { return isEdit.toggle() }
                                        
                                    }) {
                                        Label("編集", systemImage: "pencil")
                                    }
                                    
                                    Button(action: {
                                        deleteAlert.toggle()
                                    }) {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                                .sheet(isPresented: $isEdit) {
                                    if let editGroup = editGroup {
                                        EditGroupView(group: editGroup)
                                    }
                                }
                                .alert("警告", isPresented: $deleteAlert){
                                    Button("削除", role: .destructive){
                                        // データ削除処理
                                        DispatchQueue.main.async {
                                            helper.groupDelete(context: context, group: group)
                                            groups = helper.getFolder(context: context)
                                        }
                                    }
                                } message: {
                                    Text("データが削除されますが、よろしいですか？")
                                }
                        }
                    }
                }
            }
            .onAppear {
                groups = helper.getFolder(context: context)
            }
            .navigationDestination(for: Groups.self, destination: { items in
                NavigationDestinationView(groups: items) {
                    popToRoot()
                    AppStoreReview.requestIfNeeded()
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("拡大/縮小") {
                            if columnsNumber == 2 {
                                columnsNumber = 1
                                columns =  Array(repeating: GridItem(.flexible()), count: 1)
                            } else {
                                columnsNumber = 2
                                columns =  Array(repeating: GridItem(.flexible()), count: 2)
                            }
                        }
                        
                        Button("設定") {
                            
                        }
                        
                        Button("プレミアム") {
                            
                        }
                        
                        //公開後
                        Button("レビュー") {
                            if let url = URL(string: "https://itunes.apple.com/app/idYOUR_APPLE_ID?action=write-review") {
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .scaleEffect(0.8)
                    }
                }
            }
            .overlay {
                Button {
                    isAdd.toggle()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                        .font(.system(size: 70))
                        .background {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 5)
                        }
                }
                .padding([.bottom, .trailing], 25)
                .hAlign(.trailing)
                .vAlign(.bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .fullScreenCover(isPresented: $isAdd) {
            addTaskGroupView {
                groups = helper.getFolder(context: context)
            }
        }
        .ignoresSafeArea()
    }
    
    private func popToRoot() {
        path = []
    }
    
    @ViewBuilder
    func gridView(groups: Groups) -> some View {
        if (groups.groupimage == nil) {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(getColor(color: groups.color ?? "").opacity(0.25))
                .overlay {
                    
                    Text(groups.grouptitle ?? "")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .shadow(radius: 1)
        }
        
        if (groups.groupimage != nil) {
            Image(uiImage: UIImage(data: groups.groupimage!)!)
                .resizable()
                .overlay {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white)
                        
                        Text(groups.grouptitle ?? "")
                            .font(.caption)
                            .foregroundColor(getColor(color: groups.color ?? ""))
                    }
                    .frame(height: 30)
                    .vAlign(.bottom)
                }
                .cornerRadius(16)
                .shadow(radius: 1)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


