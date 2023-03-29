//
//  NavigationDestinationView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI
import WidgetKit
import Kingfisher

struct NavigationDestinationView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var sceneDelegate: MySceneDelegate
    @ObservedObject private var interstitial = Interstitial()
    @ObservedObject  private var reward = Reward()
    
    enum widgetAlertType {
        case usually
        case rewardError
        case noUrl
    }
    @AppStorage("widgetItem") var widgetItemURL = ""
    @State private var widgetAlert: Bool = false
    @State private var widgetImage: UIImage?
    @State private var widgetImageAlert: Bool = false
    @State private var alertType: widgetAlertType = .usually
    
    @State private var rewardAlert: Bool = false
    
    let groups: Groups
    private let helper = CoreDataHelper()
    @State private var groupItems: [GroupItem] = []
    
    @State private var isAdd: Bool = false
    
    @State private var isDelete: Bool = false
    @State private var deleteItems: [GroupItem] = []
    @State private var deleteAlert: Bool = false
    
    @State private var editItem: GroupItem?
    
    @State private var isZoomed = false
    @State private var zoomImage: GroupItem?
    
    @State private var searchText = ""    
    
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
            reward.loadReward()
            interstitial.LoadInterstitial()
        }
        .refreshable {
            groupItems = []
            groupItems = helper.getItem(groups: groups)
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
                groupItems = []
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
                        VideoThumbnailView(url: item.url ?? "") { uiimage in
                            Task {
                                if item.url == widgetItemURL {
                                    widgetImage = uiimage
                                }
                            }
                        }
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
                    
                    HStack(spacing: 8) {
                        Button {
                            widgetButtonFunc(item: item)
                        } label: {
                            Image(systemName: item.url == widgetItemURL ? "star.fill" : "star")
                                .frame(width: 20, height: 20)
                        }
                        
                        Button("編集") {
                            editItem = item
                        }
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
        .alert(isPresented: $widgetAlert) {
            switch alertType {
            case .usually:
                return Alert(title: Text("注意"),
                             message: Text("CMを見てウィジェットに設定しますか？"),
                             primaryButton: .default(Text("設定")){
                    reward.showReward()
                    userdefaultSave(item: item)
                    widgetImage = nil
                    WidgetCenter.shared.reloadAllTimelines()

                },
                             secondaryButton: .destructive(Text("キャンセル")))
            case .rewardError:
                return Alert(title: Text("CMの読み込みに失敗しました"),
                      message: Text("しばらく時間をおいてお試しください"),
                      dismissButton: .default(Text("了解")))  // ボタンの変更
            case .noUrl:
                return Alert(title: Text("URLが指定されていません"),
                      message: Text("ウィジェットはURLを指定しているものが対象です"),
                      dismissButton: .default(Text("了解")))  // ボタンの変更
            }
        }
    }
    
    private func userdefaultSave(item: GroupItem) {
        let userDefaults = UserDefaults(suiteName: "group.com.kotaro.URLVaultApp")

        // データを保存する
        userDefaults?.set(item.itemtitle, forKey: "title")
        userDefaults?.set(item.group?.grouptitle, forKey: "group")
        userDefaults?.set(item.url, forKey: "url")
        userDefaults?.setUIImageToData(image: widgetImage ?? UIImage(), forKey: "image")
        // 変更を保存する
        userDefaults?.synchronize()
    }
    
    private func widgetButtonFunc(item :GroupItem) {
        widgetAlert.toggle()
        widgetItemURL = item.url ?? ""
        guard widgetItemURL != "" else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                alertType = .noUrl
            }
            return
        }
        guard reward.rewardLoaded else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                alertType = .rewardError
                reward.loadReward()
            }
            return
        }
        if item.itemimage != nil {
            //スクレイピングのサムネはVideoThumbnailViewのクロージャで
            widgetImage = UIImage(data: item.itemimage!)!
        }
        alertType = .usually
        Task {
            if let thumbnailUrl = await getThumbnailUrl(url: widgetItemURL),
               let url = URL(string: thumbnailUrl) {
                let downloader = ImageDownloader.default
                let options: KingfisherOptionsInfo = [.transition(.fade(0.3))]
                
                downloader.downloadImage(with: url, options: options) { result in
                    switch result {
                    case .success(let value):
                        DispatchQueue.main.async {
                            widgetImage = value.image
                        }
                    case .failure(let error):
                        print("Error downloading image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

struct NavigationDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}



