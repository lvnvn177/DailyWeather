//
//  Forecast .swift
//  DailyWeather
//
//  Created by 이영호 on 12/5/24.
//

import Foundation
import SDUIComponent

struct Forecast {
    
}


struct HourlyForecast {
    let time: String
    let temperature: String
    let icon: String
    let condition: String
}
		

struct LocationWeather: Identifiable {
    let id = UUID()
    let locationName: String
    var currentWeatherComponent: SDUIComponent?
    var hourlyForecastComponent: SDUIComponent?
    
    mutating func updateWeatherData(
        temperature: String,
        feelsLike: String,
        humidity: String,
        windSpeed: String,
        pressure: String,
        weatherIcon: String
    ) {
        // 임시 변수에 복사
        var updatedComponent = currentWeatherComponent
        
        // 임시 변수를 사용하여 업데이트
        updatedComponent?.updateContent(temperature, for: "temperature")
        updatedComponent?.updateContent(feelsLike, for: "feels_like_value")
        updatedComponent?.updateContent(humidity, for: "humidity_value")
        updatedComponent?.updateContent(windSpeed, for: "wind_value")
        updatedComponent?.updateContent(pressure, for: "pressure_value")
        updatedComponent?.updateContent(weatherIcon, for: "weather_icon")
        updatedComponent?.updateContent(locationName, for: "location_name")
        
        // 최종 업데이트된 컴포넌트를 할당
        currentWeatherComponent = updatedComponent
    }
    
    mutating func updateHourlyForecast(_ forecastItems: [SDUIComponent]) {
        var updatedComponent = hourlyForecastComponent
        updatedComponent?.updateContent(forecastItems, for: "forecast_items_container")
        hourlyForecastComponent = updatedComponent
    }
}
