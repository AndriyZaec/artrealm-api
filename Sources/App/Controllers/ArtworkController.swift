//
//  ArtworkController.swift
//  App
//
//  Created by Andrew Zaiets on 1/23/19.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

class ArtworkController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "artworks")
        group.get("/", use: index)
        group.post(Artwork.self, at: "/", use: create)
    }
}

private extension ArtworkController {
    func index(_ request: Request) throws -> Future<[Artwork]> {
        return Artwork.query(on: request).all()
    }
    
    func create(_ reqeust: Request, newArtwork: Artwork) throws -> Future<HTTPResponseStatus> {
        let user = try reqeust.requireAuthenticated(User.self)
    
        let artwork = Artwork.init(id: nil,
                                   title: newArtwork.title,
                                   subscription: newArtwork.subscription,
                                   userID: user.id!,
                                   artworkImageData: newArtwork.artworkImageData)
        
        return artwork.save(on: reqeust).transform(to: .created)
    }
}

