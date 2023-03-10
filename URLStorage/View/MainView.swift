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
    @State var path: [Groups] = []
    @State var searchText: String = ""
    
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Groups.timestamp, ascending: false)],
//        animation: .default
//      )
//      var groups: FetchedResults<Groups>
    @State var groups: [Groups] = []
    let groupsHelper = GroupsHelper()
    
    @State var addNewGroup: Bool = false
    @State var comeInfo: Bool = false
    
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
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: gridWidth, height: gridWidth)
                        }
//                        NavigationLink(destination: {
//                            NavigationDestinationView(folder: folder) {
//                                popToRoot()
//                            }
//                        }, label: {
//                            gridView(folder: folder)
//                                .foregroundColor(.black)
//                                .padding()
//                                .frame(width: gridWidth, height: gridWidth)
//                        })
                    }
                }
            }
            .onAppear {
                groups = groupsHelper.getFolder()
            }
            .navigationDestination(for: Groups.self, destination: { items in
                NavigationDestinationView(groups: items) {
                    popToRoot()
                }
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        comeInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                
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
                                             
                        Button("削除", role: .destructive) {
                            
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .scaleEffect(0.8)
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            addNewGroup.toggle()
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
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "検索") {
            let matchedItems = self.groups.filter { group in
                return group.grouptitle?.contains(self.searchText) ?? false
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2)) {
                ForEach(matchedItems) { group in
                    NavigationLink(value: group) {
                        gridView(groups: group)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 2,
                                   height: UIScreen.main.bounds.width / 2)
                    }
                }
            }
            .navigationDestination(for: Groups.self, destination: { item in
                NavigationDestinationView(groups: item) {
                    popToRoot()
                }
            })
        }
        .fullScreenCover(isPresented: $addNewGroup) {
            addTaskGroupView {
                groups = groupsHelper.getFolder()
            }
        }
        .sheet(isPresented: $comeInfo) {
            CategoryInfoView()
                .presentationDetents([.medium])
        }
        .ignoresSafeArea()
    }
    
    private func popToRoot() {
           path = []
    }
    
    @ViewBuilder
    func gridView(groups: Groups) -> some View {
        if (groups.groupimage == nil) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    //.foregroundColor(taskGroup.category.color.opacity(0.25))
                    .overlay {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white)
                            
                            Text(groups.grouptitle ?? "")
                                .font(.caption)
                             //   .foregroundColor(taskGroup.category.color)
                        }
                        .frame(height: 30)
                        .vAlign(.bottom)
                        
                    }
                    .cornerRadius(20)
                    .shadow(radius: 1)
            }
        }
        
        if (groups.groupimage != nil) {
            ZStack {
                Image(uiImage: UIImage(data: groups.groupimage!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Rectangle())
                    .overlay {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white)
                            
                            Text(groups.grouptitle ?? "")
                                .font(.caption)
                               // .foregroundColor(taskGroup.category.color)
                        }
                        .frame(height: 30)
                        .vAlign(.bottom)
                    }
                    .cornerRadius(20)
                    .shadow(radius: 1)
            }
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


