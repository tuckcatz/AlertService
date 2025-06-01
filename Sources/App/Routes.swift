import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    app.post("send-alert") { req async throws -> HTTPStatus in
        struct AlertRequest: Content {
            let to: String
            let message: String
        }

        let alert = try req.content.decode(AlertRequest.self)
        print("🚨 Simulated SMS to \(alert.to): \(alert.message)")
        return .ok
    }
}
