//
//  ContentViewModel.swift
//  WorldDishes
//
//  Created by Peter Lebedev on 7/31/24.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isShowingImagePicker = false
    @Published var selectedLanguage: String
    @Published var isTranslating = false
    @Published var translationResult = ""
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var menuLanguage: String?
    @Published var sourceLanguage: String?
    @Published var translatedDishes: [TranslatedDish] = []

    let languages = ["Russian", "Ukrainian", "Hebrew", "English", "Spanish", "French", "German", "Italian"]

#if DEBUG
    var isDebugMode = false
    #endif
    
    init() {
        self.selectedLanguage = "English"
        setDefaultLanguage()
    }

    func setDefaultLanguage() {
        let currentLanguage = Locale.current.languageCode ?? "en"
        let languageMap = [
            "ru": "Russian",
            "uk": "Ukrainian",
            "he": "Hebrew",
            "en": "English",
            "es": "Spanish",
            "fr": "French",
            "de": "German",
            "it": "Italian"
        ]

        if let defaultLanguage = languageMap[currentLanguage],
           languages.contains(defaultLanguage) {
            selectedLanguage = defaultLanguage
        } else {
            // If the device language is not in our list, default to English
            selectedLanguage = "English"
        }
    }

    func translateImage() {
        guard let image = image else { return }
        isTranslating = true
        translationResult = ""
        menuLanguage = nil
        sourceLanguage = nil
        translatedDishes = []
        
#if DEBUG
        if isDebugMode {
            simulateTranslation()
            return
        }
#endif
        
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 1024, height: 1024))
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
            self.translationResult = "Failed to process the image."
            self.isTranslating = false
            return
        }
        
        let url = URL(string: "http://world-dishes-translator.allstuffaround.com/api/translate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("9Tz5fXwL7qKpRm3bNcJhY8vA", forHTTPHeaderField: "X-API-KEY")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"menuImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add language data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(selectedLanguage)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isTranslating = false
                
                if let error = error {
                    self?.translationResult = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.translationResult = "No data received from the server."
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self?.parseAndDisplayResults(json)
                    }
                } catch {
                    self?.translationResult = "Failed to parse server response."
                }
            }
        }.resume()
    }
    
#if DEBUG
    private func simulateTranslation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simulate network delay
            self.menuLanguage = "Simulated \(self.selectedLanguage) Menu"
            self.sourceLanguage = "English"
            
            self.translatedDishes = [
                TranslatedDish(originalName: "Spaghetti Carbonara", translation: "Спагетти Карбонара", description: "Классическое итальянское блюдо из пасты с яйцами, сыром, перцем и панчеттой", allergens: ["Яйца", "Молочные продукты", "Глютен"], isCertified: true, dishIndex: 0),
                TranslatedDish(originalName: "Caesar Salad", translation: "Салат Цезарь", description: "Салат из листьев ромэна, гренок, пармезана и заправки на основе яиц", allergens: ["Яйца", "Молочные продукты", "Глютен"], isCertified: false, dishIndex: 1),
                TranslatedDish(originalName: "Margherita Pizza", translation: "Пицца Маргарита", description: "Классическая итальянская пицца с томатами, моцареллой и базиликом", allergens: ["Молочные продукты", "Глютен"], isCertified: true, dishIndex: 2),
                TranslatedDish(originalName: "Beef Stroganoff", translation: "Бефстроганов", description: "Русское блюдо из говядины в сметанном соусе", allergens: ["Молочные продукты"], isCertified: false, dishIndex: 3),
                TranslatedDish(originalName: "Tiramisu", translation: "Тирамису", description: "Итальянский десерт на основе маскарпоне и кофе", allergens: ["Яйца", "Молочные продукты", "Глютен"], isCertified: true, dishIndex: 4)
            ]
            
            self.translationResult = "Translation completed"
            self.isTranslating = false
        }
    }
    #endif
    
    private func parseAndDisplayResults(_ json: [String: Any]) {
        if let error = json["error"] as? String {
            translationResult = "Error: \(error)"
            return
        }
        
        menuLanguage = json["menu_lang_title"] as? String
        sourceLanguage = json["source_language"] as? String
        
        if let dishes = json["dishes"] as? [String: [String: Any]] {
            translatedDishes = dishes.map { (originalName, dishInfo) in
                print("Original Name: \(originalName)")
                        print("Dish Info: \(dishInfo)")
                        
                        let index = dishInfo["index"] as? Int ?? 0
                        print("Extracted Index: \(index)")
                        
                        return TranslatedDish(
                            originalName: originalName,
                            translation: dishInfo["translation"] as? String ?? "",
                            description: dishInfo["description"] as? String ?? "",
                            allergens: dishInfo["allergens"] as? [String] ?? [],
                            isCertified: dishInfo["certified"] as? Bool ?? false,
                            dishIndex: index
                        )
            }.sorted { $0.dishIndex < $1.dishIndex }
        }
        
        translationResult = translatedDishes.isEmpty ? "No translation data found." : "Translation completed"
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
}
