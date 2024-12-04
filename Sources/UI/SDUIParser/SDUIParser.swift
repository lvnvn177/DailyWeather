import Foundation
import SDUIComponent

public enum SDUIParserError: Error {
    case fileNotFound
    case invalidData
    case parsingError(Error)
}

public class SDUIParser {
    public static func parse(json: String) throws -> SDUIComponent { // Local, SDUIComponent의 구조 형태로 작성된 json -> SDUIComponent 변환
        guard let jsonData = json.data(using: .utf8) else {
            throw SDUIError.invalidJSON
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(SDUIComponent.self, from: jsonData)
        } catch {
            throw SDUIError.parsingFailed(error)
        }
    }
    
    public static func parse(jsonData: Data) throws -> SDUIComponent { // API, ""
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(SDUIComponent.self, from: jsonData)
        } catch {
            throw SDUIError.parsingFailed(error)
        }
    }

    public static func loadFromJSON(fileName: String) throws -> SDUIComponent {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw SDUIParserError.fileNotFound
        }
        
        guard let jsonData = try? Data(contentsOf: url) else {
            throw SDUIParserError.invalidData
        }
        
        do {
            return try parse(jsonData: jsonData)
        } catch {
            throw SDUIParserError.parsingError(error)
        }
    }
}

public enum SDUIError: Error { // json -> SDUIComponent 변환 실패 시 에러 메시지 출력
    case invalidJSON
    case parsingFailed(Error)
    case renderingFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidJSON:
            return "Invalid JSON format"
        case .parsingFailed(let error):
            return "Failed to parse JSON: \(error.localizedDescription)"
        case .renderingFailed(let message):
            return "Failed to render component: \(message)"
        }
    }
}
