// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import SwiftUI
import UniformTypeIdentifiers

@Observable
final class LibraryDocument: ReadableDocument {
  static let readableContentTypes: [UTType] = [.xml]

  var library: Library?

  nonisolated func reader(
    configuration: sending ReadConfiguration
  ) -> sending FileWrapperDocumentReader<Library> {
    FileWrapperDocumentReader(configuration) { file in
      guard let data = file.regularFileContents else {
        throw CocoaError(.fileReadCorruptFile)
      }
      return try Library.from(data: data)
    }
  }

  @MainActor
  func apply(snapshot: sending Library, previous: sending Library?) async throws
  {
    library = snapshot
  }
}
