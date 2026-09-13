// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct AlbumPage: View {
  var album: Album

  @Environment(LibraryDocument.self) private var document

  var body: some View {
    if let library = document.library {
      AlbumDetail(
        album: album,
        artist: album.artist.flatMap(library.artist(named:)),
        tracks: library.tracks(in: album)
      )
      .navigationTitle(album.name)
    } else {
      ProgressView()
        .controlSize(.large)
    }
  }
}

private struct AlbumDetail: View {
  let album: Album
  let artist: Artist?
  let tracks: [Track]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        AlbumHeader(album: album, artist: artist, tracks: tracks)

        VStack(alignment: .leading, spacing: 16) {
          ForEach(discs, id: \.number) { disc in
            VStack(alignment: .leading, spacing: 4) {
              if isMultiDisc {
                Text("Disc \(disc.number)")
                  .font(.headline)
                  .foregroundStyle(.secondary)
                  .padding(.horizontal, 12)
              }

              VStack(spacing: 0) {
                TrackList(
                  tracks: disc.tracks,
                  showsArtist: showsArtistColumn,
                  omittedArtist: album.artist
                )
              }
            }
          }
        }
      }
      .padding(24)
    }
  }

  private var discs: [(number: Int, tracks: [Track])] {
    Dictionary(grouping: tracks) { $0.discNumber ?? 1 }
      .sorted { $0.key < $1.key }
      .map { (number: $0.key, tracks: $0.value) }
  }

  private var isMultiDisc: Bool {
    Set(tracks.map { $0.discNumber ?? 1 }).count > 1
      || tracks.contains { ($0.discCount ?? 1) > 1 }
  }

  private var showsArtistColumn: Bool {
    tracks.contains {
      TrackList.artist(of: $0, omitting: album.artist) != nil
    }
  }
}

private struct AlbumHeader: View {
  let album: Album
  let artist: Artist?
  let tracks: [Track]

  @Environment(NavigationModel.self) private var navigation

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(album.name)
        .font(.largeTitle)
        .fontWeight(.bold)
        .lineLimit(2)
        .textSelection(.enabled)

      if let artist {
        Button(artist.name) {
          navigation.showArtist(artist)
        }
        .buttonStyle(.plain)
        .font(.title2)
        .foregroundStyle(.tint)
        .pointerStyle(.link)
      } else {
        Text(album.artist ?? "Unknown Artist")
          .font(.title2)
          .foregroundStyle(.secondary)
      }

      if !details.isEmpty {
        Text(details)
          .font(.callout)
          .foregroundStyle(.secondary)
          .textSelection(.enabled)
      }
    }
  }

  private var details: String {
    [genre, releaseDate].compactMap(\.self).joined(separator: " · ")
  }

  private var genre: String? {
    Dictionary(grouping: tracks.compactMap(\.genre).filter { !$0.isEmpty }) {
      $0
    }
    .max { $0.value.count < $1.value.count }?
    .key
  }

  private var releaseDate: String? {
    if let date = tracks.compactMap(\.releaseDate).min() {
      return date.formatted(
        Date.FormatStyle(date: .long, time: .omitted, timeZone: .gmt)
      )
    }
    return tracks.compactMap(\.year).min().map(String.init)
  }
}

#Preview {
  let document = LibraryDocument()
  document.library = try? Library.from(
    url: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
      "Downloads/Library.xml"
    )
  )

  return NavigationStack {
    if let album = document.library?.albums.first {
      AlbumPage(album: album)
    }
  }
  .environment(document)
  .environment(NavigationModel())
}
