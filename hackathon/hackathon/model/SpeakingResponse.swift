//
//  SpeakingResponse.swift
//  hackathon
//
//  Created by Truong Nguyen on 7/3/25.
//

import Foundation
struct SpeakingResponse: Codable, Hashable {
  let matchPercentage: String
    
  enum CodingKeys: String, CodingKey {
    case matchPercentage = "match_percentage"
  }
}
