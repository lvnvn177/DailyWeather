import SwiftUI
import SDUIComponent
import SDUIParser
import SDUIRenderer

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
        
    var body: some View {
        NavigationStack {
            Group {
                if let component = viewModel.component {
                    SDUIRenderer.render(component, actionHandler: viewModel.handleAction)
                } else {
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
