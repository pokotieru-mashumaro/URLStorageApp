//
//  MainView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI
import CoreData

struct MainView: View {
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var sceneDelegate: MySceneDelegate
    @ObservedObject private var interstitial = Interstitial()
    
    @State var path: [Groups] = []
    
    @State private var groups: [Groups] = []
    private let helper = CoreDataHelper()
    
    @State private var isAdd: Bool = false
    @State private var editGroup: Groups?
    @State private var deleteAlert: Bool = false
    @State private var deleteGroup: Groups?
    //Grid関係
    @State private var columns = Array(repeating: GridItem(.flexible()), count: 2)
    @State private var columnsNumber: CGFloat = 2
    private var gridWidth: CGFloat { (UIScreen.main.bounds.width / columnsNumber)}
    
    @State private var currentGrid: Groups?
    @State private var currentFolder: Groups?
    
    //
    @State private var selectedItemForPresenting: Groups?
    
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
                                        deleteGroup = group
                                        deleteAlert.toggle()
                                    }) {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                                .alert("警告", isPresented: $deleteAlert){
                                    Button("削除", role: .destructive){
                                        // データ削除処理
                                        DispatchQueue.main.async {
                                            helper.groupDelete(context: context, group: deleteGroup!)
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
            .refreshable {
                groups = []
                groups = helper.getFolder(context: context)
            }
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
                            if let url = URL(string: "https://itunes.apple.com/app/id6446472219?action=write-review") {
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
                groups = []
                groups = helper.getFolder(context: context)
            }
        }
        .sheet(item: $selectedItemForPresenting) { group in
            NavigationDestinationView(groups: group) {
                
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
            Color.clear
                .overlay{
                    Image(uiImage: UIImage(data: groups.groupimage!)!)
                        .resizable()
                        .scaledToFill()
                }
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
    
    private func getItemId(from url: URL) -> UUID? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              urlComponents.scheme == "urlvault",
              urlComponents.host == "widgetlink",
              urlComponents.queryItems?.first?.name == "group_title",
              let uuidString = urlComponents.queryItems?.first?.value else {
            return nil
        }
        return UUID(uuidString: uuidString)
    }
    
    private func fetchItem(id uuid: UUID) -> Groups? {
        let fetchRequest: NSFetchRequest<Groups> = Groups.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "grouptitle == %@", uuid as CVarArg)

        do {
            let items = try context.fetch(fetchRequest)
            guard let item = items.first
            else { return nil }
            return item

        } catch let error as NSError {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


