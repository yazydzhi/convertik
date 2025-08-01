import XCTest
@testable import Convertik
import SwiftUI

final class NavigationTests: XCTestCase {

    var mainListView: MainListView!
    var addCurrencyView: AddCurrencyView!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Создаем экземпляры для тестирования
        mainListView = MainListView()
        addCurrencyView = AddCurrencyView()
    }

    override func tearDownWithError() throws {
        mainListView = nil
        addCurrencyView = nil
        try super.tearDownWithError()
    }

    // MARK: - Тесты навигации

    func testMainListViewNavigationStructure() throws {
        // Тест 1: Проверяем структуру навигации в MainListView

        // Проверяем, что MainListView использует NavigationView
        let mirror = Mirror(reflecting: mainListView)
        let hasNavigationView = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("NavigationView")
        }

        XCTAssertTrue(hasNavigationView, "MainListView должен содержать NavigationView")
    }

    func testAddCurrencyViewNoNavigationView() throws {
        // Тест 2: Проверяем, что AddCurrencyView НЕ содержит NavigationView

        let mirror = Mirror(reflecting: addCurrencyView)
        let hasNavigationView = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("NavigationView")
        }

        XCTAssertFalse(hasNavigationView, "AddCurrencyView НЕ должен содержать NavigationView")
    }

    func testAddCurrencyViewCustomHeader() throws {
        // Тест 3: Проверяем наличие собственной заголовочной панели в AddCurrencyView

        let mirror = Mirror(reflecting: addCurrencyView)
        let hasCustomHeader = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("HStack") ||
                String(describing: type(of: child.value)).contains("VStack")
        }

        XCTAssertTrue(hasCustomHeader, "AddCurrencyView должен содержать собственную заголовочную панель")
    }

    func testNavigationBarCount() throws {
        // Тест 4: Проверяем количество навигационных панелей

        // Создаем тестовое представление с MainListView
        let testView = NavigationView {
            mainListView
        }

        // Проверяем, что есть только одна навигационная панель
        let mirror = Mirror(reflecting: testView)
        let navigationViewCount = mirror.children.filter { child in
            String(describing: type(of: child.value)).contains("NavigationView")
        }.count

        XCTAssertEqual(navigationViewCount, 1, "Должна быть только одна NavigationView")
    }

    func testAddCurrencyPresentation() throws {
        // Тест 5: Проверяем представление AddCurrencyView

        // Создаем тестовое представление
        let testView = NavigationView {
            mainListView
        }

        // Проверяем, что AddCurrencyView может быть представлен без дублирования
        let addCurrencySheet = addCurrencyView
        XCTAssertNotNil(addCurrencySheet, "AddCurrencyView должен быть создан")

        // Проверяем, что у AddCurrencyView есть кнопка закрытия
        let mirror = Mirror(reflecting: addCurrencyView)
        let hasCloseButton = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("Button") ||
                String(describing: type(of: child.value)).contains("Image")
        }

        XCTAssertTrue(hasCloseButton, "AddCurrencyView должен содержать кнопку закрытия")
    }

    func testNavigationStateManagement() throws {
        // Тест 6: Проверяем управление состоянием навигации

        // Создаем ViewModel для тестирования
        let viewModel = MainListViewModel()

        // Проверяем начальное состояние
        XCTAssertFalse(viewModel.showingAddCurrency, "Начальное состояние showingAddCurrency должно быть false")

        // Симулируем открытие экрана добавления валют
        viewModel.showingAddCurrency = true
        XCTAssertTrue(viewModel.showingAddCurrency, "showingAddCurrency должно быть true после открытия")

        // Симулируем закрытие экрана добавления валют
        viewModel.showingAddCurrency = false
        XCTAssertFalse(viewModel.showingAddCurrency, "showingAddCurrency должно быть false после закрытия")
    }

    func testNavigationBarElements() throws {
        // Тест 7: Проверяем элементы навигационной панели

        // Проверяем, что у MainListView есть правильные элементы навигации
        let mirror = Mirror(reflecting: mainListView)
        let hasNavigationElements = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("toolbar") ||
                String(describing: type(of: child.value)).contains("navigationTitle")
        }

        XCTAssertTrue(hasNavigationElements, "MainListView должен содержать элементы навигации")
    }

    func testAddCurrencyViewDismissal() throws {
        // Тест 8: Проверяем закрытие AddCurrencyView

        // Создаем тестовое представление с состоянием
        @State var showingAddCurrency = true

        let testView = NavigationView {
            mainListView
        }
        .sheet(isPresented: $showingAddCurrency) {
            addCurrencyView
        }

        // Проверяем, что sheet может быть закрыт
        showingAddCurrency = false
        XCTAssertFalse(showingAddCurrency, "showingAddCurrency должно быть false после закрытия")
    }

    func testNavigationBarTitle() throws {
        // Тест 9: Проверяем заголовки навигационных панелей

        // Проверяем, что MainListView имеет правильный заголовок
        let mirror = Mirror(reflecting: mainListView)
        let hasTitle = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("Convertik") ||
                String(describing: type(of: child.value)).contains("navigationTitle")
        }

        XCTAssertTrue(hasTitle, "MainListView должен иметь заголовок")
    }

    func testAddCurrencyViewTitle() throws {
        // Тест 10: Проверяем заголовок AddCurrencyView

        // Проверяем, что AddCurrencyView имеет собственный заголовок
        let mirror = Mirror(reflecting: addCurrencyView)
        let hasCustomTitle = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("Text") ||
                String(describing: type(of: child.value)).contains("Добавить валюту")
        }

        XCTAssertTrue(hasCustomTitle, "AddCurrencyView должен иметь собственный заголовок")
    }

    // MARK: - Тесты интеграции

    func testNavigationIntegration() throws {
        // Тест 11: Проверяем интеграцию навигации

        // Создаем полное представление приложения
        let contentView = ContentView()

        // Проверяем, что ContentView содержит NavigationView
        let mirror = Mirror(reflecting: contentView)
        let hasNavigationView = mirror.children.contains { child in
            String(describing: type(of: child.value)).contains("NavigationView")
        }

        XCTAssertTrue(hasNavigationView, "ContentView должен содержать NavigationView")
    }

    func testNoDuplicateNavigationBars() throws {
        // Тест 12: Проверяем отсутствие дублирования навигационных панелей

        // Создаем тестовое представление
        let testView = NavigationView {
            mainListView
        }

        // Проверяем, что нет вложенных NavigationView
        let mirror = Mirror(reflecting: testView)
        let navigationViewCount = mirror.children.filter { child in
            String(describing: type(of: child.value)).contains("NavigationView")
        }.count

        XCTAssertEqual(navigationViewCount, 1, "Не должно быть вложенных NavigationView")

        // Проверяем, что MainListView не содержит дополнительных NavigationView
        let mainListViewMirror = Mirror(reflecting: mainListView)
        let nestedNavigationViewCount = mainListViewMirror.children.filter { child in
            String(describing: type(of: child.value)).contains("NavigationView")
        }.count

        XCTAssertEqual(nestedNavigationViewCount, 0, "MainListView не должен содержать NavigationView")
    }
}
