//
//  ImagePicker.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var imageData: Data?
    @State private var item: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $item, matching: .images, photoLibrary: .shared()) {
            Label(imageData == nil ? "Choose Photo" : "Change Photo", systemImage: "photo")
        }
        .onChange(of: item) { newItem in
            guard let newItem = newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
}


