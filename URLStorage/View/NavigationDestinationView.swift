//
//  NavigationDestinationView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

struct NavigationDestinationView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var sceneDelegate: MySceneDelegate
    @ObservedObject var interstitial = Interstitial()
    
    let groups: Groups
    let helper = CoreDataHelper()
    @State var groupItems: [GroupItem] = []
    
    @State var isAdd: Bool = false
    
    @State var isDelete: Bool = false
    @State var deleteItems: [GroupItem] = []
    @State var deleteAlert: Bool = false
    
    @State var editItem: GroupItem?
    
    @State private var isZoomed = false
    @State var zoomImage: GroupItem?
    
    @State var searchText = ""
    //@FocusState  var isFocused: Bool
    
    var onBack: () -> ()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(groupItems, id: \.self) { item in
                    itemView(item: item)
                }
                
                Text("")
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            groupItems = helper.getItem(groups: groups)
            interstitial.LoadInterstitial()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "検索") {
            let matchedItems = self.groupItems.filter { item in
                return item.itemtitle?.contains(self.searchText) ?? false
            }
            ForEach(matchedItems) { item in
                itemView(item: item, search: true)
            }
        }
        .navigationTitle(groups.grouptitle ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if isDelete {
                VStack {
                    Spacer()
                    
                    Button {
                        deleteAlert = true
                        isDelete = false
                    } label: {
                        Text("削除")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(width: 300, height: 50)
                            .foregroundColor(.white)
                            .background {
                                Capsule()
                                    .fill(getColor(color: groups.color ?? "").gradient)
                            }
                    }
                    .padding(.bottom)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            } else {
                VStack {
                    Spacer()
                    if let vc = sceneDelegate.window?.rootViewController {
                        BannerView(viewController: vc, windowScene: sceneDelegate.windowScene)
                            .frame(width: 320, height: 50)
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .alert("警告", isPresented: $deleteAlert){
            Button("削除", role: .destructive){
                // データ削除処理
                helper.itemDelete(context: context, items: deleteItems)
                groupItems = helper.getItem(groups: groups)
                interstitial.ShowInterstitial()
            }
        } message: {
            Text("データが削除されますが、よろしいですか？")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    onBack()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("削除") {
                    isDelete.toggle()
                }
                .foregroundColor(.red)
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
        .sheet(item: $editItem) { item in
            EditItemView(groupItem: item) {
                groupItems = helper.getItem(groups: groups)
            }
        }
        .fullScreenCover(isPresented: $isZoomed) {
            FullScreenImageView(item: $zoomImage)
        }
        .fullScreenCover(isPresented: $isAdd) {
            addTaskView(groups: groups) {
                groupItems = helper.getItem(groups: groups)
            }
        }
    }
    
    @ViewBuilder
    func itemView(item: GroupItem, search: Bool = false) -> some View {
        HStack {
            if isDelete {
                Image(systemName: deleteItems.contains(item) ? "checkmark.circle.fill" : "checkmark.circle")
                    .resizable()
                    .foregroundColor(getColor(color: groups.color ?? ""))
                    .frame(width: 20, height: 20)
                    .offset(x: 15)
            }
            
            VStack {
                HStack(spacing: 30) {
                    if item.itemimage == nil {
                        VideoThumbnailView(url: item.url ?? "")
                            .onTapGesture {
                                zoomImage = item
                                isZoomed.toggle()
                            }
                    } else {
                        Image(uiImage: UIImage(data: item.itemimage!)!)
                            .resizable()
                            .frame(width: 100, height: 80)
                            .scaledToFill()
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                zoomImage = item
                                isZoomed.toggle()
                            }
                    }
                    
                    Text(item.itemtitle ?? "")
                        .foregroundColor(getColor(color: groups.color ?? ""))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("編集") {
                        editItem = item
                    }
                    .foregroundColor(getColor(color: groups.color ?? "").opacity(0.7))
                    .vAlign(.topTrailing)
                }
                
                HStack {
                    Text(dateToString(date: item.itemtimestamp))
                        .foregroundColor(getColor(color: groups.color ?? "").opacity(0.5))
                        .font(.caption2)
                    
                    Spacer()
                    
                    if !(item.url?.isEmpty ?? false) {
                        if URL(string: item.url!) == nil {
                            Text("URLが存在しません")
                                .frame(width: 150)
                                .font(.caption2)
                                .foregroundColor(getColor(color: groups.color ?? ""))
                        } else {
                        Link(destination: URL(string: item.url!)!) {
                            Text("リンクへ移動")
                                .frame(width: 150)
                                .foregroundColor(getColor(color: groups.color ?? ""))
                                .background {
                                    Capsule()
                                        .fill(getColor(color: groups.color ?? "").opacity(0.5).gradient)
                                }
                                .padding(.trailing, 20)
                        }
                        .onTapGesture {
                            item.itemtimestamp = Date()
                            try! context.save()
                        }
                    }
                    }
                }
                .frame(height: 25)
                
                if let impression = item.impression {
                    Text(impression)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .hAlign(.leading)
                }
                if !search {
                    Rectangle()
                        .fill(.primary.opacity(0.2))
                        .frame(height: 1)
                }
            }
            .padding([.horizontal, .top], 20)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard isDelete else { return }
            if deleteItems.contains(item) {
                deleteItems.removeAll(where: {$0 == item})
            } else {
                deleteItems.append(item)
            }
        }
    }
}

struct NavigationDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
