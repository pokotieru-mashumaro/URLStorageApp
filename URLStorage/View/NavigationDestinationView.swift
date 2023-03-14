//
//  NavigationDestinationView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

struct NavigationDestinationView: View {
    @Environment(\.managedObjectContext) var context
    let groups: Groups
    let helper = CoreDataHelper()
    
    @State var isAdd: Bool = false
    
    @State var isDelete: Bool = false
    @State var deleteItems: [GroupItem] = []
    @State var deleteAlert: Bool = false
    
    @State var isEdit: Bool = false
    @State var editItem: GroupItem?
    
    @State private var isZoomed = false
    @State var zoomImage: GroupItem?
    
    var onBack: () -> ()
    
    @State var groupItems: [GroupItem] = []
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(groupItems, id: \.self) { item in
                    itemView(item: item)
                }
                
                if groupItems.isEmpty {
                    //これがないとプラスボタンの座標がおかしくなる
                    Rectangle()
                        .fill(Color.clear)
                }
            }
        }
        .onAppear {
            groupItems = helper.getItem(groups: groups)
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
            } else {
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
            }
        }
        .alert("警告", isPresented: $deleteAlert){
            Button("削除", role: .destructive){
                // データ削除処理
                helper.itemDelete(context: context, items: deleteItems)
                groupItems = helper.getItem(groups: groups)
            }
        } message: {
            Text("\(deleteItems.count)つのデータが削除されますが、よろしいですか？")
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
        }
        .fullScreenCover(isPresented: $isAdd) {
            addTaskView(groups: groups) {
                groupItems = helper.getItem(groups: groups)
            }
        }
    }
    
    @ViewBuilder
    func itemView(item: GroupItem) -> some View {
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
                        isEdit.toggle()
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
                .frame(height: 25)
                
                if let impression = item.impression {
                    Text(impression)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .hAlign(.leading)
                }
                
                Rectangle()
                    .fill(.black.opacity(0.2))
                    .frame(height: 1)
            }
            .padding([.horizontal, .top], 20)
        }
        .contentShape(Rectangle())
        .sheet(isPresented: $isEdit) {
            if let editItem = editItem {
                EditItemView(groupItem: editItem)
            }
        }
        .fullScreenCover(isPresented: $isZoomed) {
            FullScreenImageView(item: $zoomImage)
        }
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
