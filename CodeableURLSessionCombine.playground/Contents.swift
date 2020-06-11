import Foundation
import Combine

//extension
extension URLSession {
    enum SessionError: Error {
        case statusCode(HTTPURLResponse)
    }

    /// Function that wraps the existing dataTaskPublisher method and attempts to decode the result and publish it
    /// - Parameter request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on
    /// - Returns: Publisher that sends a URLSession.Result if the response can be decoded correctly.
    func dataTaskPublisher<T: Decodable>(for request: URLRequest) -> AnyPublisher<T, Error> {
        return self.dataTaskPublisher(for: request)
            .tryMap({ (data, response) -> Data in
                if let response = response as? HTTPURLResponse,
                    (200..<300).contains(response.statusCode) == false {
                    throw SessionError.statusCode(response)
                }

                return data
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /// Function that wraps the existing dataTaskPublisher method and attempts to decode the result and publish it
    /// - Parameter url: The URL to be retrieved.
    /// - Returns: Publisher that sends a URLSession.Result if the response can be decoded correctly.
    func dataTaskPublisher<T: Decodable>(for url: URL) -> AnyPublisher<T, Error> {
        return self.dataTaskPublisher(for: url)
            .tryMap({ (data, response) -> Data in
                if let response = response as? HTTPURLResponse,
                    (200..<300).contains(response.statusCode) == false {
                    throw SessionError.statusCode(response)
                }

                return data
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

/* ======================================================= */

// MARK: - User
struct User: Codable {
    let id: Int
    let name, username, email: String
    let address: Address
    let phone, website: String
    let company: Company
}

// MARK: - Address
struct Address: Codable {
    let street, suite, city, zipcode: String
    let geo: Geo
}

// MARK: - Geo
struct Geo: Codable {
    let lat, lng: String
}

// MARK: - Company
struct Company: Codable {
    let name, catchPhrase, bs: String
}

typealias Users = [User]

let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
let token = URLSession.shared.dataTaskPublisher(for: url)
    .sink(receiveCompletion: { (completion) in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }) { (users: Users) in
        users.forEach({ print("\($0.name)\n") })
    }

