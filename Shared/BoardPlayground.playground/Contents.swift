
import SwiftUI
import PlaygroundSupport

struct BoardView: View {
    
    let player_colors = [
        "empty": Color.black,
        "red": Color.red,
        "yellow": Color.yellow
    ]
    
    var body: some View {
        VStack {
            ForEach(0..<7) { j in
                HStack {
                    ForEach(0..<7) { i in
                        CoinView(diameter: 50, color: player_colors["red"] ?? Color.black)
                        
                    }
                }
            }
        }
        .padding(7)
        .background(Color.init(red: 39, green: 38, blue: 40))
    }
}

struct CoinView: View {
    
    @State var diameter: CGFloat
    @State var color: Color
    
    var body: some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .foregroundColor(color)
    }
}


let view = BoardView()
PlaygroundPage.current.setLiveView(view)
