//
//  RoomConnectView.swift
//  Connect4
//
//  Created by Filip Dabkowski on 10/04/2022.
//

import SwiftUI
import Combine

struct RoomConnectView: View {
    @EnvironmentObject var roomState: RoomState
    @EnvironmentObject var network: Network
    
    @StateObject private var game = GameSocket()
    
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
//                            self.onRoomNumberCommitted()
                        }
                    }
                    .onChange(of: isFocused) { isFocused in
                        if !isFocused {
//                            self.onRoomNumberCommitted()
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
                let myPlayer = Player(nick: self.username, number: self.roomState.players?.count ?? 0, colorName: self.color)
                
                let joinAction = SubmitAction(
                    event: "JOIN",
                    action: MoveAction(
                        player: myPlayer,
                        column: 0
                    ),
                    message: ""
                )
                self.game.send(action: joinAction)
                
                guard let roomNumber = Int(self.room) else { return }
                self.roomState.roomNumber = roomNumber
                
                self.roomState.me = myPlayer
                
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
    }
    
    func onRoomNumberCommitted() {
        guard let roomNumber = Int(room) else { return }
        
        network.getRoomPlayers(roomNumber: roomNumber)
        
        self.roomState.roomNumber = roomNumber
    }
}

//struct RoomConnectView_Previews: PreviewProvider {
//    static var previews: some View {
//       RoomConnectView()
//    }
//}
