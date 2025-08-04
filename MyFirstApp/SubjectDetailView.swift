//
//  SubjectDetailView.swift
//  MyFirstApp
//
//  Created by Mainul Hossain on 8/4/25.
//


import SwiftUI
import SwiftData

struct SubjectDetailView: View {
    let subject: SubjectImage
    @Environment(\.dismiss) private var dismiss

    @State private var uiImage: UIImage? = nil
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading…")
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(1.5)
                    Spacer()
                }
            } else if let img = uiImage {
                VStack {
                    Spacer()
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    .padding(.bottom, 40)
                    .foregroundColor(.white)
                }
            } else {
                VStack {
                    Spacer()
                    Text("Failed to load image")
                        .foregroundColor(.white)
                        .onTapGesture { dismiss() }
                    Spacer()
                }
            }
        }
        .onAppear {
            // Always reset state on appear for repeated sheet presentations!
            uiImage = nil
            isLoading = true
            loadImage()
        }
    }

    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let loaded: UIImage? = {
                if let cached = SessionImageCache.shared.image(for: subject.id) {
                    return cached
                }
                guard let decoded = UIImage(data: subject.data) else { return nil }
                SessionImageCache.shared.set(decoded, for: subject.id)
                return decoded
            }()
            DispatchQueue.main.async {
                self.uiImage = loaded
                self.isLoading = false
            }
        }
    }
}
