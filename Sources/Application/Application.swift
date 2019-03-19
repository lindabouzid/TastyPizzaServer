import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import KituraStencil

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()
    private var pizzaStore: [String: Pizza] = [:]
    
    public init() throws {
        // Run the metrics initializer
        initializeMetrics(router: router)
    }

    func postInit() throws {
        initializeHealthRoutes(app: self)
        router.post("/pizzas", handler: storeHandler)
        //router.get("/pizzas", handler: loadHandler)
        router.get("/summary", handler: summaryHandler)
        router.add(templateEngine: StencilTemplateEngine())
        router.get("/pizzas") { request, response, next in
            
            let context: [String: [Pizza]] =
                [
                    "pizzas": pizzaStore
            ]
            try response.render("myPizzas.stencil", context: context)
            response.status(.OK)
            next()
            

        }
        router.get("/add/pizza"){
            request, response, next in
            let context:[String : String] = ["ok":"ok"]
            try response.render("AddPizza.stencil", context: context)
            response.status(.OK)
            next()
            
        }

        router.post("/add/pizza"){ request, response, next in
            guard let parsedBody = request.body?.asURLEncoded else {
                next()
                return ;
            }
            guard let nom = parsedBody["nom"]
                else{
                    print("something went wrong")
                    return ;
            }
            var ingredients : [String?]
            
            ingredients = [parsedBody["ingre1"],parsedBody["ingre2"],parsedBody["ingre3"]]
            
            let pizza = Pizza(name: nom, ingredients: ingredients)
            
            pizzaStore.append(pizza)
            try response.redirect("/pizzas")
            
        }

    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
    
    func storeHandler(pizza: Pizza, completion: (Pizza?, RequestError?) -> Void ) {
        pizzaStore[pizza.name] = pizza
        completion(pizzaStore[pizza.name], nil)
    }
    
    func loadHandler(completion: ([Pizza]?, RequestError?) -> Void ) {
        let pizzas: [Pizza] = self.pizzaStore.map({ $0.value })
        completion(pizzas, nil)
    }
    
    func summaryHandler(completion: (Summary?, RequestError?) -> Void ) {
        let summary: Summary = Summary(self.pizzaStore)
        completion(summary, nil)
    }
}
