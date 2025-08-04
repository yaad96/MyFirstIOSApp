//
//  SubjectGalleryView.swift
//  MyFirstApp
//
//  Created by Mainul Hossain on 8/4/25.
//


import SwiftUI
import SwiftData

struct SubjectGalleryView: View {
    @Query(sort: \SubjectImage.timestamp, order: .reverse) var subjects: [SubjectImage]
    @State private var selectedSubject: SubjectImage?
    @State private var showViewer = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                    ForEach(subjects) { subject in
                        if let thumb = SessionImageCache.shared.image(for: subject.id) ?? subject.data.toThumbnail() {
                            Button {
                                selectedSubject = subject
                                showViewer = true
                            } label: {
                                Image(uiImage: thumb)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            }
                        } else {
                            Color.clear.frame(height: 120)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Saved Subjects")
            .onAppear {
                for subject in subjects {
                    if SessionImageCache.shared.image(for: subject.id) == nil,
                       let thumb = subject.data.toThumbnail() {
                        SessionImageCache.shared.set(thumb, for: subject.id)
                    }
                }
            }
            .sheet(isPresented: $showViewer, onDismiss: {
                selectedSubject = nil
            }) {
                if let subject = selectedSubject {
                    SubjectDetailView(subject: subject)
                }
            }
        }
    }
}

extension Data {
    func toThumbnail(maxDim: CGFloat = 120) -> UIImage? {
        guard let img = UIImage(data: self) else { return nil }
        let maxSide = Swift.max(img.size.width, img.size.height)
        if maxSide <= maxDim { return img }
        let scale = maxDim / maxSide
        let newSize = CGSize(width: img.size.width * scale, height: img.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in img.draw(in: CGRect(origin: .zero, size: newSize)) }
    }
}
