//
//  EditGroupView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/12.
//

import SwiftUI
import PhotosUI

struct EditGroupView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) private var dismiss
    
    let helper = CoreDataHelper()
    
    let group: Groups
    var onEdit: () -> ()
    //photo関係
    @State var selectedImageData: Data?
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    
    @State var titleText: String = ""
    @State var groupColor: GroupColor = GroupColor.gray
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("グループ作成")
                .font(.system(size: 28))
                .fontWeight(.heavy)
                .foregroundColor(.black)
            
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
                    .fill(.black.opacity(0.2))
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
                helper.groupEdit(context: context, group: group, title: titleText, color: groupColor.name, image: selectedImageData)
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
                            .fill(groupColor.color.gradient)
                    }
            }
            .padding(.bottom)
            .hAlign(.center)
            .vAlign(.bottom)
            .disabled(titleText == "")
            .opacity(titleText == "" ? 0.6 : 1)
        }
        .onAppear {
            titleText = group.grouptitle ?? ""
            selectedImageData = group.groupimage
            groupColor = getGroupColor(color: group.color ?? "")
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

struct EditGroupView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
