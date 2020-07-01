import UIKit
import Foundation

let url = URL(string: "https://postman-echo.com/response-headers?Content-Type=text/html&Cache-Control=max-age=3")!
let request = URLRequest(url: url)
let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    if let httpResponse = response as? HTTPURLResponse,
        let date = httpResponse.value(forHTTPHeaderField: "Date"),
        let cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control") {

        print("Request1 date: \(date)")
        print("Request1 Cache Header: \(cacheControl)")
    }
}
task.resume()

sleep(5)

let task2 = URLSession.shared.dataTask(with: url) { (data , response, error) in
    if let httpResponse = response as? HTTPURLResponse,
        let date = httpResponse.value(forHTTPHeaderField: "Date"),
        let cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control") {

        print("Request2 date: \(date)")
        print("Request2 Cache Header: \(cacheControl)")
    }

    if let error = error {
        print(error.localizedDescription)

        if let cachedResponse = URLSession.shared.configuration.urlCache?.cachedResponse(for: request),
            let httpResponse = cachedResponse.response as? HTTPURLResponse,
            let date = httpResponse.value(forHTTPHeaderField: "Date") {

            print("cached: \(date)")
        }
    }
}
task2.resume()

extension URLSession {
    /// Wraps the standard dataTask function to take an additional parameter. If cachedResponseOnError is set to true
    /// the function will attempt to return a cached response from the URLCache in the event of a network error
    /// - Parameters:
    ///   - url: URL to be retrieved
    ///   - cachedResponseOnError: Whether we should attempt to load a cached response if the request fails
    ///   - completionHandler: completionHandler to be called once the request is finished
    /// - Returns: URLSessionDataTask to manage the request

    // 1
    func dataTask(with url: URL,
                  cachedResponseOnError: Bool,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        return self.dataTask(with: url) { (data, response, error) in
            // 2
            if cachedResponseOnError,
                let error = error,
                let cachedResponse = self.configuration.urlCache?.cachedResponse(for: URLRequest(url: url)) {

                completionHandler(cachedResponse.data, cachedResponse.response, error)
                return
            }

            // 3
            completionHandler(data, response, error)
        }
    }

    func dataTask(with urlRequest: URLRequest,
                  cachedResponseOnError: Bool,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        return self.dataTask(with: urlRequest) { (data, response, error) in
            // 2
            if cachedResponseOnError,
                let error = error,
                let cachedResponse = self.configuration.urlCache?.cachedResponse(for: urlRequest) {

                completionHandler(cachedResponse.data, cachedResponse.response, error)
                return
            }

            // 3
            completionHandler(data, response, error)
        }
    }
}
