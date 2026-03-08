import XCTest

final class GardenGridUITests: XCTestCase {
    func testCriticalFlowSkeleton() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Spaces"].tap()
        app.buttons["Add"].tap()

        app.tabBars.buttons["Approvals"].tap()
        if app.buttons["Approve Once"].firstMatch.exists {
            app.buttons["Approve Once"].firstMatch.tap()
        }
    }
}
