import SwiftUI
import SDUIComponent
import SDUIParser
import SDUIRenderer

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let currentWeather = viewModel.currentWeathercomponent {
                    SDUIRenderer.render(currentWeather, actionHandler: viewModel.handleAction)
                        .frame(height: UIScreen.main.bounds.height * 0.65)
                }
                
                if let hourlyForecastComponent = viewModel.hourlyForecastComponent {
                    SDUIRenderer.render(hourlyForecastComponent, actionHandler: viewModel.handleAction)
                        .frame(height: UIScreen.main.bounds.height * 0.35)
                }
                
                if viewModel.currentWeathercomponent == nil || viewModel.hourlyForecastComponent == nil {
                    ProgressView()
                }
            }
            .onAppear {
                viewModel.loadUIFromJSON()
                
            }
            .navigationDestination(isPresented: $viewModel.navigateToDetail) {
                DetailView()
            }
        }
    }
}

#Preview {
    ContentView()
}
