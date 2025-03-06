//
//  HomeTab.swift
//  hackathon
//
//  Created by Nhat T. Nguyen on 6/3/25.
//
import SwiftUI

struct HomeTab: View {
  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        // Button Row
        HStack(spacing: 16) {
          NavigationLink(destination: PhotoDetailsView(selectedImage: UIImage())) {
            Text("Go to sample image")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .foregroundColor(.black)
              .cornerRadius(8)
          }
        }
        .padding(.horizontal)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color(.lightGray))
      .ignoresSafeArea()
    }
  }
}

#Preview {
  HomeTab()
}
