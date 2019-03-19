

import Foundation

struct Pizza: Codable {


    var name: String
    var ingredients: Array<String>

    init?(name: String, ingredients: Array<String>) {

        guard !name.isEmpty else {
            return nil
        }

        guard (ingredients.count >= 0) && (ingredients.count <= 5) else {
            return nil
        }

        if name.isEmpty || ingredients.count < 0  {
            return nil
        }

        self.name = name
        self.ingredients = ingredients

    }
}

struct Summary: Codable {
    var summary: [NoPhotoPizza]
    struct NoPhotoPizza: Codable {
        var name: String
        var ingredients: Array<String>
        init(_ pizza: Pizza) {
            self.name = pizza.name
            self.ingredients = pizza.ingredients
        }
    }
    
    init(_ pizzas: [String: Pizza]) {
        summary = pizzas.map({ NoPhotoPizza($0.value) })
    }
    init(_ pizzas: [Pizza]) {
        summary = pizzas.map({ NoPhotoPizza($0) })
    }
}

