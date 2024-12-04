// ContentViewModel.swift
import SwiftUI
import SDUIParser
import SDUIComponent
import SDUIRenderer

class ContentViewModel: ObservableObject {
    @Published var component: SDUIComponent?
    @Published var navigateToDetail: Bool = false
    
    func loadUIFromJSON() {
        do {
            component = try SDUIParser.loadFromJSON(fileName: "weather_ui")
        } catch SDUIParserError.fileNotFound {
            print("❌ Failed to find JSON file")
        } catch SDUIParserError.invalidData {
            print("❌ Failed to load data from JSON file")
        } catch SDUIParserError.parsingError(let error) {
            print("❌ Error parsing JSON: \(error)")
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    func handleAction(_ action: SDUIAction?) {
        guard let action = action else { return }
        
        switch action.type {
        case "navigate":
            if action.payload["screen"] == "DetailView" {
                navigateToDetail = true
            }
        case "openURL":
            if let urlString = action.payload["url"], let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        default:
            print("Unknown action type")
        }
    }
}
