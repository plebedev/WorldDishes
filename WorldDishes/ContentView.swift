//
//  ContentView.swift
//  WorldDishes
//
//  Created by Peter Lebedev on 7/31/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
#if DEBUG
    @State private var showTestImages = false
    let testImages = ["MenuImage1", "MenuImage2", "NotMenuImage"]
#endif
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    imageView
                    
#if DEBUG
                    Button("Select Test Image") {
                        showTestImages.toggle()
                    }
                    .actionSheet(isPresented: $showTestImages) {
                        ActionSheet(title: Text("Select Test Image"), buttons:
                                        testImages.map { imageName in
                                .default(Text(imageName)) {
                                    viewModel.image = UIImage(named: imageName)
                                }
                        } + [.cancel()]
                        )
                    }
#endif
                    
                    imageButtons
                    languagePicker
                    translateButton
                    
                    if viewModel.isTranslating {
                        ProgressView()
                    } else if !viewModel.translationResult.isEmpty {
                        translationResultView
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Menu Translator")
                        .font(.headline)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(image: $viewModel.image, sourceType: viewModel.sourceType)
        }
    }
    
    private var imageView: some View {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var imageButtons: some View {
        HStack {
            Button(action: {
                viewModel.sourceType = .camera
                viewModel.isShowingImagePicker = true
            }) {
                Label("Take Photo", systemImage: "camera")
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                viewModel.sourceType = .photoLibrary
                viewModel.isShowingImagePicker = true
            }) {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var languagePicker: some View {
        Menu {
            Picker("Language", selection: $viewModel.selectedLanguage) {
                ForEach(viewModel.languages, id: \.self) {
                    Text($0)
                }
            }
        } label: {
            HStack {
                Text("Language: ")
                Text(viewModel.selectedLanguage)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private var translateButton: some View {
        Button(action: viewModel.translateImage) {
            Text("Translate")
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.image == nil || viewModel.isTranslating)
    }
    
    private var translationResultView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let menuLanguage = viewModel.menuLanguage {
                Text("Menu Language: \(menuLanguage)")
                    .font(.headline)
            }
            if let sourceLanguage = viewModel.sourceLanguage {
                Text("Source Language: \(sourceLanguage)")
                    .font(.headline)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.translatedDishes, id: \.originalName) { dish in
                    DishView(dish: dish)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
