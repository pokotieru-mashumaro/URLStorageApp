//
//  addTaskView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI
import PhotosUI

struct addTaskView: View {
    let groups: Groups
    var onNext: () -> ()
    private let helper = CoreDataHelper()
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var sceneDelegate: MySceneDelegate
    @Environment(\.dismiss) private var dismiss
    
    //photo関係
    @State private var selectedImageData: Data?
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    
    @State private var titleText: String = ""
    @State private var articleText: String = ""
    
    @State private var urlFlag: Bool = false
    @State private var feelingFlag: Bool = false
    @State private var urlText: String = ""
    @State private var feelingText: String = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                }
                .padding(.top)
                
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
                                .foregroundColor(getColor(color: groups.color ?? "").opacity(0.5))
                                .padding(.leading, 10)
                                .onTapGesture {
                                    showImagePicker.toggle()
                                }
                        } else {
                            photoView()
                                .overlay {
                                    if selectedImageData != nil {
                                        Button {
                                            photoItem = nil
                                            selectedImageData = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 20))
                                        }
                                        .hAlign(.trailing)
                                        .vAlign(.top)
                                    }
                                }
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
                    
                    Toggle("URL", isOn: $urlFlag)
                        .fontWeight(.bold)
                        .toggleStyle(SwitchToggleStyle(tint: getColor(color: groups.color ?? "")))
                    
                    if urlFlag {
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
                                    .background(getColor(color: groups.color ?? ""))
                                    .cornerRadius(10)
                            }
                        }
                        Rectangle()
                            .fill(.primary.opacity(0.2))
                            .frame(height: 1)
                    }
                    
                    Toggle("コメント", isOn: $feelingFlag)
                        .fontWeight(.bold)
                        .toggleStyle(SwitchToggleStyle(tint: getColor(color: groups.color ?? "")))

                    if feelingFlag {
                        TextEditor(text: $articleText)
                            .scrollContentBackground(Visibility.hidden)
                            .background(getColor(color: groups.color ?? "").opacity(0.3))
                            .foregroundColor(Color.black)
                            .hAlign(.center)
                            .frame(height: 250)
                            .cornerRadius(25)
                    }
                }
                
                Button {
                    helper.itemSave(context: context, title: titleText, image: selectedImageData, url: urlText, impression: articleText, group: groups)
                    onNext()
                    dismiss()
                } label: {
                    Text("作成")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 300, height: 50)
                        .foregroundColor(.white)
                        .background {
                            Capsule()
                                .fill(getColor(color: groups.color ?? "") .gradient)
                            
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
                //ペーストボタン
                NotificationCenter.default.addObserver(forName: UIPasteboard.changedNotification, object: UIPasteboard.general, queue: .main) { notification in
                    if let pasteboardString = UIPasteboard.general.string, pasteboardString.contains("http") {
                        self.urlText = pasteboardString
                    }
                }
            }
            .padding(.horizontal, 15)
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
                .foregroundColor(getColor(color: groups.color ?? "").opacity(0.5))
        }
    }
}

struct addTaskView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

