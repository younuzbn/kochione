//
//  FoodItem.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


//
//  Tab.swift
//  FoodDeliveryApp
//

//

import SwiftUI

// MARK: Tab Model And Sample Data
struct FoodItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    let image: String
    let price: Int
    let description: String
    let isDrink: Bool
    let category: String
}

struct TabModel: Identifiable {
    let id = UUID()
    let name: String
    let tabImage: String
    var items: [FoodItem]
    let tabOffset: CGSize
}

let tabs: [TabModel] = [
    TabModel(
        name: "Soft Drinks",
        tabImage: "Drinks",
        items: [
            .init(
                name: "Cold Coffee",
                image: "ColdCoffee",
                price: 250,
                description: "Rich, chilled coffee blended with milk and ice for a smooth, refreshing taste", isDrink: false, category:"Soft Drinks"
            ),
            .init(
                name: "Iced Tea",
                image: "IcedTea",
                price: 120,
                description: "Freshly brewed tea cooled with ice and infused with lemon for a crisp, energizing sip.", isDrink: false, category: "Soft Drinks"
            ),
            .init(
                name: "Coca Cola",
                image: "CocaCola",
                price: 20,
                description: "The classic fizzy cola drink with a bold, refreshing taste loved worldwide.", isDrink: true, category: "Soft Drinks"
            ),
            .init(
                name: "7 Up",
                image: "7Up",
                price: 50,
                description: "A sparkling lemon-lime drink that’s crisp, cool, and incredibly refreshing.", isDrink: true, category: "Soft Drinks"
            )
        ],
        tabOffset: CGSize(width: -10, height: -55)
    ),
    
    TabModel(
        name: "Fast Food",
        tabImage: "Burger",
        items: [
            .init(
                name: "Burger",
                image: "Burger",
                price: 120,
                description: "A tender, flavorful meat patty grilled to perfection, paired with fresh veggies, melted cheese, and rich sauces inside a soft toasted bun", isDrink: false, category: "Fast Food"
            ),
            .init(
                name: "Pizza",
                image: "Pizza",
                price: 199,
                description: "Hand-tossed crust topped with rich tomato sauce, melted cheese, and a selection of fresh toppings baked to perfection", isDrink: false, category: "Fast Food"
            ),
            .init(
                name: "Hot Dog",
                image: "Hot Dog",
                price: 160,
                description: "Soft warm bun filled with a juicy sausage, drizzled with mustard, ketchup, and topped with crunchy onions.", isDrink: false, category: "Fast Food"
            ),
            .init(
                name: "Shawarma",
                image: "Shawarma",
                price: 110,
                description: "Thinly sliced marinated meat wrapped in soft pita bread with garlic mayo, veggies, and a hint of Middle-Eastern spices.", isDrink: false, category: "Fast Food"
            )
        ],
        tabOffset: CGSize(width: 6, height: -55)
    ),
    
   
    TabModel(
        name: "Starters",
        tabImage: "Snacks 1",
        items: [
            .init(
                name: "Momos",
                image: "Momos",
                price: 90,
                description: "Steamed dumplings filled with tender, flavorful stuffing, served hot with spicy chutney.", isDrink: true, category: "Starters"
            ),
            .init(
                name: "Chicken Wings",
                image: "Chickenwings1",
                price: 240,
                description: "Crispy, juicy chicken wings coated in a spicy seasoning and fried until golden.", isDrink: false, category: "Starters"
            ),
            .init(
                name: "French Fries",
                image: "FrenchFries",
                price: 120,
                description: "Golden-fried potato fries seasoned lightly for a perfect crispy snack.", isDrink: false, category: "Starters"
            )
        ],
        tabOffset: CGSize(width: -13, height: -55)
    ),
    
    TabModel(
        name: "Desserts",
        tabImage: "Waffles",
        items: [
            .init(
                name: "Chocolate Beetroot Cake",
                image: "DoubleChocolateBeetrootCake",
                price: 350,
                description: "A soft and moist chocolate cake blended with beetroot for a rich, earthy sweetness and natural texture.", isDrink: false, category: "Desserts"
            ),
            .init(
                name: "Ice Cream",
                image: "IceCream",
                price: 80,
                description: "Smooth and creamy ice cream prepared with fresh ingredients for a refreshing dessert.", isDrink: false, category: "Desserts"
            ),
            .init(
                name: "Chocolate Dough nuts",
                image: "ChocolateDippedDoughnuts",
                price: 90,
                description: "Fluffy doughnuts dipped in rich melted chocolate, topped with a glossy finish.", isDrink: false, category: "Desserts"
            )
        ],
        tabOffset: CGSize(width: -17, height: -55)
    ),
    
    TabModel(
        name: "Main Course",
        tabImage: "Biryani",
        items: [
            .init(
                name: "Hyderabadi Biryani",
                image: "chickenhyderabadibiryani",
                price: 260,
                description: "Traditional Hyderabadi-style biryani cooked with aromatic basmati rice, tender chicken, and a blend of royal spices.", isDrink: false, category: "Main Course"
            ),
            .init(
                name: "Butter Chicken & Naan",
                image: "ButterChicken&Naan",
                price: 320,
                description: "Butter-soft chicken simmered in a creamy tomato gravy, paired perfectly with warm, fresh naan.", isDrink: false, category: "Main Course"
            ),
            .init(
                name: "Pasta (White Sauce)",
                image: "PastaWhite Sauce",
                price: 220,
                description: "Silky white sauce pasta made with cream, herbs, and cheese, offering a smooth and comforting flavor.", isDrink: false, category: "Main Course"
            )
        ],
        tabOffset: CGSize(width: -24, height: -55)
    )
]

