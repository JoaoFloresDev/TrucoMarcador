
import XCTest
@testable import Truco_Marcador

class MockUserDefaults: UserDefaults {
    var gameStyleChanged = 0
    var maxPoints = 0
    var usTeamName = ""
    var theyTeamName = ""
    
    
    override func set(_ value: Any?, forKey defaultName: String) {
        switch defaultName {
        case "usTeamName": usTeamName = value as! String
            
        case "theyTeamName": theyTeamName = value as! String
            
        default: break
        }
    }
    
    override func set(_ value: Int, forKey defaultName: String) {
        if (defaultName == "maxPoints") {
            maxPoints = value
            print(maxPoints)
        }
    }
}

class Truco_MarcadorMockTests: XCTestCase {
    var sut: OptionsViewController!
    var mockUserDefaults: MockUserDefaults!
    
    override func setUp() {
        super.setUp()
        
        sut = OptionsViewController()
        mockUserDefaults = MockUserDefaults(suiteName: "testing")
        sut.defaults = mockUserDefaults
    }
    
    override func tearDown() {
        sut = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    func testEditProprietyGame() {
        XCTAssertEqual(mockUserDefaults.maxPoints, 0, "gameStyleChanged should be 0 before sendActions")
        
        sut.setUsersDefault(newUsTeamName: "nomeTest1", newTheyTeamName: "nomeTest2", newMaxPoints: "12")
        XCTAssertEqual(mockUserDefaults.maxPoints, 12, "maxPoints user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.usTeamName, "nomeTest1", "usTeamName user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.theyTeamName, "nomeTest2", "theyTeamName user default wasn't changed")
        
        sut.setUsersDefault(newUsTeamName: "nomeTest1111111111111111111", newTheyTeamName: "nomeTest2222222222222222222222", newMaxPoints: "0")
        XCTAssertEqual(mockUserDefaults.maxPoints, 12, "maxPoints user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.usTeamName, "nomeTest1111111111111111111", "usTeamName user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.theyTeamName, "nomeTest2222222222222222222222", "theyTeamName user default wasn't changed")
        
        sut.setUsersDefault(newUsTeamName: "", newTheyTeamName: "", newMaxPoints: "100")
        XCTAssertEqual(mockUserDefaults.maxPoints, 12, "maxPoints user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.usTeamName, "nomeTest1111111111111111111", "usTeamName user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.theyTeamName, "nomeTest2222222222222222222222", "theyTeamName user default wasn't changed")
        
        sut.setUsersDefault(newUsTeamName: "!!!!!!!!!!!!!!!***********", newTheyTeamName: "!!!!!!!!!!!!!!!***********", newMaxPoints: "99")
        XCTAssertEqual(mockUserDefaults.maxPoints, 99, "maxPoints user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.usTeamName, "!!!!!!!!!!!!!!!***********", "usTeamName user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.theyTeamName, "!!!!!!!!!!!!!!!***********", "theyTeamName user default wasn't changed")
        
        sut.populateInitialDefault()
        XCTAssertEqual(mockUserDefaults.maxPoints, 12, "maxPoints user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.usTeamName, "Nós", "usTeamName user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.theyTeamName, "Eles", "theyTeamName user default wasn't changed")
        
        sut.setUsersDefault(newUsTeamName: "a", newTheyTeamName: "a", newMaxPoints: "0")
        XCTAssertEqual(mockUserDefaults.maxPoints, 12, "maxPoints user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.usTeamName, "a", "usTeamName user default wasn't changed")
        XCTAssertEqual(mockUserDefaults.theyTeamName, "a", "theyTeamName user default wasn't changed")
    }
}
