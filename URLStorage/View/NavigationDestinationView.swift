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
    
    @State var addNewTask: Bool = false
    
    @State var deleteKey: Bool = false
    @State var deleteItems: [GroupItem] = []
    
    @State var editKey: Bool = false
    
    var onBack: () -> ()
    
    @State var groupItems: [GroupItem] = []
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(groupItems, id: \.self) { item in
                    itemView(item: item)
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
            if deleteKey {
                VStack {
                    Spacer()
                    
                    Button {
                        helper.itemDelete(context: context, items: deleteItems)
                        groupItems = helper.getItem(groups: groups)
                        deleteKey.toggle()
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
            }
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
                        deleteKey.toggle()
                    }
                    .foregroundColor(.red)
            }
            
            ToolbarItem(placement: .bottomBar) {
                if !deleteKey {
                    Button {
                        addNewTask.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                    .offset(y: -10)
                    .hAlign(.trailing)
                }
            }
        }
        .fullScreenCover(isPresented: $addNewTask) {
            addTaskView(groups: groups) {
                groupItems = helper.getItem(groups: groups)
            }
        }
    }
    
    @ViewBuilder
    func itemView(item: GroupItem) -> some View {
        HStack {
            if deleteKey {
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
                            .foregroundColor(getColor(color: groups.color ?? "").opacity(0.5))
                    } else {
                        Image(uiImage: UIImage(data: item.itemimage!)!)
                            .resizable()
                            .frame(width: 100, height: 80)
                            .scaledToFill()
                            .clipped()
                            .cornerRadius(10)
                    }
                    
                    Text(item.itemtitle ?? "")
                        .foregroundColor(getColor(color: groups.color ?? ""))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("編集") {
                        editKey.toggle()
                    }
                    .foregroundColor(getColor(color: groups.color ?? "").opacity(0.7))
                    .vAlign(.topTrailing)
                }
                
                HStack(spacing: 50) {
                    Text(dateToString(date: item.itemtimestamp))
                        .foregroundColor(getColor(color: groups.color ?? "").opacity(0.5))
                        .font(.caption2)
                    
                    if !(item.url?.isEmpty ?? false) {
                        Link(destination: URL(string: item.url!)!) {
                            Text("リンクへ移動")
                                .frame(width: 150)
                                .foregroundColor(getColor(color: groups.color ?? ""))
                                .background {
                                    Capsule()
                                        .fill(getColor(color: groups.color ?? "").opacity(0.5).gradient)
                                }
                        }
                    }
                    
                    Spacer()
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
        .sheet(isPresented: $editKey, content: {
            EditItemView(groupItem: item, selectedImageData: item.itemimage, titleText: item.itemtitle ?? "", urlText: item.url ?? "", articleText: item.impression ?? "")
        })
        .onTapGesture {
            guard deleteKey else { return }
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
