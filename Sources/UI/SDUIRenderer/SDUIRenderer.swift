import SwiftUI
import SDUIComponent
import SDUIParser

public struct SDUIRenderer {
    public static func render(_ component: SDUIComponent) -> AnyView {
        return AnyView(renderComponent(component))
    }
    
    private static func renderComponent(_ component: SDUIComponent) -> AnyView {
        switch component.type {
        case .text:
            return AnyView(renderText(component))
        case .image:
            return AnyView(renderImage(component))
        case .button:
            return AnyView(renderButton(component))
        case .stack:
            return AnyView(renderStack(component))
        case .spacer:
            return AnyView(Spacer())
        case .list:
            return AnyView(renderList(component))
        }
    }
    
    private static func renderText(_ component: SDUIComponent) -> some View {
        Text(component.content ?? "")
            .modifier(FontModifier(size: component.style?.fontSize, weight: component.style?.fontWeight))
            .modifier(ForegroundModifier(color: component.style?.foregroundColor))
            .modifier(BackgroundModifier(color: component.style?.backgroundColor))
            .modifier(PaddingModifier(padding: component.style?.padding))
            .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
    }
    
    // private static func renderImage(_ component: SDUIComponent) -> some View {
    //     AsyncImage(url: URL(string: component.content ?? "")) { phase in
    //                 switch phase {
    //                 case .empty:
    //                     ProgressView()
    //                 case .success(let image):
    //                     image
    //                         .resizable()
    //                         .scaledToFit()
    //                         .modifier(FrameModifier(width: component.style?.width, height: component.style?.height))
    //                         .modifier(BackgroundModifier(color: component.style?.backgroundColor))
    //                         .modifier(PaddingModifier(padding: component.style?.padding))
    //                         .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
    //                 case .failure:
    //                     Image(systemName: "photo")
    //                 @unknown default:
    //                     EmptyView()
    //                 }
    //             }
    // }
    private static func renderImage(_ component: SDUIComponent) -> some View {
    if let content = component.content {
        if content.hasPrefix("http") || content.hasPrefix("https") {
            // URL 이미지인 경우
            AsyncImage(url: URL(string: content)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .modifier(FrameModifier(width: component.style?.width, height: component.style?.height))
                        .modifier(BackgroundModifier(color: component.style?.backgroundColor))
                        .modifier(PaddingModifier(padding: component.style?.padding))
                        .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            // SF Symbol인 경우
            Image(systemName: content)
                .resizable()
                .scaledToFit()
                .modifier(FrameModifier(width: component.style?.width, height: component.style?.height))
                .modifier(BackgroundModifier(color: component.style?.backgroundColor))
                .modifier(PaddingModifier(padding: component.style?.padding))
                .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
        }
    } else {
        // 기본 이미지
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .modifier(FrameModifier(width: component.style?.width, height: component.style?.height))
            .modifier(BackgroundModifier(color: component.style?.backgroundColor))
            .modifier(PaddingModifier(padding: component.style?.padding))
            .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
    }
}
    
    private static func renderButton(_ component: SDUIComponent) -> some View {
        Button(action: {
            // Handle action here
            print("Button tapped: \(component.action?.type ?? "")")
        }) {
            Text(component.content ?? "")
                .modifier(FontModifier(size: component.style?.fontSize, weight: component.style?.fontWeight))
                .modifier(ForegroundModifier(color: component.style?.foregroundColor))
                .modifier(BackgroundModifier(color: component.style?.backgroundColor))
                .modifier(PaddingModifier(padding: component.style?.padding))
                .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
        }
    }
    
    private static func renderStack(_ component: SDUIComponent) -> AnyView {
        if component.stackAxis == .horizontal {
            return AnyView(
                HStack(alignment: .center) {
                    ForEach(component.children ?? [], id: \.id) { child in
                        renderComponent(child)
                    }
                }
                .modifier(BackgroundModifier(color: component.style?.backgroundColor))
                .modifier(PaddingModifier(padding: component.style?.padding))
                .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
            )
        } else {
            return AnyView(
                VStack(alignment: component.stackAlignment?.alignment ?? .center) {
                    ForEach(component.children ?? [], id: \.id) { child in
                        renderComponent(child)
                    }
                }
                .modifier(BackgroundModifier(color: component.style?.backgroundColor))
                .modifier(PaddingModifier(padding: component.style?.padding))
                .modifier(CornerRadiusModifier(radius: component.style?.cornerRadius))
            )
        }
    }
    
    private static func renderList(_ component: SDUIComponent) -> AnyView {
        return AnyView(
            ScrollView {
                LazyVStack {
                    ForEach(component.children ?? [], id: \.id) { child in
                        renderComponent(child)
                    }
                }
            }
        )
    }
}

private struct FontModifier: ViewModifier {
    let size: CGFloat?
    let weight: Int?
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size ?? 16))
            .fontWeight(convertFontWeight(weight))
    }
    
    private func convertFontWeight(_ weight: Int?) -> Font.Weight {
        guard let weight = weight else { return .regular }
        switch weight {
        case 100: return .ultraLight
        case 200: return .thin
        case 300: return .light
        case 400: return .regular
        case 500: return .medium
        case 600: return .semibold
        case 700: return .bold
        case 800: return .heavy
        case 900: return .black
        default: return .regular
        }
    }
}

private struct ForegroundModifier: ViewModifier {
    let color: String?
    
    func body(content: Content) -> some View {
        content.foregroundColor(Color(hex: color ?? "#000000"))
    }
}

private struct BackgroundModifier: ViewModifier {
    let color: String?
    
    func body(content: Content) -> some View {
        content.background(Color(hex: color ?? "#FFFFFF"))
    }
}

private struct PaddingModifier: ViewModifier {
    let padding: CGFloat?
    
    func body(content: Content) -> some View {
        content.padding(padding ?? 0)
    }
}

private struct CornerRadiusModifier: ViewModifier {
    let radius: CGFloat?
    
    func body(content: Content) -> some View {
        content.cornerRadius(radius ?? 0)
    }
}

private struct FrameModifier: ViewModifier {
    let width: CGFloat?
    let height: CGFloat?
    
    func body(content: Content) -> some View {
        content.frame(
            width: width != nil ? width : nil,
            height: height != nil ? height : nil
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
