//
//  NavigationDestinationView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

struct NavigationDestinationView: View {
    let groups: Groups
    let folderItemHelper = GroupItemHelper()
    
    @State var addNewTask: Bool = false
    var onBack: () -> ()
    
    private var groupItems: [GroupItem] {
        if let groupItems = groups.item?.allObjects as? [GroupItem] {
            return groupItems
        } else {
            return [GroupItem]()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(groupItems, id: \.self) { item in
                    itemView(item: item)
                }
            }
        }
        .navigationTitle(groups.grouptitle ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
                Button {
                    addNewTask.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fullScreenCover(isPresented: $addNewTask) {
            addTaskView(groups: groups)
        }
    }
    
    @ViewBuilder
    func itemView(item: GroupItem) -> some View {
        VStack {
            HStack(spacing: 30) {
                VideoThumbnailView(url: item.url ?? "")
                
                Text(item.itemtitle ?? "")
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
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
        .padding(30)
    }
}

struct NavigationDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
