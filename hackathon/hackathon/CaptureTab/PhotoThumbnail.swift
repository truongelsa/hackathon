import SwiftUI

struct PhotoThumbnail: View {
  let image: UIImage?

  var body: some View {
    Group {
      // if we have Image then we'll show image
      if let image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
      }

      // else just show black view
      Rectangle()
        .frame(width: 50, height: 50, alignment: .center)
        .foregroundColor(.clear)
    }
  }
}
