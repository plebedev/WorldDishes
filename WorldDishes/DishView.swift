//
//  DishView.swift
//  WorldDishes
//
//  Created by Peter Lebedev on 7/31/24.
//

import SwiftUI

struct DishView: View {
    let dish: TranslatedDish
    @State private var showDetailedView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if dish.isCertified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                }
                Text(dish.originalName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .lineLimit(2)
            
            Text(dish.translation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if !dish.description.isEmpty {
                Text(dish.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            if !dish.allergens.isEmpty {
                Text("Allergens: \(dish.allergens.joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showDetailedView = true
        }
        .sheet(isPresented: $showDetailedView) {
            DetailedDishView(dish: dish)
        }
    }
}

struct TranslatedDish {
    let originalName: String
    let translation: String
    let description: String
    let allergens: [String]
    let isCertified: Bool
}
