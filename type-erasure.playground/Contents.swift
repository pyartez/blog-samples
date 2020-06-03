import UIKit

// User Model
struct User {
    let id: Int
    let name: String
}

// Our Fetchable protocol
protocol Fetchable {
    associatedtype FetchType

    func fetch(completion: ((Result<FetchType, Error>) -> Void)?)
}

// Implementing fetchable to return a user
struct UserFetch: Fetchable {
    typealias FetchType = User

    func fetch(completion: ((Result<FetchType, Error>) -> Void)?) {
        let user = User(id: 1, name: "Phil")
        completion?(.success(user))
    }
}

// Our struct that wants to hold a reference to our user fetchable
struct SomeStruct {
    let userFetch: AnyFetchable<User>
}

// Our any class that uses type erasure to hide the class that has implemented the protocol
struct AnyFetchable<T>: Fetchable {
    typealias FetchType = T

    private let _fetch: (((Result<T, Error>) -> Void)?) -> Void

    init<U: Fetchable>(_ fetchable: U) where U.FetchType == T {
        _fetch = fetchable.fetch
    }

    func fetch(completion: ((Result<T, Error>) -> Void)?) {
        _fetch(completion)
    }
}

// Example implementation
let userFetch = UserFetch()
let anyFetchable = AnyFetchable<User>(userFetch)
let someStruct = SomeStruct(userFetch: anyFetchable)

someStruct.userFetch.fetch { (result) in
    switch result {
    case .success(let user):
        print(user.name)
    case .failure(let error):
        print(error)
    }
}

// New Dave user struct
struct DaveFetch: Fetchable {
    typealias FetchType = User

    func fetch(completion: ((Result<FetchType, Error>) -> Void)?) {
        let user = User(id: 2, name: "Dave")
        completion?(.success(user))
    }
}

// Example implementation 2
let daveFetch = DaveFetch()
let anyDaveFetchable = AnyFetchable<User>(daveFetch)
let someDaveStruct = SomeStruct(userFetch: anyDaveFetchable)

someDaveStruct.userFetch.fetch { (result) in
    switch result {
    case .success(let user):
        print(user.name)
    case .failure(let error):
        print(error)
    }
}


// Product Type
struct Product {
    let id: Int
    let title: String
    let price: String
}

struct ProductFetch: Fetchable {
    typealias FetchType = Product

    func fetch(completion: ((Result<FetchType, Error>) -> Void)?) {
        let product = Product(id: 1, title: "My Product", price: "10.99")
        completion?(.success(product))
    }
}

let productFetch = ProductFetch()
let anyProductFetch = AnyFetchable<Product>(productFetch)
anyProductFetch.fetch { (result) in
    switch result {
    case .success(let product):
        print(product.title)
    case .failure(let error):
        print(error)
    }
}
