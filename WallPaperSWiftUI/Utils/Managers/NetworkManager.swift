//
//  NetworkManager.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/02/26.
//

import Foundation
import Alamofire
import UIKit

struct NetworkManager {
    
    static func cancelRequest(url: String) {
        AF.session.getAllTasks { tasks in
            let task = tasks.first(where: { $0.currentRequest?.url?.absoluteString == url })
            task?.cancel()
        }
    }
    
    static func cancelAllRequests() {
        AF.cancelAllRequests()
    }
    
    // MARK: - General Web Service Caller
    static func callWebService<T: Codable>(
        url: String,
        httpMethod: HTTPMethod = .get,
        params: [String: Any] = [:],
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders = ["Authorization" : WebService.bearerToken],
        callbackSuccess: @escaping (T) -> (),
        callbackFailure: @escaping (_ err: Error) -> () = { _ in }
    ) {
        AF.request(url,
                   method: httpMethod,
                   parameters: params,
                   encoding: encoding,
                   headers: headers)
        .responseString { response in
            print("==================================================================")
            print("Request URL:", response.request?.url?.absoluteString ?? "")
            print("Method:", httpMethod.rawValue)
            print("Headers:", headers)
            print("Parameters:", params)
            print("Time Duration in second:", response.metrics?.taskInterval.duration ?? 0)
            response.value.decode(callbackSuccess: callbackSuccess, callbackFailure: callbackFailure)
        }
    }
    
    // MARK: - File Upload Web Service
    static func callWebServiceWithFiles<T: Codable>(
        url: String,
        params: [String: Any] = [:],
        headers: HTTPHeaders = [:],
        callbackSuccess: @escaping (T) -> (),
        callbackFailure: @escaping (_ err: Error) -> () = { _ in }
    ) {
        AF.upload(multipartFormData: { multipartFormData in
            params.forEach { (key, value) in
                if let urls = value as? [URL] {
                    urls.forEach { fileURL in
                        multipartFormData.append(fileURL,
                                                 withName: key,
                                                 fileName: "file.\(fileURL.pathExtension)",
                                                 mimeType: mimeType(for: fileURL.pathExtension))
                    }
                } else if let images = value as? [UIImage] {
                    images.forEach { image in
                        if let data = image.jpegData(compressionQuality: 1.0) {
                            multipartFormData.append(data,
                                                     withName: key,
                                                     fileName: "image.jpg",
                                                     mimeType: "image/jpeg")
                        }
                    }
                } else {
                    if let data = "\(value)".data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
        }, to: url, headers: headers)
        .uploadProgress { progress in
            print("Upload Progress:", progress.fractionCompleted)
        }
        .responseString { response in
            print("==================================================================")
            print("Request URL:", response.request?.url?.absoluteString ?? "")
            print("Headers:", headers)
            print("Parameters:", params)
            print("Time Duration in second:", response.metrics?.taskInterval.duration ?? 0)
            
            response.value.decode(callbackSuccess: callbackSuccess, callbackFailure: callbackFailure)
        }
    }
    
    // Helper: MIME type resolver
    private static func mimeType(for pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        default: return "application/octet-stream"
        }
    }
}

// MARK: - Extensions
extension Optional where Wrapped == String {
    func decode<T: Codable>(callbackSuccess: @escaping (T) -> (), callbackFailure: @escaping (_ err: Error) -> ()) {
        guard let value = self else { return }
        if let data = value.data(using: .utf8) {
            data.decode(callbackSuccess: callbackSuccess, callbackFailure: callbackFailure)
        }
    }
}

extension Data {
    func decode<T: Codable>(callbackSuccess: @escaping (T) -> (), callbackFailure: @escaping (_ err: Error) -> ()) {
        let decoder = JSONDecoder()
        do {
            print("Raw JSON:", String(data: self, encoding: .utf8) ?? "")
            let jsonData = try decoder.decode(T.self, from: self)
            callbackSuccess(jsonData)
        } catch {
            print("Decoding error:", error)
            callbackFailure(error)
        }
    }
}


