//
//  OpenAIHelper.swift
//  URLStorage
//
//  Created by iniad on 2023/03/27.
//

import SwiftUI
import OpenAI

final class OpenAIHelper: ObservableObject {
    
    init(){
    }
    
    private var client: OpenAI?

    func initialize(){
        client = OpenAI(apiToken: "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")
    }

    func send(text: String, completion: @escaping (OpenAI.ImagesResult) -> Void ) {
        let query = OpenAI.ImagesQuery(prompt: text, n: 1, size: "1024x1024")
        client?.images(query: query) { result in
            switch result {
            case .success(let success):
                let output = success.self
                completion(output)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


struct ImagesResult: Codable {
    public struct URLResult: Codable {
        public let url: String
    }
    public let created: TimeInterval
    public let data: [URLResult]
}

