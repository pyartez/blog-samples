import UIKit
import Combine

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

let url = URL(string: "https://jsonplaceholder.typicode.com/users/1")!
let task = URLSession.shared.dataTask(with: url, completionHandler: { (user: User?, response, error) in
    if let error = error {
        print(error.localizedDescription)
        return
    }

    if let user = user {
        print(user.name)
        print(user.address.street)
        print(user.address.city)
        print(user.address.zipcode)
        print(user.address.geo.lat)
        print(user.address.geo.lng)
    }
})
task.resume()

/* ======================================================= */

// MARK: - Users
struct Users: Codable {
    let results: [Result]
    let info: Info
}

// MARK: - Info
struct Info: Codable {
    let seed: String
    let results, page: Int
    let version: String
}

// MARK: - Result
struct Result: Codable {
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let login: Login
    let dob, registered: Dob
    let phone, cell: String
    let id: ID
    let picture: Picture
    let nat: String
}

// MARK: - Dob
struct Dob: Codable {
    let date: String
    let age: Int
}

// MARK: - ID
struct ID: Codable {
    let name: String
    let value: String?
}

// MARK: - Location
struct Location: Codable {
    let street: Street
    let city, state, country: String
    let postcode: Int
    let coordinates: Coordinates
    let timezone: Timezone
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let latitude, longitude: String
}

// MARK: - Street
struct Street: Codable {
    let number: Int
    let name: String
}

// MARK: - Timezone
struct Timezone: Codable {
    let offset, timezoneDescription: String

    enum CodingKeys: String, CodingKey {
        case offset
        case timezoneDescription = "description"
    }
}

// MARK: - Login
struct Login: Codable {
    let uuid, username, password, salt: String
    let md5, sha1, sha256: String
}

// MARK: - Name
struct Name: Codable {
    let title, first, last: String
}

// MARK: - Picture
struct Picture: Codable {
    let large, medium, thumbnail: String
}

let url2 = URL(string: "https://randomuser.me/api/")!
let task2 = URLSession.shared.dataTask(with: url2, completionHandler: { (users: Users?, response, error) in
    if let error = error {
        print(error.localizedDescription)
        return
    }

    if let user = users?.results.first {
        print("\(user.name.first) \(user.name.last)")
        print(user.location.street.name)
        print(user.location.city)
        print(user.location.postcode)
        print(user.location.coordinates.latitude)
        print(user.location.coordinates.longitude)
    }
})
task2.resume()


/* ======================================================= */

struct DomainUser {
    let name: String
    let street: String
    let city: String
    let postcode: String
    let latitude: String
    let longitude: String
}

/* ======================================================= */

protocol Repository {
    associatedtype T
    
    func get(id: Int, completionHandler: @escaping (T?, Error?) -> Void)
    func list(completionHandler: @escaping ([T]?, Error?) -> Void)
    func add(_ item: T, completionHandler: @escaping (Error?) -> Void)
    func delete(_ item: T, completionHandler: @escaping (Error?) -> Void)
    func edit(_ item: T, completionHandler: @escaping (Error?) -> Void)
}

protocol CombineRepository {
    associatedtype T
    
    func get(id: Int) -> AnyPublisher<T, Error>
    func list() -> AnyPublisher<[T], Error>
    func add(_ item: T) -> AnyPublisher<Void, Error>
    func delete(_ item: T) -> AnyPublisher<Void, Error>
    func edit(_ item: T) -> AnyPublisher<Void, Error>
}

enum RepositoryError: Error {
    case notFound
}

struct FirstRequestImp: Repository {
    typealias T = DomainUser
    
    func get(id: Int, completionHandler: @escaping (DomainUser?, Error?) -> Void) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users/1")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (user: User?, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }

            guard let user = user else {
                completionHandler(nil, RepositoryError.notFound)
                return
            }
            
            let domainUser = DomainUser(
                name: user.name,
                street: user.address.street,
                city: user.address.city,
                postcode: user.address.zipcode,
                latitude: user.address.geo.lat,
                longitude: user.address.geo.lng
            )
            
            completionHandler(domainUser, nil)
        })
        task.resume()
    }
    
    func list(completionHandler: @escaping ([DomainUser]?, Error?) -> Void) {}
    func add(_ item: DomainUser, completionHandler: @escaping (Error?) -> Void) {}
    func delete(_ item: DomainUser, completionHandler: @escaping (Error?) -> Void) {}
    func edit(_ item: DomainUser, completionHandler: @escaping (Error?) -> Void) {}
}

struct SecondRequestImp: Repository {
    typealias T = DomainUser
    
    func get(id: Int, completionHandler: @escaping (DomainUser?, Error?) -> Void) {
        let url = URL(string: "https://randomuser.me/api/")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (users: Users?, response, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }

            guard let user = users?.results.first else {
                completionHandler(nil, RepositoryError.notFound)
                return
            }
            
            let domainUser = DomainUser(
                name: "\(user.name.first) \(user.name.last)",
                street: user.location.street.name,
                city: user.location.city,
                postcode: "\(user.location.postcode)",
                latitude: user.location.coordinates.latitude,
                longitude: user.location.coordinates.longitude
            )
            
            completionHandler(domainUser, nil)
        })
        task.resume()
    }
    
    func list(completionHandler: @escaping ([DomainUser]?, Error?) -> Void) {}
    func add(_ item: DomainUser, completionHandler: @escaping (Error?) -> Void) {}
    func delete(_ item: DomainUser, completionHandler: @escaping (Error?) -> Void) {}
    func edit(_ item: DomainUser, completionHandler: @escaping (Error?) -> Void) {}
}

/* ======================================================= */

let repository: FirstRequestImp = FirstRequestImp()
repository.get(id: 1) { (user, error) in
    if let error = error {
        print(error)
    }
    
    if let user = user {
        print(user.name)
        print(user.street)
        print(user.city)
        print(user.postcode)
        print(user.latitude)
        print(user.longitude)
    }
}

let repository2: SecondRequestImp = SecondRequestImp()
repository2.get(id: 1) { (user, error) in
    if let error = error {
        print(error)
    }

    if let user = user {
        print(user.name)
        print(user.street)
        print(user.city)
        print(user.postcode)
        print(user.latitude)
        print(user.longitude)
    }
}
