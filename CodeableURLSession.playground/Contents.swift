import Foundation

extension URLSession {

    enum SessionError: Error {
        case noData
        case statusCode
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

            if let response = response as? HTTPURLResponse,
                (200..<300).contains(response.statusCode) == false {
                completionHandler(nil, response, SessionError.statusCode)
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

            if let response = response as? HTTPURLResponse,
                (200..<300).contains(response.statusCode) == false {
                completionHandler(nil, response, SessionError.statusCode)
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
let task = URLSession.shared.dataTask(with: url, completionHandler: { (users: Users?, response, error) in
    if let error = error {
        print(error.localizedDescription)
        return
    }

    users?.forEach({ print("\($0.name)\n") })
})
task.resume()
