//
//  FileUploadService.swift
//  hackathon
//
//  Created by Truong Nguyen on 6/3/25.
//

import Foundation

class FileUploadService {
  
  func uploadPhoto(data: Data, completion: @escaping (Result<URLResponse, Error>) -> Void) {
    guard let url = URL(string: "http://52.7.92.246:8000/api/v1/images/upload") else {
      completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let response = response else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response from server"])))
        return
      }
      
      completion(.success(response))
    }
    
    task.resume()
  }
}
