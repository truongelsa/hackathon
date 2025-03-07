import Foundation

class FileUploadService {
  
  func uploadPhoto(data: Data, completion: @escaping (Result<(URLResponse, Data?), Error>) -> Void) {
    guard let url = URL(string: "http://52.7.92.246:8000/api/v1/images/upload") else {
      completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
      return
    }

    let boundary = "Boundary-\(UUID().uuidString)"
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()
    let filename = "debug_001.png"
    let mimetype = "image/png"
    
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
    body.append(data)
    body.append("\r\n".data(using: .utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    let task = URLSession.shared.uploadTask(with: request, from: body) { responseData, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response from server"])))
        return
      }
      
      print("Status code: \(httpResponse.statusCode)")
      
      if let responseData = responseData {
        if let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) {
          print("JSON Response: \(jsonResponse)")
        } else {
          print("Failed to parse JSON response")
        }
      } else {
        print("No response data received")
      }
      
      completion(.success((httpResponse, responseData)))
    }
    
    task.resume()
  }
  
  func generateSentenceFromWord(_ word: [String], context: String, completion: @escaping (Result<(URLResponse, Data?), Error>) -> Void) {
    // API Endpoint
    guard let url = URL(string: "http://52.7.92.246:8000/api/v1/sentences/generate") else {
      completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
      return
    }
    
    // JSON Body
    let requestBody: [String: Any] = [
      "words": word,
      "context": context,
      "count": 1,
    ]
    
    
    // Convert request body to JSON data
    guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
      completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"])))
      return
    }
    
    // Create URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    // Perform network request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let response = response else {
        completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "No response received"])))
        return
      }
      
      // Print JSON Response
      if let data = data {
        do {
          let jsonObject = try JSONSerialization.jsonObject(with: data)
          print("JSON Response:\n", jsonObject)
        } catch {
          print("Failed to parse JSON response: \(error)")
        }
      } else {
        print("No response data received")
      }
      
      // Return response and data
      completion(.success((response, data)))
    }
    
    task.resume()
  }

  func uploadAudio(filePath: URL, completion: @escaping (String?, String?) -> Void) {
    // Correct API Endpoint
    guard let url = URL(string: "http://52.7.92.246:8000/api/v1/audio/analyze") else {      
      completion(nil, nil)
      return
    }
    
    // Create URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "accept")
    
    // Read the audio file data
//    let fileUrl = URL(fileURLWithPath: filePath)
    let fileUrl = filePath
    guard let audioData = try? Data(contentsOf: fileUrl) else {
      completion(nil, nil)
      return
    }
    
    // Construct Multipart Form Data Body
    var body = Data()
    let filename = fileUrl.lastPathComponent
    let mimetype = "audio/mpeg"
    
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
    body.append(audioData)
    body.append("\r\n".data(using: .utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    
    // Perform the request
    let task = URLSession.shared.uploadTask(with: request, from: body) { responseData, response, error in
      if let error = error {
        completion(nil, nil)
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(nil, nil)
        return
      }
      
      // Print JSON Response
      if let responseData = responseData {
        if let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) {
          print("JSON Response: \(jsonResponse)")
          if let jsonDict = jsonResponse as? [String: Any] {
            var matchPercentageString: String?
            var feedbackText: String?

            if let matchPercentage = jsonDict["match_percentage"] {
                if let matchPercentageInt = matchPercentage as? Int {
                    matchPercentageString = String(matchPercentageInt)
                } else if let matchPercentageDouble = matchPercentage as? Double {
                    matchPercentageString = String(matchPercentageDouble)
                } else if let matchPercentageStr = matchPercentage as? String {
                    matchPercentageString = matchPercentageStr
                }
            }
            feedbackText = jsonDict["feedback"] as? String
            completion(matchPercentageString, feedbackText)
          }
        }
        print("Failed to parse JSON response")
        completion(nil, nil)
      }
    }
    
    task.resume()
  }


}
