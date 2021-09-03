//
//  Post.swift
//  fullstack_social_ios
//
//  Created by Andrey on 01.09.2021.
//

import Foundation

struct Post: Decodable {
    let id: String
    let text: String
    let createdAt: Int
    let imageUrl: String
    let user: User
}

struct User: Decodable {
    let id: String
    let fullName: String
}
