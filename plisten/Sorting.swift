// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation

nonisolated protocol SortField: Hashable, Sendable {
  associatedtype Item

  func sort(_ items: [Item], ascending: Bool) -> [Item]
}

nonisolated protocol SortOption: SortField, CaseIterable, Identifiable {
  var title: String { get }
  var defaultsToAscending: Bool { get }
}

nonisolated struct SortSetting<Field: SortField>: Hashable, Sendable {
  var field: Field
  var ascending: Bool

  func apply(to items: [Field.Item]) -> [Field.Item] {
    field.sort(items, ascending: ascending)
  }
}

extension SortSetting where Field: SortOption {
  init(_ field: Field) {
    self.init(field: field, ascending: field.defaultsToAscending)
  }
}

nonisolated struct Unsorted<Item>: SortField {
  func sort(_ items: [Item], ascending: Bool) -> [Item] { items }
}

nonisolated enum TrackSortField: String, SortOption {
  case playlistOrder
  case title
  case artist
  case album
  case releaseDate
  case dateAdded

  var id: Self { self }

  var title: String {
    switch self {
    case .playlistOrder: "Playlist Order"
    case .title: "Title"
    case .artist: "Artist"
    case .album: "Album"
    case .releaseDate: "Release Date"
    case .dateAdded: "Date Added"
    }
  }

  var defaultsToAscending: Bool {
    switch self {
    case .releaseDate, .dateAdded: false
    default: true
    }
  }

  func sort(_ tracks: [Track], ascending: Bool) -> [Track] {
    let albumOrder: [SortKey<Track>] = [
      .text(\.album), .value(\.discNumber), .value(\.trackNumber),
    ]

    let keys: [SortKey<Track>] =
      switch self {
      case .playlistOrder: []
      case .title: [.text(\.name), .text(\.artist)]
      case .artist: [.text(\.artist)] + albumOrder
      case .album: albumOrder
      case .releaseDate: [.value(\.effectiveReleaseDate)] + albumOrder
      case .dateAdded: [.value(\.dateAdded)] + albumOrder
      }

    guard !keys.isEmpty else {
      return ascending ? tracks : tracks.reversed()
    }
    return tracks.sorted(by: keys, ascending: ascending)
  }
}

nonisolated enum AlbumSortField: String, SortOption {
  case title
  case artist
  case releaseDate
  case dateAdded

  var id: Self { self }

  var title: String {
    switch self {
    case .title: "Title"
    case .artist: "Artist"
    case .releaseDate: "Release Date"
    case .dateAdded: "Date Added"
    }
  }

  var defaultsToAscending: Bool {
    switch self {
    case .releaseDate, .dateAdded: false
    default: true
    }
  }

  func sort(_ albums: [Album], ascending: Bool) -> [Album] {
    let keys: [SortKey<Album>] =
      switch self {
      case .title: [.text(\.name), .text(\.artist)]
      case .artist: [.text(\.artist), .value(\.releaseDate), .text(\.name)]
      case .releaseDate: [.value(\.releaseDate), .text(\.name)]
      case .dateAdded: [.value(\.dateAdded), .text(\.name)]
      }

    return albums.sorted(by: keys, ascending: ascending)
  }
}

extension Array {
  nonisolated func sorted<Field: SortField>(
    by field: Field,
    ascending: Bool
  ) -> [Element] where Field.Item == Element {
    field.sort(self, ascending: ascending)
  }
}

nonisolated private struct SortKey<Item> {
  let compare: (Item, Item, _ ascending: Bool) -> ComparisonResult

  static func text(_ keyPath: KeyPath<Item, String>) -> Self {
    Self { lhs, rhs, ascending in
      lhs[keyPath: keyPath]
        .localizedStandardCompare(rhs[keyPath: keyPath])
        .directed(ascending)
    }
  }

  static func text(_ keyPath: KeyPath<Item, String?>) -> Self {
    Self { lhs, rhs, ascending in
      switch (lhs[keyPath: keyPath]?.nonEmpty, rhs[keyPath: keyPath]?.nonEmpty)
      {
      case (nil, nil): .orderedSame
      case (nil, _): .orderedDescending
      case (_, nil): .orderedAscending
      case (let lhs?, let rhs?):
        lhs.localizedStandardCompare(rhs).directed(ascending)
      }
    }
  }

  static func value<Value: Comparable>(_ keyPath: KeyPath<Item, Value?>) -> Self
  {
    Self { lhs, rhs, ascending in
      switch (lhs[keyPath: keyPath], rhs[keyPath: keyPath]) {
      case (nil, nil): .orderedSame
      case (nil, _): .orderedDescending
      case (_, nil): .orderedAscending
      case (let lhs?, let rhs?):
        if lhs == rhs {
          .orderedSame
        } else {
          (lhs < rhs ? ComparisonResult.orderedAscending : .orderedDescending)
            .directed(ascending)
        }
      }
    }
  }
}

extension Array {
  nonisolated fileprivate func sorted(
    by keys: [SortKey<Element>],
    ascending: Bool
  ) -> [Element] {
    sorted { lhs, rhs in
      for key in keys {
        let order = key.compare(lhs, rhs, ascending)
        if order != .orderedSame { return order == .orderedAscending }
      }
      return false
    }
  }
}

extension ComparisonResult {
  nonisolated fileprivate func directed(_ ascending: Bool) -> Self {
    guard !ascending else { return self }
    switch self {
    case .orderedAscending: return .orderedDescending
    case .orderedDescending: return .orderedAscending
    case .orderedSame: return .orderedSame
    }
  }
}

extension String {
  nonisolated fileprivate var nonEmpty: String? { isEmpty ? nil : self }
}
