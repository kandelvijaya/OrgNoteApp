<img src="./icon.png">

# Kekka
## Implemented Features
### Result<T>
- Abstraction on types that can fail (Contextual types i.e Network result)
    ```swift
        enum MathError: Error {
        case cannotDivideByZero
      }

      func divide(item: Int, by: Int) -> Result<Double> {
          if by == 0 { return .failure(error: MathError.cannotDivideByZero) }
          return .success(value: Double(item / by))
      }
    ```
- provides `map` and `flatMap` (i.e. `bind`)
    ```swift
      /// map [Functor]
      divide(item: 12, by: 0).map { $0 * 2 }  // still .failure(.cannotDivideByZero)
      divide(item: 12, by: 6).map { $0 * 2 }  // .success(4)

      /// flatMap | bind [Monad]
      divide(item: 12, by: 6).flatMap { divide(item: Int($0), by: 2) }  // .success(1)
    ```
### Future<T>
- Abstraction over async tasks and nested callbacks (i.e. animation,
      networking, reading file)

    ```swift
      final class Network {

          public enum NetworkError: Error {
              case unknown
          }

          /// This is a much better way of wrapping network calls. 
          public func get(from url: URL) -> Future<Result<Data>> {
              return Future { aCompletion in
                  let session = URLSession(configuration: .default)
                  let dataTask = session.dataTask(with: url) { (data, response, error) in
                      if let d = data, error == nil {
                          aCompletion?(.success(value: d))
                      } else if let e = error {
                          aCompletion?(.failure(error: e))
                      } else {
                          aCompletion?(.failure(error: NetworkError.unknown))
                      }
                  }
                  dataTask.resume()
              }
          }

      }
    ```
- provides `map`(i.e. `then`)  and `flatMap` (i.e `bind`)
  
    ```swift
    /// This allows one to reason code in linear way without the threading involved. 
    let url = URL(string: "https://www.kandelvijaya.com")!
    Network().get(from: url).map { transformToModel($0) }   // produces Future<Result<[XModel]>>
                            .map { viewModels(from: $0) }   // produces Future<Result<[XViewModel]>>
                            .execute()

    /// This allows one to chain multiple future/async task into a linear way
    Network().get(from: url).map { extractUrls($0).first }   // gets first external url
                            .flatMap { Network().get(from: $0) }  // gets data from that url 
                            .map { transformToModel($0) }  // produces Future<Result<XViewModel>>
                            .execute()
    ```
- Result and Future can work seemlessy enabling elegant code which is both easy to reason.
      The same technique can be used for chaining animations, IO and side effect programming.

## To be implemented 
### IO
- Abstraction over impure compuatation (capturing side effects)
## Contribution Policy
   - Syntatic sugar and fancy extension without fundamental proof are not what
     this minimalistic library strives for
   - Else, feel free to create issue or pull request.
