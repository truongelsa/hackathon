//
//  WordListResponse.swift
//  hackathon
//
//  Created by Truong Nguyen on 6/3/25.
//

import Foundation

struct WordListResponse: Encodable {
  let context: String
  let imageUrl: String
  let vocabulary: [Vocabulary]
  
  struct Vocabulary: Encodable {
    let definition: String
    let example: String
    let partOfSpeech: String
    let word: String
    
    enum CodingKeys: String, CodingKey {
      case definition
      case example
      case partOfSpeech = "part_of_speech"
      case word
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case context
    case imageUrl = "image_url"
    case vocabulary
  }
}
