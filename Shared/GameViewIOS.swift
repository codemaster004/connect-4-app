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
    @EnvironmentObject var game: GameSocket
    
    @State var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State var preparingRoom: Bool = false
    
    var body: some View {
        HStack {
            if self.gameState.boardReady() {
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
        .onAppear() {
            gameState.resetBoard()
//            gameState.playingPlayer = 1
//            gameState.players = ["Player 1", "Player 2"]
//            gameState.playersWins = [
//                0: 0,
//                1: 0,
//            ]
            self.preparingRoom.toggle()
        }
        .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            self.orientation = UIDevice.current.orientation
        }
        .sheet(isPresented: self.$preparingRoom) {
            RoomSettingView(showSettings: self.$preparingRoom)
        }
    }
    
    @ViewBuilder
    func players() -> some View {
        VStack {
            if self.orientation.isLandscape {
                VStack(spacing: 20) {
                    ForEach(self.roomState.players ?? [], id: \.number) { player in
                        PlayerNameTag(playerNum: player.number, playerColor: player.colorName, playerName: player.nick)
                    }
                }
                .padding(.vertical)
            } else {
                HStack(spacing: 20) {
                    ForEach(self.roomState.players ?? [], id: \.number) { player in
                        PlayerNameTag(playerNum: player.number, playerColor: player.colorName, playerName: player.nick)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: game.newPlayer) { _ in
            guard let newPlayer = game.newPlayer else { return }
            
            self.roomState.players?.append(newPlayer)
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
            
            RoomSettingView(showSettings: .constant(true))
                .environmentObject(RoomState())
                .environmentObject(Network())
        }
        
    }
}

struct RoomSettingView: View {
    
    @EnvironmentObject var roomState: RoomState
    @EnvironmentObject var network: Network
    @EnvironmentObject var game: GameSocket
    
    @Binding var showSettings: Bool
    
    @State var username: String = ""
    @State var room: String = ""
    @State var color: String = ""
    @State var colours = ["Coin1", "Coin2", "Coin3"]
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Join room")
                    .font(.title)
                    .bold()
                    .padding()
                
                Spacer()
            }
            
//            Room Number
            VStack(alignment: .leading, spacing: 10) {
                Text("Room: ")
                    .fontWeight(.semibold)
                
                TextField("Enter your room number", text: self.$room)
                    .padding()
                    .background(Color("CoinEmpty"))
                    .cornerRadius(10)
                    .focused($isFocused)
                    .keyboardType(.numberPad)
                    .onReceive(Just(self.room)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.room = filtered
                        }
                    }
                    .onChange(of: isFocused) { isFocused in
                        if !isFocused {
                            self.onRoomNumberEntered()
                        }
                    }
            }
            .padding(.horizontal)
            
//            Username
            VStack(alignment: .leading) {
                Text("Username: ")
                    .fontWeight(.semibold)
                
                TextField("Enter your username", text: self.$username)
                    .padding()
                    .background(Color("CoinEmpty"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
//            Colors
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Pick color: ")
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    ForEach(colours, id: \.self) { color in
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
                .onChange(of: network.roomStatus) { _ in
                    for player in network.roomStatus.players {
                        self.colours = self.colours.filter { $0 != player.colorName}
                    }

                    if self.colours.isEmpty {
                        print("Room is full")
                    }

                    self.roomState.players = network.roomStatus.players
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                let myPlayer = Player(nick: self.username, number: (self.roomState.players?.count ?? 0) + 1, colorName: self.color)
                self.addPlayerToRoom(player: myPlayer)
                self.updateRoomState(player: myPlayer)
                
                self.showSettings = false
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
        .onAppear() {
            self.roomState.roomNumber = 0
        }
    }
    
    private func onRoomNumberEntered() {
        guard let roomNumber = Int(room) else { return }

        network.getRoomPlayers(roomNumber: roomNumber)
        game.connect(roomNumber: roomNumber)

        self.roomState.roomNumber = roomNumber
    }
    
    private func addPlayerToRoom(player: Player) {
        let joinAction = SubmitAction(
            event: "JOIN",
            action: MoveAction(
                player: player,
                column: 0
            ),
            message: ""
        )
        self.game.send(action: joinAction)
    }
    
    private func updateRoomState(player: Player) {
        guard let roomNumber = Int(self.room) else { return }
        self.roomState.roomNumber = roomNumber
        
        self.roomState.me = player
    }
}
