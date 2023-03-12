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
            addTaskView(groups: groups) {
               // groupItems = helper.getItem(context: context)
                groupItems = helper.getItem(groups: groups)
            }
        }
    }
    
    @ViewBuilder
    func itemView(item: GroupItem) -> some View {
        VStack {
            HStack(spacing: 30) {
                VideoThumbnailView(url: item.url ?? "")
                    .foregroundColor(getColor(color: groups.color ?? "").opacity(0.5))
                
                Text(item.itemtitle ?? "")
                    .foregroundColor(getColor(color: groups.color ?? ""))
                    .fontWeight(.semibold)
                
                Spacer()
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
}

struct NavigationDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
