// ContentViewModel.swift
import SwiftUI
import SDUIParser
import SDUIComponent
import SDUIRenderer
import WeatherKit
import CoreLocation
import ApiManager
import MapKit

class ContentViewModel: NSObject,ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var currentWeathercomponent: SDUIComponent?
    @Published var hourlyForecastComponent: SDUIComponent?
    @Published var addressCandidates: [MKLocalSearchCompletion] = []
    @Published var navigateToDetail: Bool = false
    
    private let weatherService = WeatherService.init()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var searchCompleter = MKLocalSearchCompleter()
   
    
    override init() {
        super.init()
        setupLocationManager()
        setupSearchCompleter()
        loadUIFromJSON()
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("위치 서비스 권한이 없습니다.")
            // 기본 위치 사용 (예: 서울)
            let defaultLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
            Task {
                await fetchWeather(location: defaultLocation)
            }
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    
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
    
    func searchAddress(_ address: String) {
        searchCompleter.queryFragment = address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            addressCandidates = completer.results
            print("검색 결과 업데이트: \(completer.results)")
    }
    
    
    
     func selectAddress(_ completion: MKLocalSearchCompletion) {
         let searchRequest = MKLocalSearch.Request(completion: completion)
         let search = MKLocalSearch(request: searchRequest)
         search.start { response, error in
             if let error = error {
                 print("주소 검색 오류: \(error.localizedDescription)")
                 return
             }
             guard let response = response, let mapItem = response.mapItems.first else {
                 print("주소 검색 결과가 없습니다.")
                 return
             }
             let location = mapItem.placemark.location
             let locationName = mapItem.name ?? "알 수 없는 위치"
             Task {
                 await self.fetchWeather(location: location!)
                 await self.updateLocationName(locationName)
             }
         }
     }
        
    
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
                
                updateHourlyForecast(weather.hourlyForecast.forecast)
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
    

    
    private func updateHourlyForecast(_ forecasts: [HourWeather]) {
        // 24시간 예보만 사용
        let now = Date()
//        let next24Hours = Array(forecasts.prefix(24))
        let next24Hours = Calendar.current.date(byAdding: .hour, value: 24, to: now)!
        
        let filteredForecasts = forecasts.filter { $0.date >= now && $0.date <= next24Hours }
        // 각 시간대별 수직 스택 생성
        let forecastItems = filteredForecasts.enumerated().map { index, forecast in
            // 각 시간대별 수직 스택
            SDUIComponent(
                type: .stack,
                id: "forecast_item_\(index)",
                style: SDUIStyle(
                    padding: 8,
                    spacing: 8
                ),
                children: [
                    // 시간
                    SDUIComponent(
                        type: .text,
                        id: "time_\(index)",
                        content: index == 0 ? "지금" : formatTime(forecast.date),
                        style: SDUIStyle(
                            foregroundColor: "#FFFFFF",
                            fontSize: 14,
                            alignment: .center
                        )
                    ),
                    // 아이콘
                    SDUIComponent(
                        type: .image,
                        id: "icon_\(index)",
                        content: getWeatherIcon(for: forecast.condition),
                        style: SDUIStyle(
                            foregroundColor: "#FFFFFF",
                            width: 30,
                            height: 30
                        )
                    ),
                    // 온도
                    SDUIComponent(
                        type: .text,
                        id: "temp_\(index)",
                        content: "\(Int(round(forecast.temperature.value)))°",
                        style: SDUIStyle(
                            foregroundColor: "#FFFFFF",
                            fontSize: 16,
                            fontWeight: 600,
                            alignment: .center
                        )
                    )
                ],
                stackAxis: .vertical,
                stackAlignment: .center
            )
        }
        
        // forecast_items_container 업데이트
        hourlyForecastComponent?.updateContent(forecastItems, for: "forecast_items_container")
        objectWillChange.send()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    


    
    private func getWeatherIcon(for condition: WeatherCondition) -> String {
            switch condition {
            case .clear:
                return "sun.max.fill"
            case .cloudy:
                return "cloud.fill"
            case .mostlyClear:
                return "sun.max.fill"
            case .mostlyCloudy:
                return "cloud.sun.fill"
            case .partlyCloudy:
                return "cloud.sun.fill"
            case .rain:
                return "cloud.rain.fill"
            case .snow:
                return "cloud.snow.fill"
            case .sleet:
                return "cloud.sleet.fill"
            case .windy:
                return "wind"
            case .drizzle:
                return "cloud.drizzle.fill"
            case .thunderstorms:
                return "cloud.bolt.rain.fill"
            case .haze:
                return "sun.haze.fill"
            default:
                return "cloud.fill"
            }
        }
    
    private func refreshWeather() {
        Task {
            await fetchWeather(location: CLLocation(latitude: 43, longitude: -76))
        }
    }
    
    private func updateLocationName(_ locationName: String) async {
        currentWeathercomponent?.updateContent(locationName, for: "location_name")
        objectWillChange.send()
    }
    

}

extension ContentViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        
        // 위치를 한 번 받았으면 업데이트 중지
        locationManager.stopUpdatingLocation()
        
        // 위치 정보로 날씨 데이터 가져오기
        Task {
            await fetchWeather(location: location)
            await getLocationName(for: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 정보 오류: \(error.localizedDescription)")
        // 오류 발생 시 기본 위치 사용
        let defaultLocation = CLLocation(latitude: 37.5665, longitude: 126.9780)
        Task {
            await fetchWeather(location: defaultLocation)
        }
    }
    
    // 위치의 지역 이름 가져오기
    private func getLocationName(for location: CLLocation) async {
        let geocoder = CLGeocoder()
        do {
            if let placemark = try await geocoder.reverseGeocodeLocation(location).first {
                await MainActor.run {
                    let locationName = placemark.locality ?? placemark.administrativeArea ?? "알 수 없는 위치"
                    currentWeathercomponent?.updateContent(locationName, for: "location_name")
                }
            }
        } catch {
            print("지역 이름 가져오기 실패: \(error.localizedDescription)")
        }
    }
}

