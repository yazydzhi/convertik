import XCTest

final class ConvertikScreenshotUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testScreenshotsLightAndDark() throws {
        // Светлая тема
        app.launchArguments = ["-uiuserInterfaceStyle", "light", "-AppleInterfaceStyle", "Light"]
        app.launch()
        takeAllScreenshots(theme: "light")
        app.terminate()

        // Тёмная тема
        app.launchArguments = ["-uiuserInterfaceStyle", "dark", "-AppleInterfaceStyle", "Dark"]
        app.launch()
        takeAllScreenshots(theme: "dark")
        app.terminate()
    }

    func takeAllScreenshots(theme: String) {
        // Главный экран
        let mainScreen = XCUIScreen.main.screenshot()
        let mainAttachment = XCTAttachment(screenshot: mainScreen)
        mainAttachment.name = "\(theme)_main"
        mainAttachment.lifetime = .keepAlways
        add(mainAttachment)

        // Открыть настройки
        app.buttons["settingsButton"].tap()
        sleep(1)
        let settingsScreen = XCUIScreen.main.screenshot()
        let settingsAttachment = XCTAttachment(screenshot: settingsScreen)
        settingsAttachment.name = "\(theme)_settings"
        settingsAttachment.lifetime = .keepAlways
        add(settingsAttachment)
        app.buttons["doneButton"].tap()
        sleep(1)

        // Открыть добавить валюту
        app.buttons["addCurrencyButton"].tap()
        sleep(1)
        let addCurrencyScreen = XCUIScreen.main.screenshot()
        let addCurrencyAttachment = XCTAttachment(screenshot: addCurrencyScreen)
        addCurrencyAttachment.name = "\(theme)_add_currency"
        addCurrencyAttachment.lifetime = .keepAlways
        add(addCurrencyAttachment)
        app.buttons["cancelButton"].tap()
        sleep(1)
    }
}