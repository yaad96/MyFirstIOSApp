//
//  ImageLiftPasteView.swift
//  MyFirstApp
//
//  Created by Mainul Hossain on 8/4/25.
//


import SwiftUI
import SwiftData

struct ImageLiftPasteView: View {
    var subjectImage: UIImage?
    var onSaved: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var showBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                if let img = subjectImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)

                    Button("Save Subject") {
                        let resized = img.resized(maxDim: 1024)
                        guard let data = resized.pngData() else { return }
                        let subject = SubjectImage(data: data)
                        modelContext.insert(subject)

                        withAnimation { showBanner = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation { showBanner = false }
                            onSaved()
                        }
                    }
                    .frame(width: 200, height: 50)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                } else {
                    Text("No pasted image yet")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Pasted Subject")

            if showBanner {
                Text("Saved!")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 24)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                    .padding(.top, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

extension UIImage {
    func resized(maxDim: CGFloat) -> UIImage {
        let maxSide = Swift.max(size.width, size.height)
        guard maxSide > maxDim else { return self }
        let scale = maxDim / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
