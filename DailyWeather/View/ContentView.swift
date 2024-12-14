import SwiftUI
import CoreLocation
import SDUIComponent
import SDUIParser
import SDUIRenderer


struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var address: String = ""
    @State private var showSearchSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
//                if viewModel.locationWeathers.isEmpty {
                    // 위치가 없을 때 표시할 뷰
                    
                
                    // 날씨 페이지들
                    TabView(selection: $viewModel.currentPageIndex) {
                        ForEach(viewModel.locationWeathers.indices, id: \.self) { index in
                            WeatherPageView(
                                currentWeather: viewModel.locationWeathers[index].currentWeatherComponent,
                                hourlyForecast: viewModel.locationWeathers[index].hourlyForecastComponent
                            ) { action in
                                viewModel.handleAction(action)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .indexViewStyle(.page(backgroundDisplayMode: .automatic))
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    searchButton
                }
                if !viewModel.locationWeathers.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.removeLocation(at: viewModel.currentPageIndex)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]),
                              startPoint: .top,
                              endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
        }
        .sheet(isPresented: $showSearchSheet) {
            AddressSearchView(viewModel: viewModel, address: $address)
        }
       
    }
    
    private var searchButton: some View {
        Button(action: {
            showSearchSheet.toggle()
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("주소 검색")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}


struct WeatherPageView: View {
    let currentWeather: SDUIComponent?
    let hourlyForecast: SDUIComponent?
    let onAction: (SDUIAction?) -> Void
    
    var body: some View {
        VStack {
            if let currentWeather = currentWeather {
                SDUIRendererView(component: currentWeather) { action in
                    onAction(action)
                }
            }
            
            if let hourlyForecast = hourlyForecast {
                SDUIRendererView(component: hourlyForecast) { action in
                    onAction(action)
                }
            }
        }
    }
}

// SDUIRendererView 래퍼 추가
struct SDUIRendererView: View {
    let component: SDUIComponent
    let onAction: (SDUIAction?) -> Void
    
    var body: some View {
        SDUIRenderer(component: component, onAction: onAction)
    }
}

struct AddressSearchView: View {
    @ObservedObject var viewModel: ContentViewModel
    @Binding var address: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("주소를 입력하세요", text: $address, onCommit: {
                    viewModel.searchAddress(address)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: address) { old, newValue in
                    viewModel.searchAddress(newValue)
                }
                
                
                List(viewModel.addressCandidates, id: \.self) { candidate in
                    Button(action: {
                        viewModel.selectAddress(candidate)
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(candidate.title)
                                .font(.headline)
                            Text(candidate.subtitle)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("주소 검색")
            .navigationBarItems(trailing: Button("닫기") {
                viewModel.addressCandidates.removeAll()
            })
        }
    }
}

// ContentViewModel 를 활용해서 지역을 추가 시 해당 추가된 지역 포함 모든 지역의 날씨 뷰를 보여줄 수 있도록 구현


#Preview {
    ContentView()
}


