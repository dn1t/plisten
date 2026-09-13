// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

struct AlbumItem: View {
  let album: Album

  var body: some View {
    NavigationLink(value: Page.album(album: album)) {
      HStack {
        VStack(alignment: .leading) {
          Text(album.name)
            .font(.title3)
            .fontWeight(.medium)
          Text(album.artist ?? "Unknown")
            .font(.body)
            .foregroundStyle(.gray)
          Text(
            "\(album.trackIDs.count) Track\(album.trackIDs.count == 1 ? "" : "s")"
          )
          .font(.callout)
          .foregroundStyle(.gray)
        }
        Spacer()
      }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  AlbumItem(
    album: .init(
      id: .init(name: "DAYTONA", artist: "Pusha T"),
      trackIDs: [0, 1, 2, 3, 4, 5, 6]
    )
  )
}
