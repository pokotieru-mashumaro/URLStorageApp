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
    
    let helper = CoreDataHelper()
    
    //photo関係
    @State var selectedImageData: Data?
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var titleText: String = ""
    @State private var groupColor: GroupColor = GroupColor.gray
    var onAdd: () -> ()
    
    var body: some View {
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
                        .onTapGesture {
                            showImagePicker.toggle()
                        }
                        .hAlign(.center)
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
}

struct addTaskGroupView_Previews: PreviewProvider {
    static var previews: some View {
        addTaskGroupView {
            
        }
    }
}
