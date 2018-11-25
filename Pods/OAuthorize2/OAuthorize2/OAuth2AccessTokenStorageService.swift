//
//  Copyright © 2018 zalando.de. All rights reserved.
//

import Foundation
import CommonCryptoModule

/// Specifies interface to store and retrieve access token
public protocol OAuth2AccessTokenStorageProtocol {

    func store(token: OAuth2AccessToken, for config: OAuth2Config)
    func retrieve(tokenFor config: OAuth2Config) -> OAuth2AccessToken?
    func delete(tokenFor config: OAuth2Config)

}


struct OAuth2FileBasedAccessTokenStorageService: OAuth2AccessTokenStorageProtocol {

    private let fileManager = FileManager.default

    func store(token: OAuth2AccessToken, for config: OAuth2Config) {
        let encoded = try! JSONEncoder().encode(token)
        let file = fileName(from: config)
        fileManager.createFile(atPath: file, contents: encoded, attributes: nil)
    }

    func retrieve(tokenFor config: OAuth2Config) -> OAuth2AccessToken? {
        let file = fileName(from: config)
        guard fileManager.fileExists(atPath: file) else { return nil }
        guard let data = fileManager.contents(atPath: file) else { return nil }
        let token = try? JSONDecoder().decode(OAuth2AccessToken.self, from: data)
        return token
    }

    func delete(tokenFor config: OAuth2Config) {
        let file = fileName(from: config)
        guard fileManager.fileExists(atPath: file) else { return }
        try? fileManager.removeItem(atPath: file)
    }

    private func fileName(from config: OAuth2Config) -> String {
        let data = try! JSONEncoder().encode(config)
        let shaString = sha256(data: data).base64EncodedString()
        let fileName = String(shaString.dropLast(shaString.count - 8))
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filePath = (documentsPath as NSString).appendingPathComponent(fileName)
        return filePath
    }

    private func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }

}
