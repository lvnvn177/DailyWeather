// ContentViewModel.swift
import SwiftUI
import SDUIParser
import SDUIComponent
import SDUIRenderer
import WeatherKit
import CoreLocation

class ContentViewModel: ObservableObject {
    @Published var currentWeathercomponent: SDUIComponent?
    @Published var hourlyForecastComponent: SDUIComponent?
    @Published var navigateToDetail: Bool = false
    
    private let weatherService = WeatherService.init()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    init() {
//        setupLocationManager()
        loadUIFromJSON()
        
        Task {
            print("test1")
            await fetchWeather(location: CLLocation(latitude: 43, longitude: -76))
            print("test")
        }
    }
    
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
    
    func loadUIFromJSON() {
        do {
            currentWeathercomponent = try SDUIParser.loadFromJSON(fileName: "currentWeather")
            hourlyForecastComponent = try SDUIParser.loadFromJSON(fileName: "hourlyForecast")
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
        case "refresh":
            refreshWeather()
        default:
            print("Unknown action type")
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else { return }
//        currentLocation = location
//        
//        Task {
//            await fetchWeatherData()
//        }
//    }
    
    
    func fetchWeather(location: CLLocation) async {
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            
            // 메인 스레드에서 UI 업데이트
            await MainActor.run {
                // 날씨 데이터 추출
                let temperature = "\(Int(round(weather.currentWeather.temperature.value)))°"
                let feelsLike = "\(Int(round(weather.currentWeather.apparentTemperature.value)))°"
                let humidity = "\(Int(round(weather.currentWeather.humidity * 100)))%"
                let windSpeed = "\(Int(round(weather.currentWeather.wind.speed.value)))m/s"
                let pressure = "\(Int(round(weather.currentWeather.pressure.value)))hPa"
                
                // 날씨 아이콘 업데이트
                let weatherIcon = getWeatherIcon(for: weather.currentWeather.condition)
                currentWeathercomponent?.updateContent(weatherIcon, for: "weather_icon")
                
                // UI 컴포넌트 업데이트
                updateWeatherUI(
                    feelsLike: feelsLike,
                    temperature: temperature,
                    humidity: humidity,
                    windSpeed: windSpeed,
                    pressure: pressure
                )
            }
        } catch {
            print("Error fetching weather: \(error)")
        }
    }
    
    private func updateWeatherUI(feelsLike: String, temperature: String, humidity: String, windSpeed: String, pressure: String) {
        // MainActor에서 UI 업데이트 수행
        Task { @MainActor in
            // 온도 업데이트
            
            currentWeathercomponent?.updateContent(feelsLike, for: "feels_like_value")
            
            currentWeathercomponent?.updateContent(temperature, for: "temperature")
            
            // 습도 업데이트
            currentWeathercomponent?.updateContent(humidity, for: "humidity_value")
            
            // 풍속 업데이트
            currentWeathercomponent?.updateContent(windSpeed, for: "wind_value")
            
            // 기압 업데이트
            currentWeathercomponent?.updateContent(pressure, for: "pressure_value")
            
            // 변경사항 알림
            objectWillChange.send()
        }
    }
//
//    private func createHourlyForecasts(from forecast: Forecast) -> [HourlyForecast] {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        return forecast.forecast.prefix(24).enumerated().map { index, hourWeather in
//            let hour = calendar.component(.hour, from: hourWeather.date)
//            let timeString = index == 0 ? "지금" : "\(hour)시"
//            let temp = Int(round(hourWeather.temperature.value))
//            
//            return HourlyForecast(
//                time: timeString,
//                temperature: "\(temp)°",
//                icon: getWeatherIcon(for: hourWeather.condition), condition: <#String#>
//            )
//        }
//    }
    
    private func getWeatherIcon(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .rain:
            return "cloud.rain.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private func refreshWeather() {
        Task {
            await fetchWeather(location: CLLocation(latitude: 43, longitude: -76))
        }
    }
    
//    @MainActor
//    private func updateHourlyForecastJSON(with forecasts: [HourlyForecast]) {
//        let hourlyJSON = createHourlyForecastJSON(with: forecasts)
//        
//        do {
//            self.hourlyForecastComponent = try SDUIParser.shared.loadFromJSONSafely(hourlyJSON)
//        } catch {
//            print("❌ Error updating hourly forecast: \(error)")
//        }
//    }
}


