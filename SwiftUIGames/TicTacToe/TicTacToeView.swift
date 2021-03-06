//
//  TicTacToe.swift
//  SwiftUIGames
//
//  Created by Berik Visschers on 2019-06-16.
//  Copyright © 2019 Berik Visschers. All rights reserved.
//

import SwiftUI

struct TicTacToeView: View {
    @State private var game = TicTacToe()

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            HeaderView(gameState: game.state)

            BoardView { row, column in
                CellView(cell: self.game.cellAt(row, column)) {
                    self.game.play(row, column)
                }
            }
                .overlay(WinningLineView(winningLine: game.winningLine))

            Button(action: { self.game.replay() },
                   label: { Text("Replay") })
        }
    }
}

private struct HeaderView: View {
    let gameState: TicTacToe.GameState
    init(gameState: TicTacToe.GameState) {
        self.gameState = gameState
    }

    var body: some View {
        switch gameState {
        case .duece: return Text("Duece")
        case let .turn(of: player): return Text("Player \(player.label) turn")
        case let .won(by: player): return Text("Won by \(player.label)")
        }
    }
}

private struct BoardView: View {
    let createCellHandler: (Int, Int) -> CellView
    init(createCellHandler: @escaping (Int, Int) -> CellView) {
        self.createCellHandler = createCellHandler
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ForEach(0..<3) { column in
                HStack(alignment: .center, spacing: 10) {
                    ForEach(0..<3) { row in
                        self.createCellHandler(row, column)
                    }
                }
            }
        }.overlay(Background())
    }
}

private struct CellView: View {
    let cell: TicTacToe.Cell
    let didTapHandler: () -> ()
    let size: CGFloat = 60

    init(cell: TicTacToe.Cell, didTapHandler: @escaping () -> ()) {
        self.cell = cell
        self.didTapHandler = didTapHandler
    }

    var body: some View {
        Button(
            action: didTapHandler,
            label: { cellContent })
    }

    private var cellContent: some View {
        ZStack {
            cross
                .animation(.spring())
                .opacity(cell == .playedBy(.x) ? 1 : 0)

            circle
                .animation(.spring())
                .opacity(cell == .playedBy(.o) ? 1 : 0)

            }
            .frame(width: self.size, height: self.size)
            .fixedSize(horizontal: true, vertical: true)
    }

    let inset = Length(10)
    let lineWidth = Length(5)
    let lineColor = Color.primary

    private var circle: some View {
        Circle()
            .inset(by: inset)
            .stroke(lineColor, lineWidth: lineWidth)
    }

    private var cross: some View {
        GeometryReader { geometry in
            Path { path in
                let xmin = self.inset
                let xmax = geometry.size.width - self.inset
                let ymin = self.inset
                let ymax = geometry.size.height - self.inset

                path.move(to: CGPoint(x: xmin, y: ymin))
                path.addLine(to: CGPoint(x: xmax, y: ymax))
                path.move(to: CGPoint(x: xmin, y: ymax))
                path.addLine(to: CGPoint(x: xmax, y: ymin))
            }
                .stroke(self.lineColor, lineWidth: self.lineWidth)
        }
    }
}

private struct WinningLineView: View {
    let winningLine: [TicTacToe.BoardIndex]?
    init(winningLine: [TicTacToe.BoardIndex]?) {
        self.winningLine = winningLine
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let line = self.winningLine else { return }

                let cellMargin: CGFloat = 10
                let strokeWidth = (geometry.size.width + cellMargin) / 3 * 2
                let min = (geometry.size.width - strokeWidth) / 2
                let center = geometry.size.width / 2
                let max = min + strokeWidth

                func coordinate(for index: Int) -> CGFloat {
                    switch index {
                    case 0: return min
                    case 1: return center
                    case 2: return max
                    default: fatalError()
                    }
                }

                path.move(to: CGPoint(x: coordinate(for: line[0].0),
                                      y: coordinate(for: line[0].1)))
                path.addLine(to: CGPoint(x: coordinate(for: line[2].0),
                                         y: coordinate(for: line[2].1)))
            }
                .stroke(style: StrokeStyle(lineCap: .round))
                .stroke(Color.orange, lineWidth: 6)
        }
    }
}

private struct Background: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: geometry.size.width / 3,
                                      y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width / 3,
                                         y: geometry.size.height))
                path.move(to: CGPoint(x: geometry.size.width * 2 / 3,
                                      y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width * 2 / 3,
                                         y: geometry.size.height))
                path.move(to: CGPoint(x: 0,
                                      y: geometry.size.height / 3))
                path.addLine(to: CGPoint(x: geometry.size.width,
                                         y: geometry.size.height / 3))
                path.move(to: CGPoint(x: 0,
                                      y: geometry.size.height * 2 / 3))
                path.addLine(to: CGPoint(x: geometry.size.width,
                                         y: geometry.size.height * 2 / 3))
                }
                .stroke(Color.secondary, lineWidth: Length(2))
        }
    }
}

#if DEBUG
struct TicTacToeView_Previews : PreviewProvider {
    static var previews: some View {
        TicTacToeView()
    }
}
#endif
