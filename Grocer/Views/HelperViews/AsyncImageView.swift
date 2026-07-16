//
//  AsyncImageView.swift
//  Grocer
//
//  Created by Emil on 6/26/26.
//

import SwiftUI

struct AsyncImageView: View {
    
    let imageURL: String
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .failure:
                Image(systemName: "photo")
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity)
            @unknown default:
                EmptyView()
            }
        }
    }
}
