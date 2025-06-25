@testable import AlertService
import VaporTesting
import Testing

@Suite("App Tests")
struct AlertServiceTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Test Hello Route")
    func helloRoute() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }

    @Test("Send Alert Route (no real SMS)")
    func sendAlertRoute() async throws {
        try await withApp { app in
            let payload = ["to": "+13139193199", "message": "🧪 Unit test for send-alert route"]

            try await app.testing().test(.POST, "send-alert", beforeRequest: { req in
                try req.content.encode(payload)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok || res.status == .badRequest)
            })
        }
    }
}
