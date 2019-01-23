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
        let userGroup = router.grouped("api", "users")
        
        userGroup.post(User.self, at: "signup", use: register)
        userGroup.post("login", use: login)
        userGroup.get("/", use: getAll)
        
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = userGroup.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        tokenProtected.get("profile", use: profile)
    }
}

private extension UserController {
    func getAll(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).toPublic()
    }
    
    func register(_ request: Request, newUser: User) throws -> Future<HTTPResponseStatus> {
        return User.query(on: request).filter(\.email == newUser.email)
            .first()
            .flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "A user with this email already exists" ,
                                identifier: nil)
                }
                
                let digest = try request.make(BCryptDigest.self)
                let hashedPassword = try digest.hash(newUser.password)
                let persistedUser = User(email: newUser.email,
                                         password: hashedPassword)
                
                return persistedUser.save(on: request).transform(to: .created)
        }
    }
    
    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { fetchedUser in
                guard let existingUser = fetchedUser else {
                    throw Abort(HTTPStatus.notFound)
                }
                let hasher = try req.make(BCryptDigest.self)
                if try hasher.verify(user.password, created: existingUser.password) {
                    let token = try Token.generate(for: existingUser)
                    return token.save(on: req)
                } else {
                    throw Abort(HTTPStatus.unauthorized)
                }
            }
        }
    }
    
    func profile(_ req: Request) throws -> Future<String> {
        let user = try req.requireAuthenticated(User.self)
        return req.future("Hello, \(user.email)")
    }
}
