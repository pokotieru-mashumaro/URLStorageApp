//
//  tryDALL-E.swift
//  URLStorage
//
//  Created by iniad on 2023/04/07.
//

import SwiftUI
import OpenAIKit

struct tryDALL_E: View {
    @State var typingMessage: String = ""
    @ObservedObject var dalleViewModel = DalleViewModel()
    @Namespace var bottomID
    @FocusState private var fieldIsFocused: Bool
    
    var body: some View {
        NavigationView(){
            VStack(alignment: .leading){
                if !dalleViewModel.messages.isEmpty{
                    ScrollViewReader { reader in
                        ScrollView(.vertical) {
                            ForEach(dalleViewModel.messages.indices, id: \.self){ index in
                                let message = dalleViewModel.messages[index]
                                MessageView(message: message)
                            }
                            Text("").id(bottomID)
                        }
                        .onAppear{
                            withAnimation{
                                reader.scrollTo(bottomID)
                            }
                        }
                        .onChange(of: dalleViewModel.messages.count){ _ in
                            withAnimation{
                                reader.scrollTo(bottomID)
                            }
                        }
                    }
                } else {
                    VStack {
                        Image(systemName: "paintbrush")
                            .font(.largeTitle)
                        Text("Write your first message!")
                            .font(.subheadline)
                            .padding(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                HStack(alignment: .center){
                    TextField("Message...", text: $typingMessage, axis: .vertical)
                        .focused($fieldIsFocused)
                        .padding()
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .onTapGesture {
                            fieldIsFocused = true
                        }
                    Button(action: sendMessage) {
                        Image(systemName: typingMessage.isEmpty ? "circle" : "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(typingMessage.isEmpty ? .white.opacity(0.75) : .white)
                            .frame(width: 20, height: 20)
                            .padding()
                    }
                }
                .onDisappear {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                }
                .background(Color(red: 63/255, green: 66/255, blue: 78/255, opacity: 1))
                .cornerRadius(12)
                .padding([.leading, .trailing, .bottom], 10)
                .shadow(color: .black, radius: 0.5)
            }
            .background(Color(red: 53/255, green: 54/255, blue: 65/255))
            .gesture(TapGesture().onEnded {
                hideKeyboard()
            })
            .navigationTitle("DALL·E 2")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendMessage() {
        guard !typingMessage.isEmpty else { return }
        Task{
            if !typingMessage.trimmingCharacters(in: .whitespaces).isEmpty{
                let tempMessage = typingMessage
                typingMessage = ""
                hideKeyboard()
                await dalleViewModel.generateImage(prompt: tempMessage)
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct tryDALL_E_Previews: PreviewProvider {
    static var previews: some View {
        tryDALL_E()
    }
}



class DalleViewModel: ObservableObject {
    private let apiKey: String
    private var openAI: OpenAI
    @Published var messages = [Message]()
    
    init() {
        apiKey = "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"
        openAI = OpenAI(Configuration(organizationId: "Personal", apiKey: apiKey))
    }
    
    func generateImage(prompt: String) async {
        self.addMessage(prompt, type: .text, isUserMessage: true)
        self.addMessage("", type: .indicator, isUserMessage: false)
        
        let imageParam = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)

        do {
            let result = try await openAI.createImage(parameters: imageParam)
            let b64Image = result.data[0].image
            let output = try openAI.decodeBase64Image(b64Image)
            self.addMessage(output, type: .image, isUserMessage: false)
        } catch {
            print(error)
            self.addMessage(error.localizedDescription, type: .error, isUserMessage: false)
        }
    }
    
    private func addMessage(_ content: Any, type: MessageType, isUserMessage: Bool) {
        DispatchQueue.main.async {
            // if messages list is empty just add new message
            guard let lastMessage = self.messages.last else {
                let message = Message(content: content, type: type, isUserMessage: isUserMessage)
                self.messages.append(message)
                return
            }
            let message = Message(content: content, type: type, isUserMessage: isUserMessage)
            // if last message is an indicator switch with new one
            if lastMessage.type == .indicator && !lastMessage.isUserMessage {
                self.messages[self.messages.count - 1] = message
            } else {
                // otherwise, add new message to the end of the list
                self.messages.append(message)
            }
            
            if self.messages.count > 100 {
                self.messages.removeFirst()
            }
        }
    }
}
