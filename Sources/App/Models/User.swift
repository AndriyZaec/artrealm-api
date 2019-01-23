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

final class User: Content, SQLiteUUIDModel {
    var id: UUID?
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    struct Public: Codable {
        var id: UUID?
        var firstName: String?
        var lastName: String?
        var email: String
        
        init(id: UUID?, email: String) {
            self.id = id
            self.email = email
        }
    }
}

extension User {
    var artworks: Children<User, Artwork> {
        return children(\.userID)
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

extension User: Parameter {}

extension User: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: conn) { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.email)
        }
    }
}

extension User.Public: Content {}

extension User {
    func toPublic() -> User.Public {
        return User.Public(id: id, email: email)
    }
}

extension Future where T: User {
    func toPublic() -> Future<User.Public> {
        return map(to: User.Public.self) { (user) in
            return user.toPublic()
        }
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

struct AdminUser: Migration {
    typealias Database = SQLiteDatabase
    
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        let password = try? BCrypt.hash("admin") // NOT do this for production
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        
        let user = User(email: "admin@admin.com", password: hashedPassword)
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: SQLiteConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
