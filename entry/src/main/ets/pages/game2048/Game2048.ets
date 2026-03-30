import WechatToolbar from '../../component/WechatToolbar'

// 定义类型接口
interface Position {
  x: number
  y: number
}

// 定义触摸点接口
interface TouchPoint {
  x: number
  y: number
}

// 定义触摸事件接口
interface GameTouchEvent {
  type: string
  touches?: Array<TouchPoint>
  changedTouches?: Array<TouchPoint>
}

// 定义遍历结构接口
interface Traversals {
  x: number[]
  y: number[]
}

// 定义位置结果接口
interface PositionResult {
  farthest: Position
  next: Position
}

@Preview
@Entry
@Component
export default struct Game2048 {
  private gridSize: number = 4
  @State private grid: Array<Array<number>> = []
  @State private score: number = 0
  @State private bestScore: number = 0
  @State private gameOver: boolean = false
  @State private gameWon: boolean = false
  @State private keepPlaying: boolean = false

  aboutToAppear() {
    this.setupGame()
  }

  setupGame() {
    // 初始化网格
    const newGrid: Array<Array<number>> = new Array(this.gridSize)
    for (let x = 0; x < this.gridSize; x++) {
      newGrid[x] = new Array(this.gridSize)
      for (let y = 0; y < this.gridSize; y++) {
        newGrid[x][y] = 0
      }
    }
    
    // 重置游戏状态
    this.score = 0
    this.gameOver = false
    this.gameWon = false
    this.keepPlaying = false
    
    // 添加初始方块
    this.grid = newGrid
    this.addRandomTile()
    this.addRandomTile()
    
    // 创建新的数组引用，触发UI更新
    this.grid = JSON.parse(JSON.stringify(this.grid))
  }

  addRandomTile() {
    const availableCells: Position[] = []
    for (let x = 0; x < this.gridSize; x++) {
      for (let y = 0; y < this.gridSize; y++) {
        if (this.grid[x][y] === 0) {
          const cell: Position = { x: x, y: y }
          availableCells.push(cell)
        }
      }
    }
    
    if (availableCells.length > 0) {
      const cell = availableCells[Math.floor(Math.random() * availableCells.length)]
      this.grid[cell.x][cell.y] = Math.random() < 0.9 ? 2 : 4
    }
  }

  move(direction: number) {
    if (this.gameOver || (this.gameWon && !this.keepPlaying)) return
    
    let moved = false
    
    // 0: up, 1: right, 2: down, 3: left
    const vector = this.getVector(direction)
    const traversals = this.buildTraversals(vector)
    
    // 遍历网格并移动方块
    traversals.x.forEach(x => {
      traversals.y.forEach(y => {
        if (this.grid[x][y] !== 0) {
          const cell: Position = { x: x, y: y }
          const positions = this.findFarthestPosition(cell, vector)
          let next = 0
          if (this.withinBounds(positions.next)) {
            next = this.grid[positions.next.x][positions.next.y]
          }
          
          if (next !== 0 && next === this.grid[x][y]) {
            // 合并方块
            this.grid[positions.next.x][positions.next.y] *= 2
            this.grid[x][y] = 0
            this.score += this.grid[positions.next.x][positions.next.y]
            
            if (this.grid[positions.next.x][positions.next.y] === 2048 && !this.gameWon) {
              this.gameWon = true
            }
            
            moved = true
          } else if (positions.farthest.x !== x || positions.farthest.y !== y) {
            // 移动方块
            this.grid[positions.farthest.x][positions.farthest.y] = this.grid[x][y]
            this.grid[x][y] = 0
            moved = true
          }
        }
      })
    })
    
    if (moved) {
      this.addRandomTile()
      
      // 创建新的数组引用，触发UI更新
      this.grid = JSON.parse(JSON.stringify(this.grid))
      
      if (!this.movesAvailable()) {
        this.gameOver = true
      }
      
      // 更新最高分
      if (this.score > this.bestScore) {
        this.bestScore = this.score
      }
    }
  }

  getVector(direction: number): Position {
    // 使用数组而不是对象来避免数字作为属性名的问题
    const vectors: Position[] = [
      { x: 0, y: -1 }, // Up
      { x: 0, y: 1 },  // Down
      { x: -1, y: 0 },  // Left
      { x: 1, y: 0 }   // Right
    ]
    return vectors[direction]
  }

  buildTraversals(vector: Position): Traversals {
    const traversals: Traversals = { x: [], y: [] }
    
    for (let pos = 0; pos < this.gridSize; pos++) {
      traversals.x.push(pos)
      traversals.y.push(pos)
    }
    
    // 从最远的单元格开始遍历
    if (vector.x === 1) traversals.x.reverse()
    if (vector.y === 1) traversals.y.reverse()
    
    return traversals
  }

  findFarthestPosition(cell: Position, vector: Position): PositionResult {
    let previous: Position = { x: cell.x, y: cell.y }
    let current: Position = { x: cell.x, y: cell.y }
    
    do {
      previous = { x: current.x, y: current.y }
      current = { x: previous.x + vector.x, y: previous.y + vector.y }
    } while (this.withinBounds(current) && this.grid[current.x][current.y] === 0)
    
    return {
      farthest: previous,
      next: current
    }
  }

  withinBounds(position: Position): boolean {
    return position.x >= 0 && position.x < this.gridSize &&
           position.y >= 0 && position.y < this.gridSize
  }

  movesAvailable(): boolean {
    return this.cellsAvailable() || this.tileMatchesAvailable()
  }

  cellsAvailable(): boolean {
    for (let x = 0; x < this.gridSize; x++) {
      for (let y = 0; y < this.gridSize; y++) {
        if (this.grid[x][y] === 0) {
          return true
        }
      }
    }
    return false
  }

  tileMatchesAvailable(): boolean {
    for (let x = 0; x < this.gridSize; x++) {
      for (let y = 0; y < this.gridSize; y++) {
        const tile = this.grid[x][y]
        if (tile) {
          for (let direction = 0; direction < 4; direction++) {
            const vector = this.getVector(direction)
            const cell: Position = { x: x + vector.x, y: y + vector.y }
            
            if (this.withinBounds(cell) && this.grid[cell.x][cell.y] === tile) {
              return true
            }
          }
        }
      }
    }
    return false
  }

  restartGame() {
    this.setupGame()
  }

  keepPlayingGame() {
    this.keepPlaying = true
  }

  build() {
    Column() {
      WechatToolbar({ title: "2048" })
      
      // 得分区域
      Row() {
        Column() {
          Text("分数")
            .fontSize(14)
            .fontColor("#776e65")
          Text(this.score.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
        }
        .margin({ right: 20 })
        
        Column() {
          Text("最高分")
            .fontSize(14)
            .fontColor("#776e65")
          Text(this.bestScore.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
        }
        
        Blank()
        
        Button("重新开始")
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor("#8f7a66")
          .borderRadius(3)
          .onClick(() => this.restartGame())
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      
      // 游戏网格
      Grid() {
        ForEach(this.grid, (row: number[], rowIndex: number) => {
          ForEach(row, (cell: number, colIndex: number) => {
            GridItem() {
              if (cell !== 0) {
                Text(cell.toString())
                  .fontSize(this.getFontSize(cell))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getTextColor(cell))
                  .width("100%")
                  .height("100%")
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.getTileColor(cell))
                  .borderRadius(3)
              } else {
                Text("")
                  .width("100%")
                  .height("100%")
                  .backgroundColor("#cdc1b4")
                  .borderRadius(3)
              }
            }
          })
        })
      }
      .columnsTemplate("1fr 1fr 1fr 1fr")
      .rowsTemplate("1fr 1fr 1fr 1fr")
      .columnsGap(10)
      .rowsGap(10)
      .width("90%")
      .height("60%")
      .backgroundColor("#bbada0")
      .padding(10)
      .borderRadius(6)
      
      // 方向按键
      Row() {
        Button("↑")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor("#8f7a66")
          .borderRadius(3)
          .width(60)
          .height(60)
          .onClick(() => this.move(2)) // 上对应左
          .margin({ right: 10 })
        Button("↓")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor("#8f7a66ff")
          .borderRadius(3)
          .width(60)
          .height(60)
          .onClick(() => this.move(3)) // 下对应右
          .margin({ right: 10 })
        Button("←")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor("#8f7a66")
          .borderRadius(3)
          .width(60)
          .height(60)
          .onClick(() => this.move(0)) // 左对应上
          .margin({ right: 10 })
        Button("→")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor("#8f7a66")
          .borderRadius(3)
          .width(60)
          .height(60)
          .onClick(() => this.move(1)) // 右对应下
      }
      .margin({ top: 20 })
      
      // 游戏提示
      Text("合并相同数字，获得2048！")
        .fontSize(14)
        .fontColor("#776e65")
        .margin({ top: 20 })
      
      // 游戏结束提示
      if (this.gameOver) {
        Text("游戏结束！")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor("#776e65")
          .margin({ top: 10 })
        Button("再试一次")
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor("#8f7a66")
          .borderRadius(3)
          .margin({ top: 10 })
          .onClick(() => this.restartGame())
      }
      
      // 游戏胜利提示
      if (this.gameWon && !this.keepPlaying) {
        Text("你赢了！")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor("#776e65")
          .margin({ top: 10 })
        Row() {
          Button("继续游戏")
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor("#8f7a66")
            .borderRadius(3)
            .margin({ right: 10 })
            .onClick(() => this.keepPlayingGame())
          Button("再试一次")
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor("#8f7a66")
            .borderRadius(3)
            .onClick(() => this.restartGame())
        }
        .margin({ top: 10 })
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#faf8ef")
  }

  getTileColor(value: number): string {
    const colors: Record<number, string> = {
      2: "#eee4da",
      4: "#ede0c8",
      8: "#f2b179",
      16: "#f59563",
      32: "#f67c5f",
      64: "#f65e3b",
      128: "#edcf72",
      256: "#edcc61",
      512: "#edc850",
      1024: "#edc53f",
      2048: "#edc22e"
    }
    return colors[value] || "#3c3a32"
  }

  getTextColor(value: number): string {
    return value <= 4 ? "#776e65" : "#f9f6f2"
  }

  getFontSize(value: number): number {
    if (value < 100) return 32
    if (value < 1000) return 28
    return 24
  }
}
