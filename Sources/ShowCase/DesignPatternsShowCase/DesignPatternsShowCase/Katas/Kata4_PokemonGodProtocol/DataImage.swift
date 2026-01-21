import SwiftUI

struct DataImage: View {
	let data: Data?

	var body: some View {
		if let data = data, let uiImage = UIImage(data: data) {
			Image(uiImage: uiImage)
				.resizable()
				.aspectRatio(contentMode: .fit)
		} else {
			Image(systemName: "photo")
				.font(.largeTitle)
				.foregroundStyle(.gray)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Color.gray.opacity(0.1))
		}
	}
}
