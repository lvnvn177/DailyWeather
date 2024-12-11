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
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    Button(action: {
                        showSearchSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("주소 검색")
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
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
                .sheet(isPresented: $showSearchSheet) {
                    AddressSearchView(viewModel: viewModel, address: $address)
                }
            }
            .background(Color.blue)
        }
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
#Preview {
    ContentView()
}

//import SwiftUI
//import CoreLocation
//import SDUIComponent
//import SDUIParser
//import SDUIRenderer
//import MapKit
//
//struct ContentView: View {
//    @StateObject private var viewModel = ContentViewModel()
//    @State private var address: String = ""
//    @State private var showAddressSearch = false
//    
//    var body: some View {
//        ZStack {
//            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all)
//            
//            NavigationStack {
//                VStack(spacing: 0) {
//                    Button(action: {
//                        showAddressSearch.toggle()
//                    }) {
//                        HStack {
//                            Image(systemName: "magnifyingglass")
//                            Text("주소 검색")
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                    }
//                    
//                    if let currentWeather = viewModel.currentWeathercomponent {
//                        SDUIRenderer.render(currentWeather, actionHandler: viewModel.handleAction)
//                            .background(Color.clear)
//                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
//                    }
//                    
//                    if let hourlyForecastComponent = viewModel.hourlyForecastComponent {
//                        SDUIRenderer.render(hourlyForecastComponent, actionHandler: viewModel.handleAction)
//                            .background(Color.clear)
//                            .frame(minHeight: 200)
//                            .frame(maxHeight: UIScreen.main.bounds.height * 0.3)
//                    }
//                    
//                    if viewModel.currentWeathercomponent == nil || viewModel.hourlyForecastComponent == nil {
//                        Spacer()
//                        ProgressView()
//                        Spacer()
//                    }
//                }
//                .background(
//                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .top, endPoint: .bottom)
//                        .edgesIgnoringSafeArea(.all)
//                )
//                .onAppear {
//                    Task {
//                        await viewModel.fetchWeather(for: "서울")
//                    }
//                }
//                .sheet(isPresented: $showAddressSearch) {
//                    AddressSearchView(viewModel: viewModel, address: $address)
//                }
//            }
//        }
//    }
//}
//
//struct AddressSearchView: View {
//    @ObservedObject var viewModel: ContentViewModel
//    @Binding var address: String
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("주소를 입력하세요", text: $address, onCommit: {
//                    viewModel.searchAddress(address)
//                })
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//                
//                List(viewModel.addressCandidates, id: \.self) { candidate in
//                    Button(action: {
//                        viewModel.selectAddress(candidate)
//                    }) {
//                        VStack(alignment: .leading) {
//                            Text(candidate.title)
//                                .font(.headline)
//                            Text(candidate.subtitle)
//                                .font(.subheadline)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("주소 검색")
//            .navigationBarItems(trailing: Button("닫기") {
//                viewModel.addressCandidates.removeAll()
//            })
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
