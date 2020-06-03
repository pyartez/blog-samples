import Foundation
import Combine

extension URLSession {

    /// Result struct containing the processing data and url response
    struct Result<T> {
        let data: T
        let response: URLResponse
    }


    /// Function that wraps the existing dataTaskPublisher method and attempts to decode the result and publish it
    /// - Parameter request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on
    /// - Returns: Publisher that sends a URLSession.Result if the response can be decoded correctly.
    func dataTaskPublisher<T: Decodable>(for request: URLRequest) -> AnyPublisher<URLSession.Result<T>, Error> {
        return self.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> URLSession.Result<T> in
                let data = try JSONDecoder().decode(T.self, from: data)
                return URLSession.Result(data: data, response: response)
            }
            .eraseToAnyPublisher()
    }

    /// Function that wraps the existing dataTaskPublisher method and attempts to decode the result and publish it
    /// - Parameter url: The URL to be retrieved.
    /// - Returns: Publisher that sends a URLSession.Result if the response can be decoded correctly.
    func dataTaskPublisher<T: Decodable>(for url: URL) -> AnyPublisher<URLSession.Result<T>, Error> {
        return self.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> URLSession.Result<T> in
                let data = try JSONDecoder().decode(T.self, from: data)
                return URLSession.Result(data: data, response: response)
            }
            .eraseToAnyPublisher()
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
let token = (URLSession.shared.dataTaskPublisher(for: url) as AnyPublisher<URLSession.Result<Posts>, Error>)
    .sink(receiveCompletion: { (completion) in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }) { (result) in
        result.data.forEach({ print("\($0.title)\n") })
    }

