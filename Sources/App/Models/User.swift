//
//  User.swift
//  App
//
//  Created by Andrew Zaiets on 1/19/19.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Authentication

struct User: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    private(set) var name: String
    private(set) var email: String
    private(set) var password: String
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}
