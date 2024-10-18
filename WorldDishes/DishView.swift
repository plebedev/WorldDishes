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
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if dish.isCertified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                Text(dish.originalName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .lineLimit(1)
            
            Text(dish.translation)
                .font(.caption)
                .lineLimit(1)
            
            if !dish.description.isEmpty {
                Text(dish.description)
                    .font(.caption)
                    .lineLimit(2)
            }
            
            if !dish.allergens.isEmpty {
                Text("Allergens: \(dish.allergens.joined(separator: ", "))")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .lineLimit(1)
            }
        }
        .padding(8)
        .frame(height: 100) // Fixed height for uniformity
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
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
    let dishIndex: Int
}
