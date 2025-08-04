import SwiftUI
import PhotosUI

enum LiftNavigationState: Equatable {
    case idle
    case showingLift(image: UIImage)
    case showingPastedSubject(image: UIImage)
}

struct ContentView: View {
    @State private var pickerItem: PhotosPickerItem?
    @State private var navState: LiftNavigationState = .idle
    @State private var showCamera = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                PhotosPicker(
                    selection: $pickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Pick from Library")
                        .frame(width: 220, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .onChange(of: pickerItem) { newItem in
                    guard let item = newItem else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img = UIImage(data: data) {
                            navState = .showingLift(image: img)
                        }
                    }
                }

                Button {
                    showCamera = true
                } label: {
                    Text("Take Photo with Camera")
                        .frame(width: 220, height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showCamera) {
                    CameraCaptureView(image: .constant(nil), isShown: $showCamera, onCapture: { img in
                        if let img = img {
                            navState = .showingLift(image: img)
                        }
                    })
                }

                NavigationLink(destination: SubjectGalleryView()) {
                    Text("Show Saved Subjects")
                        .frame(width: 220, height: 50)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Lift Subject Demo")
            .background(
                NavigationLink(
                    destination: navigationDestination(),
                    isActive: Binding<Bool>(
                        get: { navState != .idle },
                        set: { isActive in
                            if !isActive { navState = .idle }
                        }
                    )
                ) {
                    EmptyView()
                }
            )
        }
    }

    @ViewBuilder
    private func navigationDestination() -> some View {
        switch navState {
        case .idle:
            EmptyView()
        case .showingLift(let img):
            ImageLiftView(uiImage: img) { pasted in
                navState = .showingPastedSubject(image: pasted)
            }
        case .showingPastedSubject(let subject):
            ImageLiftPasteView(subjectImage: subject) {
                navState = .idle
            }
        }
    }
}

