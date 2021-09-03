//
//  Service.swift
//  fullstack_social_ios
//
//  Created by Andrey on 01.09.2021.
//

import Alamofire

class Service: NSObject {
    
    static let shared = Service()
    
    let baseUrl = "http://localhost:1337"
    
    func login(email: String, password: String, completion: @escaping (AFResult<Data>) -> ()) {
        print("Performing login")
        let params = ["emailAddress": email, "password": password]
        let url = "\(baseUrl)/api/v1/entrance/login"
        AF.request(url, method: .put, parameters: params)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                if let err = dataResp.error {
                    completion(.failure(err))
                } else {
                    completion(.success(dataResp.data ?? Data()))
                }
        }
    }
    
    func fetchPosts(completion: @escaping (AFResult<[Post]>) -> ()) {
        let url = "\(baseUrl)/post"
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                if let err = dataResp.error {
                    completion(.failure(err))
                    return
                }
                
                guard let data = dataResp.data else { return }
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                } catch {
                    completion(.failure(error as! AFError))
                }
        }
    }
    
    func signUp(fullName: String, emailAddress: String, password: String, completion: @escaping (AFResult<Data>) -> ()) {
        let params = ["fullName": fullName, "emailAddress": emailAddress, "password": password]
        let url = "\(baseUrl)/api/v1/entrance/signup"
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                if let err = dataResp.error {
                    completion(.failure(err))
                    return
                }
                completion(.success(dataResp.data ?? Data()))
        }
    }
    
}
