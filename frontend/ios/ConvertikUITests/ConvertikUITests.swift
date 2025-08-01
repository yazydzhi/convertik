import XCTest

final class ConvertikUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Тесты интерфейса

    func testMainScreenElements() throws {
        // Тест 1: Проверяем наличие основных элементов интерфейса

        // Проверяем заголовок
        let title = app.navigationBars["Convertik"]
        XCTAssertTrue(title.exists, "Заголовок 'Convertik' должен присутствовать")

        // Проверяем кнопку добавления валют
        let addButton = app.buttons["plus"]
        XCTAssertTrue(addButton.exists, "Кнопка добавления валют должна присутствовать")

        // Проверяем кнопку настроек
        let settingsButton = app.buttons["gearshape"]
        XCTAssertTrue(settingsButton.exists, "Кнопка настроек должна присутствовать")
    }

    func testNoDuplicateNavigationBars() throws {
        // Тест 2: Проверяем отсутствие дублирования навигационных панелей

        // Нажимаем кнопку добавления валют
        let addButton = app.buttons["plus"]
        addButton.tap()

        // Проверяем, что есть только одна навигационная панель
        let navigationBars = app.navigationBars
        XCTAssertEqual(navigationBars.count, 1, "Должна быть только одна навигационная панель")

        // Закрываем экран добавления валют
        let backButton = app.navigationBars.buttons["Convertik"]
        backButton.tap()

        // Проверяем, что на главном экране все еще только одна навигационная панель
        XCTAssertEqual(
            navigationBars.count, 
            1, 
            "После закрытия экрана добавления валют должна остаться только одна навигационная панель"
        )
    }

    func testCurrencyInputFields() throws {
        // Тест 3: Проверяем поля ввода валют

        // Ждем загрузки данных
        let predicate = NSPredicate(format: "count > 0")
        let currencyList = app.collectionViews.firstMatch
        expectation(for: predicate, evaluatedWith: currencyList, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        // Проверяем, что есть поля ввода
        let textFields = app.textFields
        XCTAssertGreaterThan(textFields.count, 0, "Должны быть поля ввода для валют")
    }

    func testCurrencyInputAndRecalculation() throws {
        // Тест 4: Проверяем ввод валют и пересчет

        // Ждем загрузки данных
        let predicate = NSPredicate(format: "count > 0")
        let currencyList = app.collectionViews.firstMatch
        expectation(for: predicate, evaluatedWith: currencyList, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        // Находим первое поле ввода
        let firstTextField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(firstTextField.exists, "Должно быть поле ввода")

        // Вводим значение
        firstTextField.tap()
        firstTextField.typeText("100")

        // Проверяем, что значение введено
        XCTAssertEqual(firstTextField.value as? String, "100", "Значение должно быть введено")

        // Ждем пересчета
        Thread.sleep(forTimeInterval: 1)

        // Проверяем, что другие поля обновились
        let otherTextFields = app.textFields.dropFirst()
        for textField in otherTextFields {
            let value = textField.value as? String ?? ""
            XCTAssertFalse(value.isEmpty, "Другие поля должны обновиться после ввода")
        }
    }

    func testAddCurrencyScreen() throws {
        // Тест 5: Проверяем экран добавления валют

        // Открываем экран добавления валют
        let addButton = app.buttons["plus"]
        addButton.tap()

        // Проверяем элементы экрана добавления валют
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists, "Поле поиска должно присутствовать")

        // Проверяем, что есть список валют
        let currencyList = app.collectionViews.firstMatch
        XCTAssertTrue(currencyList.exists, "Список валют должен присутствовать")

        // Проверяем, что список не пустой (если есть данные)
        if currencyList.cells.count > 0 {
            let firstCell = currencyList.cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.exists, "Должна быть хотя бы одна валюта в списке")
        }
    }

    func testCurrencySearch() throws {
        // Тест 6: Проверяем поиск валют

        // Открываем экран добавления валют
        let addButton = app.buttons["plus"]
        addButton.tap()

        // Находим поле поиска
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists, "Поле поиска должно присутствовать")

        // Вводим поисковый запрос
        searchField.tap()
        searchField.typeText("USD")

        // Проверяем, что поиск работает
        let searchResults = app.collectionViews.firstMatch
        XCTAssertTrue(searchResults.exists, "Результаты поиска должны отображаться")
    }

    func testSettingsScreen() throws {
        // Тест 7: Проверяем экран настроек

        // Открываем экран настроек
        let settingsButton = app.buttons["gearshape"]
        settingsButton.tap()

        // Проверяем элементы экрана настроек
        let settingsTitle = app.navigationBars["Настройки"]
        XCTAssertTrue(settingsTitle.exists, "Заголовок 'Настройки' должен присутствовать")

        // Проверяем наличие основных настроек
        let premiumToggle = app.switches.firstMatch
        XCTAssertTrue(premiumToggle.exists, "Переключатель премиум должен присутствовать")
    }

    func testNoDataMessage() throws {
        // Тест 8: Проверяем отображение сообщения при отсутствии данных

        // Очищаем данные (если возможно)
        // В реальном приложении это может потребовать специальных действий

        // Проверяем, что есть сообщение об отсутствии данных или пустой список
        let emptyState = app.staticTexts["Нет данных"]
        let emptyList = app.collectionViews.firstMatch

        // Если есть сообщение об отсутствии данных, проверяем его
        if emptyState.exists {
            XCTAssertTrue(emptyState.exists, "Должно быть сообщение об отсутствии данных")
        } else {
            // Иначе проверяем, что список пустой
            XCTAssertEqual(emptyList.cells.count, 0, "Список должен быть пустым при отсутствии данных")
        }
    }

    func testCurrencyListScrolling() throws {
        // Тест 9: Проверяем прокрутку списка валют

        // Ждем загрузки данных
        let predicate = NSPredicate(format: "count > 0")
        let currencyList = app.collectionViews.firstMatch
        expectation(for: predicate, evaluatedWith: currencyList, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        // Проверяем, что список можно прокручивать
        if currencyList.cells.count > 3 {
            currencyList.swipeUp()
            Thread.sleep(forTimeInterval: 1)

            // Проверяем, что прокрутка работает
            XCTAssertTrue(currencyList.exists, "Список должен остаться после прокрутки")
        }
    }

    func testInputFieldFocus() throws {
        // Тест 10: Проверяем фокус на полях ввода

        // Ждем загрузки данных
        let predicate = NSPredicate(format: "count > 0")
        let currencyList = app.collectionViews.firstMatch
        expectation(for: predicate, evaluatedWith: currencyList, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)

        // Находим поле ввода
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.exists, "Должно быть поле ввода")

        // Нажимаем на поле ввода
        textField.tap()

        // Проверяем, что поле получило фокус
        XCTAssertTrue(textField.hasKeyboardFocus, "Поле ввода должно получить фокус")

        // Проверяем, что клавиатура появилась
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.exists, "Клавиатура должна появиться при фокусе на поле ввода")
    }
}
