//
//  WordListResponse.swift
//  hackathon
//
//  Created by Truong Nguyen on 6/3/25.
//

import Foundation

struct WordListResponse: Codable {
  let context: String
  let vocabulary: [Vocabulary]
  
  struct Vocabulary: Codable {
    let definition: String
    let example: String
    let word: String
    
    enum CodingKeys: String, CodingKey {
      case definition
      case example      
      case word
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case context
    case vocabulary
  }
}

