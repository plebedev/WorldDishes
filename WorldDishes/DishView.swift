//
//  DishView.swift
//  WorldDishes
//
//  Created by Peter Lebedev on 7/31/24.
//

import SwiftUI

struct DishView: View {
    let dish: TranslatedDish
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dish.originalName)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(dish.translation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            if !dish.description.isEmpty {
                Text(dish.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if !dish.allergens.isEmpty {
                Text("Allergens: \(dish.allergens.joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct TranslatedDish {
    let originalName: String
    let translation: String
    let description: String
    let allergens: [String]
}
