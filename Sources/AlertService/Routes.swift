import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    app.post("send-alert") { req async throws -> HTTPStatus in
        app.logger.info("📩 /send-alert endpoint triggered")

        struct AlertRequest: Content {
            let to: String
            let message: String
        }

        let alert = try req.content.decode(AlertRequest.self)

        // Load environment variables
        guard
            let accountSID = Environment.get("TWILIO_ACCOUNT_SID"),
            let authToken = Environment.get("TWILIO_AUTH_TOKEN"),
            let fromNumber = Environment.get("TWILIO_PHONE_NUMBER")
        else {
            throw Abort(.internalServerError, reason: "Missing Twilio credentials")
        }

        let twilioURL = URI(string: "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages.json")

        let body = [
            "To": alert.to,
            "From": fromNumber,
            "Body": alert.message
        ]

        let credentials = "\(accountSID):\(authToken)"
        let encoded = Data(credentials.utf8).base64EncodedString()

        let headers: HTTPHeaders = [
            "Authorization": "Basic \(encoded)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let response = try await req.client.post(twilioURL, headers: headers) { req in
            try req.content.encode(body, as: .urlEncodedForm)
        }

        guard response.status == .created else {
            let error = try? response.body?.getString(at: 0, length: response.body?.readableBytes ?? 0)
            throw Abort(.badRequest, reason: "Failed to send SMS: \(error ?? "Unknown error")")
        }

        app.logger.info("✅ SMS sent to \(alert.to)")
        return .ok
    }
}
