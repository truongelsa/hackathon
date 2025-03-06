//
//  SentenceResponse.swift
//  hackathon
//
//  Created by Truong Nguyen on 6/3/25.
//

import Foundation


struct Sentence: Codable, Hashable {
  let sentence: String
  let usedVocabulary: [String]

  enum CodingKeys: String, CodingKey {
    case sentence
    case usedVocabulary = "used_vocabulary"
  }
}

struct SentenceResponse: Codable {
  let sentences: [Sentence]

}
