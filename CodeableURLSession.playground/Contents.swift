import Foundation

extension URLSession {

    enum SessionError: Error {
        case noData
    }

    /// Wraps the standard dataTask method with a JSON decode attempt using the passed generic type.
    /// Throws an error if decoding fails
    /// - Parameters:
    ///   - url: The URL to be retrieved.
    ///   - completionHandler: The completion handler to be called once decoding is complete / fails
    /// - Returns: The new session data task
    func dataTask<T: Decodable>(with url: URL,
                                completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        return self.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, response, error)
                return
            }

            guard let data = data else {
                completionHandler(nil, response, SessionError.noData)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completionHandler(decoded, response, nil)
            } catch(let error) {
                completionHandler(nil, response, error)
            }
        }
    }


    /// Wraps the standard dataTask method with a JSON decode attempt using the passed generic type.
    /// Throws an error if decoding fails
    /// - Parameters:
    ///   - urlRequest: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on
    ///   - completionHandler: The completion handler to be called once decoding is complete / fails
    /// - Returns: The new session data task
    func dataTask<T: Decodable>(with urlRequest: URLRequest,
                                completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        return self.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, response, error)
                return
            }

            guard let data = data else {
                completionHandler(nil, response, SessionError.noData)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completionHandler(decoded, response, nil)
            } catch(let error) {
                completionHandler(nil, response, error)
            }
        }
    }
}

/* ======================================================= */

struct Post: Codable {
    let userID, id: Int
    let title, body: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title, body
    }
}

typealias Posts = [Post]

let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
let task = URLSession.shared.dataTask(with: url, completionHandler: { (posts: Posts?, response, error) in
    if let error = error {
        print(error.localizedDescription)
        return
    }

    posts?.forEach({ print("\($0.title)\n") })
})
task.resume()
