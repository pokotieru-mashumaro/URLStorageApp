//
//  EditItemView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/12.
//

import SwiftUI
import PhotosUI

struct EditItemView: View {
    let groupItem: GroupItem
    var onEdit: () -> ()
    let helper = CoreDataHelper()
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var sceneDelegate: MySceneDelegate
    @Environment(\.dismiss) private var dismiss
    
    //photo関係
    @State var selectedImageData: Data?
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var titleText: String = ""
    @State var urlText: String = ""
    @State var articleText: String = ""
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    Text("内容作成")
                        .font(.system(size: 28))
                        .fontWeight(.heavy)
                    
                    Spacer()
                    
                    Text(dateToString(date: Date()))
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 30) {
                        if selectedImageData == nil {
                            AddOrEditVideoThumbnailView(url: $urlText)
                                .foregroundColor(getColor(color: groupItem.group?.color ?? "").opacity(0.5))
                                .padding(.leading, 10)
                                .onTapGesture {
                                    showImagePicker.toggle()
                                }
                        } else {
                            photoView()
                        }
                        
                        VStack {
                            TitleView("タイトル", .gray)
                                .hAlign(.leading)
                            
                            TextField("タイトル（必須）", text: $titleText)
                                .font(.system(size: 16))
                            
                            Rectangle()
                                .fill(.primary.opacity(0.2))
                                .frame(height: 1)
                        }
                    }
                    
                    TitleView("詳細（任意）", .gray)
                        .padding(.top, 15)
                    
                    TitleView("URL", .gray)
                        .hAlign(.leading)
                    
                    HStack {
                        TextField("URL", text: $urlText)
                            .keyboardType(.URL)
                        
                        Button(action: {
                            if let pasteboardString = UIPasteboard.general.string {
                                self.urlText = pasteboardString
                            }
                        }) {
                            Text("ペースト")
                                .foregroundColor(Color.white)
                                .font(.caption2)
                                .padding(10)
                                .background(getColor(color: groupItem.group?.color ?? ""))
                                .cornerRadius(10)
                        }
                    }
                    
                    Rectangle()
                        .fill(.primary.opacity(0.2))
                        .frame(height: 1)
                    
                    TitleView("コメント", .gray)
                        .hAlign(.leading)
                    
                    TextEditor(text: $articleText)
                        .scrollContentBackground(Visibility.hidden)
                        .background(getColor(color: groupItem.group?.color ?? "").opacity(0.3))
                        .foregroundColor(Color.black)
                        .hAlign(.center)
                        .frame(height: 250)
                        .cornerRadius(25)
                    
                }
                
                Button {
                    helper.itemEdit(context: context, item: groupItem, title: titleText, image: selectedImageData, url: urlText, impression: articleText)
                    onEdit()
                    dismiss()
                } label: {
                    Text("編集")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 300, height: 50)
                        .foregroundColor(.white)
                        .background {
                            Capsule()
                                .fill(getColor(color: groupItem.group?.color ?? "").gradient)
                            
                        }
                }
                .padding(.bottom)
                .hAlign(.center)
                .vAlign(.bottom)
                .disabled(titleText == "")
                .opacity(titleText == "" ? 0.6 : 1)
                
                Text("")
                    .padding(.bottom, 40)
                
            }
            .onAppear {
                titleText = groupItem.itemtitle ?? ""
                selectedImageData = groupItem.itemimage
                urlText = groupItem.url ?? ""
                articleText = groupItem.impression ?? ""
                
                //ペーストボタン
                NotificationCenter.default.addObserver(forName: UIPasteboard.changedNotification, object: UIPasteboard.general, queue: .main) { notification in
                    if let pasteboardString = UIPasteboard.general.string, pasteboardString.contains("http") {
                        self.urlText = pasteboardString
                    }
                }
            }
            .padding(15)
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem) { newvalue in
                if let newvalue {
                    Task {
                        do {
                            guard let imageData = try await newvalue.loadTransferable(type: Data.self) else { return }
                            //MARK: UI Must Be Updated on Main Thread
                            await MainActor.run(body: {
                                selectedImageData = imageData
                            })
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
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
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    @ViewBuilder
    func TitleView(_ value: String, _ color: Color = .white.opacity(0.7)) -> some View {
        Text(value)
            .font(.system(size: 12))
            .foregroundColor(color)
    }
    
    @ViewBuilder
    func photoView() -> some View {
        if let selectedImageData,
           let image = UIImage(data: selectedImageData) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 85, height: 85)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
        } else {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 85, height: 85)
                .foregroundColor(getColor(color: groupItem.group?.color ?? "").opacity(0.5))
            
        }
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
