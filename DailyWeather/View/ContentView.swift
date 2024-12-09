import SwiftUI
import CoreLocation
import SDUIComponent
import SDUIParser
import SDUIRenderer

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
        
    var body: some View {
        ZStack {
//            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all)
            
            NavigationStack {
                VStack(spacing: 0) {
                    if let currentWeather = viewModel.currentWeathercomponent {
                        SDUIRenderer.render(currentWeather, actionHandler: viewModel.handleAction)
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                    }
                    
                    if let hourlyForecastComponent = viewModel.hourlyForecastComponent {
                        SDUIRenderer.render(hourlyForecastComponent, actionHandler: viewModel.handleAction)
                            .frame(minHeight: 200)  // 최소 높이 지정
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.3)  // 최대 높이 지정
                    }
                    
                    if viewModel.currentWeathercomponent == nil || viewModel.hourlyForecastComponent == nil {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .top, endPoint: .bottom)
                                           .edgesIgnoringSafeArea(.all)
                )
                .onAppear {
                    Task {
                        await viewModel.fetchWeather(location: CLLocation(latitude: 37.5665, longitude: 126.9780))
                    }
                }
            }
        }
        .background(Color.blue)
    }
}

#Preview {
    ContentView()
}
