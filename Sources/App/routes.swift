import Vapor
import Crypto
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let todoController = TodoController()
    
    router.get("todos", use: todoController.index)
//    basicAuthGroup.post("todos", use: todoController.create)
//    basicAuthGroup.delete("todos", Todo.parameter, use: todoController.delete)
    
    let userController = UserController()
    try userController.boot(router: router)
}
