//
//  addTaskGroupView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI
import PhotosUI

struct addTaskGroupView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var sceneDelegate: MySceneDelegate
    @Environment(\.dismiss) private var dismiss
    
    private let helper = CoreDataHelper()
    @ObservedObject private var aiHelper = OpenAIHelper()
    @ObservedObject private var reward = Reward()
    enum rewardAlertType {
        case usually
        case rewardError
    }
    @State private var alertType: rewardAlertType = .usually
    @State private var rewardAlert: Bool = false

    //photo関係
    @State private var selectedImageData: Data?
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @State private var imageURL: String = ""
    @State private var loadImage: Bool = false
    
    @State private var titleText: String = ""
    @State private var groupColor: GroupColor = GroupColor.gray
    var onAdd: () -> ()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 30) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .contentShape(Rectangle())
                }
                .padding(.top)
                
                Text("グループ作成")
                    .font(.system(size: 28))
                    .fontWeight(.heavy)
                
                VStack(alignment: .leading, spacing: 20) {
                    TitleView("写真(任意)", .gray)
                    
                    HStack {
                        photoView()
                            .padding(.leading, 10)
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
                            .onTapGesture {
                                showImagePicker.toggle()
                            }
                            .hAlign(.leading)
                        
                        Button {
                            alertType = .usually
                            rewardAlert.toggle()
                            send()
                        } label: {
                            Text("画像自動生成")
                                .font(.callout)
                                .foregroundColor(groupColor.color)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .foregroundColor(groupColor.color.opacity(0.25))
                                }
                        }.onAppear() {
                            reward.loadReward()
                        }.disabled(titleText == "")
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    TitleView("タイトル", .gray)
                    
                    TextField("タイトル（必須）", text: $titleText)
                        .font(.system(size: 16))
                    
                    Rectangle()
                        .fill(.primary.opacity(0.2))
                        .frame(height: 1)
                    
                    TitleView("カラー", .gray)
                        .padding(.top, 15)
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 20), count: 3), spacing: 15) {
                        ForEach(GroupColor.allCases, id: \.rawValue) { color in
                            Text("")
                                .hAlign(.center)
                                .padding(.vertical, 5)
                                .background {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(color.color.opacity(0.25))
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        groupColor = color
                                    }
                                }
                        }
                    }
                    .padding(.top, 5)
                }
                
                Button {
//                    guard reward.rewardLoaded else {
//                        reward.loadReward()
//                        return
//                    }
//                    reward.showReward()
                    let color = groupColor.name
                    helper.groupSave(context: context, title: titleText, color: color, image: selectedImageData)
                    onAdd()
                    dismiss()
                } label: {
                    Text("作成")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(width: 300, height: 50)
                        .foregroundColor(.white)
                        .background {
                            Capsule()
                                .fill(groupColor.color.gradient)
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
            .padding(.horizontal, 15)
            .task {
                aiHelper.initialize()
            }
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
            .overlay {
                VStack {
                    Spacer()
                    if let vc = sceneDelegate.window?.rootViewController {
                        BannerView(viewController: vc, windowScene: sceneDelegate.windowScene)
                            .frame(width: 320, height: 50)
                    }
                }
            }
            .alert(isPresented: $rewardAlert) {
                switch alertType {
                case .usually:
                    return Alert(title: Text("AIによる画像生成を行います"),
                                 message: Text("不適切な単語がある場合、生成できない時があります"),
                                 dismissButton: .default(Text("OK")) {
                    })
                    
                    
                case .rewardError:
                    return Alert(title: Text("生成失敗"),
                          message: Text("タイトルが適切ではない可能性があります"))
                }
            }
            
            if loadImage {
                loadView()
            }
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
                .foregroundColor(groupColor.color.opacity(0.5))
                .foregroundColor(.blue)
        }
    }
    
    @ViewBuilder
    func loadView() -> some View {
        ZStack {
            Color.black.opacity(0.2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea()
            
            Rectangle()
                .foregroundColor(.black.opacity(0.4))
                .frame(width: 80, height: 80)
                .cornerRadius(20)
            
            ProgressView()
        }
    }
    
    func send(){
        loadImage = true
        let promptToSend = titleText
        var withinSeconds: Bool = true
        aiHelper.send(text: promptToSend) { response in
            DispatchQueue.main.async {
                self.imageURL = response.data.first?.url ?? ""
                
                guard let imageURL = URL(string: imageURL) else {
                    print("生成失敗")
                    print("url:", imageURL)
                    loadImage = false
                    withinSeconds = false
                    return
                }
                
                let request = URLRequest(url: imageURL)
                let _ = URLSession.shared.dataTask(with: request) { data, _, _ in
                    self.selectedImageData = data
                    print("生成成功")
                    print("url:", imageURL)
                    loadImage = false
                    withinSeconds = false
                }.resume()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if withinSeconds {
                loadImage = false
                print("タイムアウト")
                alertType = .rewardError
                rewardAlert.toggle()
            }
        }
    }
}

struct addTaskGroupView_Previews: PreviewProvider {
    static var previews: some View {
        addTaskGroupView {
            
        }
    }
}

