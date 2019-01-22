//
//  Artwork.swift
//  App
//
//  Created by Andrew Zaiets on 1/23/19.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct Artwork: SQLiteUUIDModel {
    var id: UUID?
    private(set) var title: String
    private(set) var subscription: String?
    private(set) var userID: UUID
    private(set) var artworkImageData: File?
}

extension Artwork {
    var user: Parent<Artwork, User> {
        return parent(\.userID)
    }
}

extension Artwork: Content {}
extension Artwork: Migration {}
