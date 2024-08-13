//
//  DetailedDishView.swift
//  WorldDishes
//
//  Created by Peter Lebedev on 8/13/24.
//

import SwiftUI

struct DetailedDishView: View {
    let dish: TranslatedDish
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        if dish.isCertified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                        Text(dish.originalName)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text(dish.translation)
                        .font(.title2)
                    
                    if !dish.description.isEmpty {
                        Text("Description:")
                            .font(.headline)
                        Text(dish.description)
                            .font(.body)
                    }
                    
                    if !dish.allergens.isEmpty {
                        Text("Allergens:")
                            .font(.headline)
                        Text(dish.allergens.joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Dish Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
