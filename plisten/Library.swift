// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation

nonisolated struct Track: Codable, Identifiable {
  let trackID: Int
  let name: String
  let artist: String?
  let albumArtist: String?
  let album: String?
  let genre: String?
  let totalTime: Int
  let discNumber: Int?
  let discCount: Int?
  let trackNumber: Int?
  let trackCount: Int?
  let year: Int?
  let releaseDate: Date?
  let _loved: Bool?
  let _albumLoved: Bool?
  let _explicit: Bool?
  let _appleMusic: Bool?
  let _playlistOnly: Bool?

  var id: Int { trackID }
  var loved: Bool { _loved ?? false }
  var albumLoved: Bool { _albumLoved ?? false }
  var explicit: Bool { _explicit ?? false }
  var appleMusic: Bool { _appleMusic ?? false }
  var playlistOnly: Bool { _playlistOnly ?? false }

  enum CodingKeys: String, CodingKey {
    case trackID = "Track ID"
    case name = "Name"
    case artist = "Artist"
    case albumArtist = "Album Artist"
    case album = "Album"
    case genre = "Genre"
    case totalTime = "Total Time"
    case discNumber = "Disc Number"
    case discCount = "Disc Count"
    case trackNumber = "Track Number"
    case trackCount = "Track Count"
    case year = "Year"
    case releaseDate = "Release Date"
    case _loved = "Loved"
    case _albumLoved = "Album Loved"
    case _explicit = "Explicit"
    case _appleMusic = "Apple Music"
    case _playlistOnly = "Playlist Only"
  }
}

nonisolated struct PlaylistItem: Codable {
  let trackID: Int

  enum CodingKeys: String, CodingKey {
    case trackID = "Track ID"
  }
}

nonisolated struct Playlist: Codable, Identifiable {
  let name: String
  let description: String?
  let _master: Bool?
  let playlistPersistentID: String
  let parentPersistentID: String?
  let _folder: Bool?
  let playlistItems: [PlaylistItem]?
  let distinguishedKind: Int?

  var id: String { playlistPersistentID }

  var master: Bool { self._master ?? false }
  var folder: Bool { self._folder ?? false }

  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case description = "Description"
    case _master = "Master"
    case playlistPersistentID = "Playlist Persistent ID"
    case parentPersistentID = "Parent Persistent ID"
    case _folder = "Folder"
    case playlistItems = "Playlist Items"
    case distinguishedKind = "Distinguished Kind"
  }
}

nonisolated struct Library: Codable {
  let date: Date
  let tracks: [Int: Track]
  let _playlists: [Playlist]

  enum CodingKeys: String, CodingKey {
    case date = "Date"
    case tracks = "Tracks"
    case _playlists = "Playlists"
  }

  func children(of folder: Playlist?) -> [Playlist] {
    let children: [Playlist]
    if let folder {
      children = playlists.filter { $0.parentPersistentID == folder.id }
    } else {
      let folderIDs = Set(playlists.lazy.filter(\.folder).map(\.id))
      children = playlists.filter { playlist in
        guard let parentID = playlist.parentPersistentID else { return true }
        return !folderIDs.contains(parentID)
      }
    }

    return children
  }

  var playlists: [Playlist] {
    _playlists.filter { !$0.master && $0.distinguishedKind == nil }
  }

  func tracks(in playlist: Playlist) -> [Track] {
    (playlist.playlistItems ?? []).compactMap { tracks[$0.trackID] }
  }

  static func from(data: Data) throws -> Self {
    return try PropertyListDecoder().decode(Library.self, from: data)
  }

  static func from(url: URL) throws -> Self {
    let data = try Data(contentsOf: url)
    return try self.from(data: data)
  }
}
