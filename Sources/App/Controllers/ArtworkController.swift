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
        group.get("/", use: artworkGetHandler)
    }
}

private extension ArtworkController {
    func artworkGetHandler(_ request: Request) throws -> Future<[Artwork]> {
        return Artwork.query(on: request).all()
    }
}

