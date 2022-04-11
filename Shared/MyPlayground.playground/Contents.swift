import UIKit


func checkForWinners(board: Array<Array<Int>>, new_x: Int, new_y: Int) -> Bool {
//    Diagonal /
    var axis: [Int] = []
    var b = new_y - new_x
    for i in b..<7 {
        if i >= 0 && i < 7 && i - b < 7 {
            axis.append(board[i - b][i])
        }
    }
    if checkAxis(axis: axis) {
        return true
    }
    
//    Diagonal \
    axis = []
    b = new_y + new_x
    for i in (0...b).reversed() {
        if i >= 0 && i < 7 && b - i < 7 {
            axis.append(board[b - i][i])
        }
    }
    if checkAxis(axis: axis) {
        return true
    }
    
//    Horizontal -
    axis = []
    for i in 0..<7 {
        axis.append(board[i][new_y])
    }
    if checkAxis(axis: axis) {
        return true
    }

//    Vertical |
    axis = []
    for i in 0..<7 {
        axis.append(board[new_x][i])
    }
    if checkAxis(axis: axis) {
        return true
    }
    
    return false
}

func checkAxis(axis: Array<Int>) -> Bool {
    var count = 0
    var previous = axis.first ?? 0
    for player in axis {
        if player != 0 && previous == player {
            count += 1
        } else {
            count = 1
        }
        previous = player
        if count >= 4 {
            return true
        }
    }
    return false
}

let board = [
    [1, 2, 1, 2, 0, 0, 0],
    [2, 2, 2, 1, 0, 0, 0],
    [2, 1, 1, 0, 0, 0, 0],
    [1, 1, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
]

checkForWinners(board: board, new_x: 2, new_y: 2)

checkAxis(axis: [1, 1, 1, 1, 0, 0, 0])
