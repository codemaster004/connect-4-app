//
//  GameViewIOS.swift
//  Connect4 (iOS)
//
//  Created by Filip Dabkowski on 08/04/2022.
//

import SwiftUI
import Combine

struct GameView: View {
    
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var roomState: RoomState
    
    @State var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State var preparingRoom: Bool = false
    
    var body: some View {
        HStack {
            if gameState.boardReady() {
                if self.orientation.isLandscape {
                    HStack {
                        players()
                            .padding(.leading)
                        BoardView()
                        actions()
                            .padding(.trailing)
                    }
                } else {
                    VStack {
                        players()
                        BoardView()
                        actions()
                    }
                }
            } else {
                Text("Sorry your room is not ready")
            }
        }
        .frame(alignment: .leading)
        .padding(.top, 15)
        .background(Color("BgColor").ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onAppear() {
            gameState.resetBoard()
            gameState.playingPlayer = 1
            gameState.players = ["Player 1", "Player 2"]
            gameState.playersWins = [
                0: 0,
                1: 0,
            ]
            self.preparingRoom.toggle()
        }
        .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            self.orientation = UIDevice.current.orientation
        }
        .sheet(isPresented: self.$preparingRoom) {
            RoomSettingView()
        }
    }
    
    @ViewBuilder
    func players() -> some View {
        if self.orientation.isLandscape {
            VStack(spacing: 20) {
                PlayerNameTag(playerNum: 0, playerColor: "Coin1")
                
                PlayerNameTag(playerNum: 1, playerColor: "Coin2")
            }
            .padding(.vertical)
        } else {
            HStack(spacing: 20) {
                PlayerNameTag(playerNum: 0, playerColor: "Coin1")
                
                PlayerNameTag(playerNum: 1, playerColor: "Coin2")
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    func actions() -> some View {
        HStack(alignment: .center) {
            if self.orientation.isLandscape {
                Spacer()
            }
            
            Button(action: {
                gameState.resetBoard()
            }) {
                VStack {
                    ZStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.accentColor)
                        
                        Image(systemName: "repeat")
                            .foregroundColor(Color.white)
                            .imageScale(.large)
                    }
                    
                    Text("Restart")
                        .foregroundColor(Color.white)
                        .fontWeight(.medium)
                    
                }
                .padding(.horizontal)
            }
            
            if self.orientation.isLandscape {
                Spacer()
            }
        }
        .padding(.bottom, 15)
    }
}

struct GameViewIOS_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameView()
                .environmentObject(GameState())
                .environmentObject(RoomState())
                .preferredColorScheme(.dark)
            
            RoomSettingView()
                .environmentObject(RoomState())
                .preferredColorScheme(.dark)
        }
        
    }
}

struct RoomSettingView: View {
    
//    @EnvironmentObject var roomState: RoomState
    
    @State var username: String = ""
    @State var roomNumber: String = ""
    @State var color: String = ""
    
    let colors = ["Coin1", "Coin2"]
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Join room")
                    .font(.title)
                    .bold()
                    .padding()
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Room: ")
                    .fontWeight(.semibold)
                
                TextField("Enter your room number", text: self.$roomNumber)
                    .padding()
                    .background(Color("CoinEmpty"))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)
                    .onReceive(Just(self.roomNumber)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.roomNumber = filtered
                        }
                    }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Username: ")
                    .fontWeight(.semibold)
                
                TextField("Enter your username", text: self.$username)
                    .padding()
                    .background(Color("CoinEmpty"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Pick color: ")
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(color).opacity(self.color == color || self.color == "" ? 1 : 0.3))
                            .onTapGesture {
                                withAnimation {
                                    self.color = color
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                
            } label: {
                Text("Join")
                    .bold()
            }
            .frame(width: getRect().width * 0.8)
            .padding()
            .background(Color("AccentColor"))
            .cornerRadius(10)

        }
        .foregroundColor(.white)
        .background(Color("BgColor"))
    }
}
