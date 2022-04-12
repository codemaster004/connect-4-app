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
    
    @Binding var isActive: Bool
    
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
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .frame(alignment: .leading)
        .padding(.top, 15)
        .background(Color("BgColor").ignoresSafeArea())
        .onAppear() {
            gameState.resetBoard()
            self.preparingRoom.toggle()
        }
        .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            self.orientation = UIDevice.current.orientation
        }
        .sheet(isPresented: self.$preparingRoom) {
            RoomConnectView(showSettings: self.$preparingRoom)
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
        .onChange(of: game.removedPlayer) { _ in
            guard let oldPlayer = game.newPlayer else { return }
            
            self.roomState.players = self.roomState.players?.filter { $0 != oldPlayer }
        }
    }
    
    @ViewBuilder
    func actions() -> some View {
        HStack(alignment: .center, spacing: 30) {
            if self.orientation.isLandscape {
                Spacer()
            }
            
            PlayerActionButton(text: "Exit", iconName: "arrow.left.to.line") {
                let leaveAction = SubmitAction(event: "LEAVE", action: MoveAction(player: self.roomState.me, column: 0), message: "")
                self.game.send(action: leaveAction)
                self.game.disconnect()
                self.roomState.reset()
                self.isActive = false
            }
            
            PlayerActionButton(text: "Reset", iconName: "repeat") {
                self.gameState.resetBoard()
            }
            
            PlayerActionButton(text: "Play", iconName: "arrowtriangle.right.fill") {
                
            }
            
            if self.orientation.isLandscape {
                Spacer()
            }
        }
        .padding(.bottom, 15)
        .onChange(of: self.gameState.players) { newValue in
            
        }
    }
}

struct GameViewIOS_Previews: PreviewProvider {
    static var previews: some View {
        GameView(isActive: .constant(true))
            .environmentObject(GameState())
            .environmentObject(RoomState())
            .environmentObject(GameSocket())
            .environmentObject(Network())
    }
}

struct PlayerActionButton: View {
    
    let text: String
    let iconName: String
    let action: () -> ()
    
    var body: some View {
        Button(action: self.action) {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.accentColor)
                    
                    Image(systemName: iconName)
                        .foregroundColor(Color.white)
                        .imageScale(.large)
                }
                
                Text(text)
                    .foregroundColor(Color.white)
                    .fontWeight(.medium)
                
            }
            .padding(.horizontal)
        }
    }
}
