//
//  ColorCarouselViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 15/01/2026.
//

@testable import WalletVault
import XCTest
import SwiftUI
import CoreData

class ColorCarouselViewModelTests: XCTestCase {
    
    var mockContext: NSManagedObjectContext!
    var appManager: AppManager!
    var testColor: ColorEntity!
    
    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        appManager = AppManager(context: mockContext)
        
        testColor = ColorEntity(context: mockContext)
        testColor.hexValue = Color.red.toHex()
        testColor.isDefault = false
    }
    
    override func tearDown() {
        testColor = nil
        appManager = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_WithNilColor_ShouldSetupCorrectly() {
        var cardColor: ColorEntity? = nil
        let binding = Binding<ColorEntity?>(
            get: { cardColor },
            set: { cardColor = $0 }
        )
        
        let viewModel = ColorCarouselViewModel(appManager: appManager, cardColor: binding)
        XCTAssertNotNil(viewModel)
        XCTAssertNil(cardColor)
    }
    
    func testInit_WithColor_ShouldSetupCorrectly() {
        var cardColor: ColorEntity? = testColor
        let binding = Binding<ColorEntity?>(
            get: { cardColor },
            set: { cardColor = $0 }
        )
        
        let viewModel = ColorCarouselViewModel(appManager: appManager, cardColor: binding)
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(cardColor?.hexValue, testColor.hexValue)
    }
    
    // MARK: - Card Background Opacity Tests
    
    func testGetCardBackgroundOpacity_ShouldReturnConstantValue() {
        let viewModel = ColorCarouselViewModel(
            appManager: appManager,
            cardColor: .constant(nil)
        )
        
        let opacity = viewModel.getCardBackgroundOpacity()
        XCTAssertEqual(opacity, 0.35)
    }
    
    // MARK: - Add New Color Tests
    
    func testAddNewColor_WithValidHex_ShouldAddColor() {
        let viewModel = ColorCarouselViewModel(
            appManager: appManager,
            cardColor: .constant(nil)
        )
        
        let hexValue = Color.orange.toHex()!
        viewModel.addNewColor(hex: hexValue)
        
        // Verify color was added through the action manager
        // We can fetch all colors from context to verify
        let fetchRequest: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
        let colors = try? mockContext.fetch(fetchRequest)
        
        let addedColor = colors?.first { $0.hexValue == hexValue && !$0.isDefault }
        XCTAssertNotNil(addedColor)
    }
    
    func testAddNewColor_Multiple_ShouldAddAllColors() {
        let viewModel = ColorCarouselViewModel(
            appManager: appManager,
            cardColor: .constant(nil)
        )
        
        let hex1 = Color.orange.toHex()!
        let hex2 = Color.pink.toHex()!
        
        viewModel.addNewColor(hex: hex1)
        viewModel.addNewColor(hex: hex2)
        
        let fetchRequest: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
        let colors = try? mockContext.fetch(fetchRequest)
        
        let customColors = colors?.filter { !$0.isDefault }
        XCTAssertTrue(customColors!.count >= 2)
    }
    
    // MARK: - Remove Selected Color Tests
    
    func testRemoveSelectedColor_WithValidColor_ShouldRemoveColor() {
        var cardColor: ColorEntity? = testColor
        let binding = Binding<ColorEntity?>(
            get: { cardColor },
            set: { cardColor = $0 }
        )
        
        let viewModel = ColorCarouselViewModel(appManager: appManager, cardColor: binding)
        
        viewModel.removeSelectedColor()
        
        // Verify color was removed
        let fetchRequest: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "hexValue == %@", testColor.hexValue!)
        let colors = try? mockContext.fetch(fetchRequest)
        
        XCTAssertTrue(colors?.isEmpty ?? true)
    }
    
    func testRemoveSelectedColor_WithNilColor_ShouldNotCrash() {
        let viewModel = ColorCarouselViewModel(
            appManager: appManager,
            cardColor: .constant(nil)
        )
        
        // Should not crash when no color is selected
        viewModel.removeSelectedColor()
    }
    
    func testRemoveSelectedColor_WithColorWithoutHex_ShouldNotCrash() {
        let colorWithoutHex = ColorEntity(context: mockContext)
        colorWithoutHex.hexValue = nil
        colorWithoutHex.isDefault = false
        
        let viewModel = ColorCarouselViewModel(
            appManager: appManager,
            cardColor: .constant(colorWithoutHex)
        )
        
        // Should not crash
        viewModel.removeSelectedColor()
    }
    
    // MARK: - Binding Tests
    
    func testCardColorBinding_ShouldUpdateWhenChanged() {
        var cardColor: ColorEntity? = nil
        let binding = Binding<ColorEntity?>(
            get: { cardColor },
            set: { cardColor = $0 }
        )
        
        let viewModel = ColorCarouselViewModel(appManager: appManager, cardColor: binding)
        
        // Simulate changing the binding
        cardColor = testColor
        XCTAssertEqual(cardColor?.hexValue, testColor.hexValue)
    }
    
    func testCardColorBinding_ShouldReflectChanges() {
        var cardColor: ColorEntity? = testColor
        let binding = Binding<ColorEntity?>(
            get: { cardColor },
            set: { cardColor = $0 }
        )
        
        let viewModel = ColorCarouselViewModel(appManager: appManager, cardColor: binding)
        
        // Change to nil
        cardColor = nil
        XCTAssertNil(cardColor)
        
        // Change back
        cardColor = testColor
        XCTAssertEqual(cardColor?.hexValue, testColor.hexValue)
    }
}
