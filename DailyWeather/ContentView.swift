//
//  ContentView.swift
//  DailyWeather
//
//  Created by 이영호 on 11/28/24.
//

import SwiftUI
import SDUIParser
import SDUIComponent
import SDUIRenderer

struct ContentView: View {
    @State private var component: SDUIComponent?
        
    var body: some View {
//        VStack {
//            Text("test")
//        }
        Group {
            if let component = component {
                SDUIRenderer.render(component)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadUIFromJSON()
        }
    }
    
    private func loadUIFromJSON() {
        print("📱 Starting to load UI from JSON...")
        
        // 1. Bundle에서 JSON 파일 찾기
        guard let url = Bundle.main.url(forResource: "weather_ui", withExtension: "json") else {
            print("❌ Failed to find weather_screen.json in bundle")
            return
        }
        print("✅ Found JSON file at: \(url.path)")
        
        // 2. JSON 파일 데이터 로드
        guard let jsonData = try? Data(contentsOf: url) else {
            print("❌ Failed to load data from JSON file")
            return
        }
        print("✅ Successfully loaded JSON data, size: \(jsonData.count) bytes")
        
        do {
            // 3. JSON 데이터를 SDUIComponent로 파싱
            print("🔄 Starting to parse JSON data...")
            let component = try SDUIParser.parse(jsonData: jsonData)
            print("✅ Successfully parsed JSON into SDUIComponent")
            
            // 4. 파싱된 컴포넌트 정보 출력
            print("📊 Parsed component type: \(component.type)")
            if let children = component.children {
                print("📊 Number of child components: \(children.count)")
            }
            
            // 5. 컴포넌트 설정
            self.component = component
            print("✅ UI component successfully set")
        } catch {
            print("❌ Error parsing JSON: \(error)")
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📄 JSON content: \(jsonString)")
            }
        }
    }
}

#Preview {
    ContentView()
}
