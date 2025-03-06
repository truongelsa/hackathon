//
//  SentenceResponse.swift
//  hackathon
//
//  Created by Truong Nguyen on 6/3/25.
//

import Foundation

struct SentenceResponse: Codable {
  let sentences: [Sentence]
  
  struct Sentence: Codable {
    let sentence: String
    let usedVocabulary: [String]
    
    enum CodingKeys: String, CodingKey {
      case sentence
      case usedVocabulary = "used_vocabulary"
    }
  }
}
