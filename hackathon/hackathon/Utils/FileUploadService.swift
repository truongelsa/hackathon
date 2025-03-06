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
}
