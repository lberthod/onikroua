import XCTest
@testable import onykroua

final class VocabularyDataManagerTests: XCTestCase {
    
    var dataManager: VocabularyDataManager!
    
    override func setUpWithError() throws {
        dataManager = VocabularyDataManager.shared
    }
    
    override func tearDownWithError() throws {
        dataManager.clearAllCache()
    }
    
    // MARK: - Loading Tests
    
    func testLoadVocabulary_Italian_Success() throws {
        // Given
        let expectation = XCTestExpectation(description: "Italian vocabulary loads")
        
        // When
        dataManager.loadVocabularyAsync(language: "it")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let vocabulary = self.dataManager.getVocabularyByLanguage("it")
            XCTAssertFalse(vocabulary.isEmpty, "Italian vocabulary should not be empty")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testLoadVocabulary_Spanish_Success() throws {
        // Given
        let expectation = XCTestExpectation(description: "Spanish vocabulary loads")
        
        // When
        dataManager.loadVocabularyAsync(language: "es")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let vocabulary = self.dataManager.getVocabularyByLanguage("es")
            XCTAssertFalse(vocabulary.isEmpty, "Spanish vocabulary should not be empty")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnsureLoaded_DoesNotReloadExistingLanguage() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        // Allow first load to complete
        let expectation = XCTestExpectation(description: "First load completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        let startTime = CFAbsoluteTimeGetCurrent()
        dataManager.ensureLoaded(language: "it")
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Then
        XCTAssertLessThan(timeElapsed, 0.1, "ensureLoaded should be instant for already loaded language")
    }
    
    // MARK: - Data Retrieval Tests
    
    func testGetAllWords_ReturnsUniqueWords() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        let allWords = dataManager.getAllWords(language: "it")
        
        // Then
        XCTAssertFalse(allWords.isEmpty, "Should return words")
        
        // Check uniqueness
        let wordStrings = allWords.map { $0.word }
        let uniqueWords = Set(wordStrings)
        XCTAssertEqual(wordStrings.count, uniqueWords.count, "All words should be unique")
    }
    
    func testGetWordsByCategory_ValidCategory() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        let categories = dataManager.getCategories(language: "it")
        XCTAssertFalse(categories.isEmpty, "Should have categories")
        
        let firstCategory = categories.first!
        let words = dataManager.getWordsByCategory(language: "it", categoryName: firstCategory.name)
        
        // Then
        XCTAssertFalse(words.isEmpty, "Should return words for valid category")
        XCTAssertTrue(words.allSatisfy { $0.category == firstCategory.name }, "All words should belong to the category")
    }
    
    func testGetWordsByCategory_InvalidCategory() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        let words = dataManager.getWordsByCategory(language: "it", categoryName: "NonExistentCategory")
        
        // Then
        XCTAssertTrue(words.isEmpty, "Should return empty array for invalid category")
    }
    
    // MARK: - Alphabetical Sorting Tests
    
    func testGetWordsSortedAlphabetically_ReturnsCorrectStructure() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        let sortedWords = dataManager.getWordsSortedAlphabetically(language: "it")
        
        // Then
        XCTAssertFalse(sortedWords.isEmpty, "Should return sorted words")
        
        // Check that each letter's words are sorted
        for (_, words) in sortedWords {
            let wordStrings = words.map { $0.word.lowercased() }
            let sortedWordStrings = wordStrings.sorted()
            XCTAssertEqual(wordStrings, sortedWordStrings, "Words within each letter should be alphabetically sorted")
        }
    }
    
    // MARK: - Category Tests
    
    func testGetMainCategories_ReturnsValidCategories() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        let mainCategories = dataManager.getMainCategories(language: "it")
        
        // Then
        XCTAssertFalse(mainCategories.isEmpty, "Should return main categories")
        
        // Check that categories are sorted
        let sortedCategories = mainCategories.sorted()
        XCTAssertEqual(mainCategories, sortedCategories, "Main categories should be sorted")
    }
    
    func testGetSubCategoriesByMainCategory_ValidMainCategory() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When
        let mainCategories = dataManager.getMainCategories(language: "it")
        XCTAssertFalse(mainCategories.isEmpty, "Should have main categories")
        
        let firstMainCategory = mainCategories.first!
        let subCategories = dataManager.getSubCategoriesByMainCategory(language: "it", mainCategory: firstMainCategory)
        
        // Then
        XCTAssertFalse(subCategories.isEmpty, "Should return subcategories for valid main category")
        XCTAssertTrue(subCategories.allSatisfy { $0.mainCategory == firstMainCategory }, "All subcategories should belong to the main category")
    }
    
    // MARK: - Cache Tests
    
    func testCache_HitOnSecondCall() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When - First call
        let startTime1 = CFAbsoluteTimeGetCurrent()
        let allWords1 = dataManager.getAllWords(language: "it")
        let time1 = CFAbsoluteTimeGetCurrent() - startTime1
        
        // When - Second call (should hit cache)
        let startTime2 = CFAbsoluteTimeGetCurrent()
        let allWords2 = dataManager.getAllWords(language: "it")
        let time2 = CFAbsoluteTimeGetCurrent() - startTime2
        
        // Then
        XCTAssertEqual(allWords1.count, allWords2.count, "Should return same results")
        XCTAssertLessThan(time2, time1, "Second call should be faster (cache hit)")
    }
    
    func testInvalidateCache_ClearsCache() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When - Populate cache
        _ = dataManager.getAllWords(language: "it")
        
        // Then - Clear cache
        dataManager.clearAllCache()
        
        // Verify cache is cleared by checking performance
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = dataManager.getAllWords(language: "it")
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Should take longer than cache hit (simple verification)
        XCTAssertGreaterThan(timeElapsed, 0.001, "Should take time after cache clear")
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_GetAllWords() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When & Then
        measure {
            _ = dataManager.getAllWords(language: "it")
        }
    }
    
    func testPerformance_GetWordsSortedAlphabetically() throws {
        // Given
        dataManager.loadVocabularyAsync(language: "it")
        
        let expectation = XCTestExpectation(description: "Vocabulary loads")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        // When & Then
        measure {
            _ = dataManager.getWordsSortedAlphabetically(language: "it")
        }
    }
}
