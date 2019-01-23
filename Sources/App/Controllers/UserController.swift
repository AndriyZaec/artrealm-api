//
//  UserController.swift
//  App
//
//  Created by Andrew Zaiets on 1/19/19.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto

class UserController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "signup", use: registerUserHandler)
        group.get("/", use: index)
    }
}

private extension UserController {
    func index(_ request: Request) throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<HTTPResponseStatus> {
        return User.query(on: request).filter(\.email == newUser.email)
            .first()
            .flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "A user with this email already exists" ,
                                identifier: nil)
                }
                
                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let persistedUser = User(id: nil,
                                         name: newUser.name,
                                         email: newUser.email,
                                         password: hashedPassword)
                
                return persistedUser.save(on: request).transform(to: .created)
        }
    }
    
}
