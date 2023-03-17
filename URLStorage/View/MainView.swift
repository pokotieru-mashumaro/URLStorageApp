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
    @EnvironmentObject private var sceneDelegate: MySceneDelegate
    @ObservedObject var interstitial = Interstitial()
    
    @State var path: [Groups] = []
    
    @State var groups: [Groups] = []
    let helper = CoreDataHelper()
    
    @State var isAdd: Bool = false
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
                                    }) {
                                        Label("編集", systemImage: "pencil")
                                    }
                                    
                                    Button(action: {
                                        deleteAlert.toggle()
                                    }) {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                                .alert("警告", isPresented: $deleteAlert){
                                    Button("削除", role: .destructive){
                                        // データ削除処理
                                        DispatchQueue.main.async {
                                            helper.groupDelete(context: context, group: group)
                                            groups = helper.getFolder(context: context)
                                            interstitial.ShowInterstitial()
                                        }
                                    }
                                } message: {
                                    Text("データが削除されますが、よろしいですか？")
                                }
                        }
                    }
                }
                Text("")
                    .padding(.bottom, 40)
            }
            .onAppear {
                groups = helper.getFolder(context: context)
                interstitial.LoadInterstitial()
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
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isAdd.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                    }
                    .hAlign(.trailing)
                    .vAlign(.center)
                }
            }
            .overlay {
                VStack {
                    Spacer()
                    if let vc = sceneDelegate.window?.rootViewController {
                        BannerView(viewController: vc, windowScene: sceneDelegate.windowScene)
                            .frame(width: 320, height: 50)
                    }
                }
            }
        }
        .sheet(item: $editGroup) { group in
            EditGroupView(group: group) {
                groups = helper.getFolder(context: context)
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


