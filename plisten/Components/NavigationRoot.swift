// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI

enum Page: Hashable {
  case root
  case album(album: Album)
}

struct NavigationRoot<Content: View>: View {
  @Binding var path: [Page]
  @ViewBuilder let content: Content

  var body: some View {
    NavigationStack(path: $path) {
      content
        .navigationDestination(for: Page.self) { page in
          if case .album(let album) = page {
            AlbumPage(album: album)
          }
        }
    }
  }
}
