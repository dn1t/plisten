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

  var effectiveAlbumArtist: String? {
    albumArtist?.nonEmpty ?? artist?.nonEmpty
  }

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

nonisolated struct Artist: Identifiable {
  let name: String
  let trackIDs: [Int]

  var id: String { name }
}

nonisolated struct Album: Identifiable, Hashable {
  struct ID: Hashable {
    let name: String
    let artist: String?
  }

  let id: ID
  let trackIDs: [Int]

  var name: String { id.name }
  var artist: String? { id.artist }
}

nonisolated struct Genre: Identifiable {
  let name: String
  let trackIDs: [Int]

  var id: String { name }
}

nonisolated struct Library: Codable {
  let date: Date
  let tracks: [Int: Track]
  let _playlists: [Playlist]

  let artists: [Artist]
  let albums: [Album]
  let genres: [Genre]

  enum CodingKeys: String, CodingKey {
    case date = "Date"
    case tracks = "Tracks"
    case _playlists = "Playlists"
  }

  init(date: Date, tracks: [Int: Track], playlists: [Playlist]) {
    self.date = date
    self.tracks = tracks
    self._playlists = playlists

    let ordered = tracks.values.sorted { $0.precedesInAlbumOrder($1) }

    self.artists = Self.group(
      ordered,
      by: \.effectiveAlbumArtist,
      ignoringCase: \.caseFolded
    )
    .map { Artist(name: $0.key, trackIDs: $0.trackIDs) }
    .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

    self.albums = Self.group(ordered) { track in
      track.album?.nonEmpty.map {
        Album.ID(name: $0, artist: track.effectiveAlbumArtist)
      }
    } ignoringCase: {
      Album.ID(name: $0.name.caseFolded, artist: $0.artist?.caseFolded)
    }
    .map { Album(id: $0.key, trackIDs: $0.trackIDs) }
    .sorted { lhs, rhs in
      let byName = lhs.name.localizedStandardCompare(rhs.name)
      if byName != .orderedSame { return byName == .orderedAscending }

      return (lhs.artist ?? "")
        .localizedStandardCompare(rhs.artist ?? "") == .orderedAscending
    }

    self.genres = Self.group(
      ordered,
      by: { $0.genre?.nonEmpty },
      ignoringCase: \.caseFolded
    )
    .map { Genre(name: $0.key, trackIDs: $0.trackIDs) }
    .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      date: try container.decode(Date.self, forKey: .date),
      tracks: try container.decode([Int: Track].self, forKey: .tracks),
      playlists: try container.decode([Playlist].self, forKey: ._playlists)
    )
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

  private static func group<Key: Hashable>(
    _ tracks: [Track],
    by key: (Track) -> Key?,
    ignoringCase fold: (Key) -> Key
  ) -> [(key: Key, trackIDs: [Int])] {
    var groups: [Key: TrackGroup<Key>] = [:]
    for track in tracks {
      guard let key = key(track) else { continue }
      groups[fold(key), default: TrackGroup()].add(
        track.trackID,
        spelledAs: key
      )
    }

    return groups.values.map { ($0.key, $0.trackIDs) }
  }
}

nonisolated private struct TrackGroup<Key: Hashable> {
  private var counts: [Key: Int] = [:]
  private var spellings: [Key] = []
  private(set) var trackIDs: [Int] = []

  mutating func add(_ trackID: Int, spelledAs key: Key) {
    if counts[key] == nil {
      spellings.append(key)
    }
    counts[key, default: 0] += 1
    trackIDs.append(trackID)
  }

  var key: Key {
    spellings.max { counts[$0, default: 0] < counts[$1, default: 0] }!
  }
}

extension Track {
  nonisolated fileprivate func precedesInAlbumOrder(_ other: Track) -> Bool {
    for (lhs, rhs) in [
      (album, other.album), (effectiveAlbumArtist, other.effectiveAlbumArtist),
    ] {
      let order = (lhs ?? "").compareIgnoringCase(rhs ?? "")
      if order != .orderedSame { return order == .orderedAscending }
    }

    let lhs = (discNumber ?? 0, trackNumber ?? 0)
    let rhs = (other.discNumber ?? 0, other.trackNumber ?? 0)
    if lhs != rhs { return lhs < rhs }

    return name.localizedStandardCompare(other.name) == .orderedAscending
  }
}

extension String {
  nonisolated fileprivate var nonEmpty: String? { isEmpty ? nil : self }

  nonisolated fileprivate var caseFolded: String {
    folding(options: .caseInsensitive, locale: nil)
  }

  nonisolated fileprivate func compareIgnoringCase(_ other: String)
    -> ComparisonResult
  {
    compare(
      other,
      options: [.caseInsensitive, .numeric, .widthInsensitive],
      locale: .current
    )
  }
}
