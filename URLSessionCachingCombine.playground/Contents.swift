import Combine
import Foundation

typealias ShortOutput = URLSession.DataTaskPublisher.Output

extension URLSession {

    func dataTaskPublisher(for url: URL,
                           cachedResponseOnError: Bool) -> AnyPublisher<ShortOutput, Error> {
        return self.dataTaskPublisher(for: url)
            .tryCatch { [weak self] (error) -> AnyPublisher<ShortOutput, Never> in
                guard cachedResponseOnError,
                    let urlCache = self?.configuration.urlCache,
                    let cachedResponse = urlCache.cachedResponse(for: URLRequest(url: url)) else {

                    throw error
                }

                return Just(ShortOutput(
                    data: cachedResponse.data,
                    response: cachedResponse.response
                )).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

let url = URL(string: "https://postman-echo.com/response-headers?Content-Type=text/html&Cache-Control=max-age=3")!
let publisher = URLSession.shared.dataTaskPublisher(for: url, cachedResponseOnError: true)
let token = publisher
    .sink(receiveCompletion: { (completion) in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }) { (responseHandler: URLSession.DataTaskPublisher.Output) in
        if let httpResponse = responseHandler.response as? HTTPURLResponse,
            let date = httpResponse.value(forHTTPHeaderField: "Date"),
            let cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control") {

            print("Request1 date: \(date)")
            print("Request1 Cache Header: \(cacheControl)")
        }
    }

sleep(5)

let token2 = publisher
    .sink(receiveCompletion: { (completion) in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }) { (responseHandler: URLSession.DataTaskPublisher.Output) in
        if let httpResponse = responseHandler.response as? HTTPURLResponse,
            let date = httpResponse.value(forHTTPHeaderField: "Date"),
            let cacheControl = httpResponse.value(forHTTPHeaderField: "Cache-Control") {

            print("Request2 date: \(date)")
            print("Request2 Cache Header: \(cacheControl)")
        }
    }
