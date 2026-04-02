
import router from '@ohos.router'
import ListMenuItem from '../../component/ListMenuItem'

@Entry
@Preview
@Component
export default struct GamePage {
  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .margin({ left: 15, right: 15 })
          .onClick(() => {
            router.back()
          })
        Text('游戏')
          .fontSize(17)
          .fontWeight(500)
          .fontColor('#000000')
        Blank()
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .margin({ right: 15 })
        Image($r('app.media.ic_user_head1'))
          .width(20)
          .height(20)
          .margin({ right: 15 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#ffffff')

      // 导航标签
      Row() {
        Text('朋友')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 15, right: 20 })
        Text('圈子')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 20 })
        Text('找游戏')
          .fontSize(14)
          .fontColor('#07C160')
          .margin({ right: 20 })
          .decoration({ type: TextDecorationType.Underline, color: '#07C160' })
          .padding({ bottom: 8 })
        Blank()
      }
      .width('100%')
      .height(40)
      .backgroundColor('#ffffff')

      // 分类标签
      Row() {
        Text('在玩')
          .fontSize(14)
          .fontColor('#333333')
          .margin({ left: 15, right: 15 })
        Text('分类')
          .fontSize(14)
          .fontColor('#333333')
          .margin({ right: 15 })
        Text('小游戏')
          .fontSize(14)
          .fontColor('#333333')
          .margin({ right: 15 })
        Text('排行榜')
          .fontSize(14)
          .fontColor('#333333')
          .margin({ right: 15 })
        Text('福利')
          .fontSize(14)
          .fontColor('#333333')
          .margin({ right: 15 })
        Text('新')
          .fontSize(14)
          .fontColor('#333333')
        Blank()
      }
      .width('100%')
      .height(40)
      .backgroundColor('#ffffff')

      // 可滚动内容
      Scroll() {
        Column() {
          // 碎片时间，玩出大智慧
          Row() {
            Text('碎片时间，玩出大智慧')
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#333333')
              .margin({ left: 15, top: 15, bottom: 10 })
            Blank()
            Text('>')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ right: 15, top: 15, bottom: 10 })
          }
          .width('100%')

          // 游戏列表
          Column() {
            // 箭头消除大闯关
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('箭头消除大闯关')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('箭头消除大闯关是一款方块...')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .flexGrow(1)
              Button('立即玩')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)

            // 倒水大闯关
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('倒水大闯关')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('超好玩的倒水杯闯关游戏')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .flexGrow(1)
              Button('立即玩')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)

            // 跳了个蛋
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('跳了个蛋')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('高智商蛋蛋的烧脑冒险')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .flexGrow(1)
              Button('立即玩')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor('#ffffff')

          // 发现新游
          Row() {
            Text('发现新游')
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#333333')
              .margin({ left: 15, top: 15, bottom: 10 })
            Blank()
            Text('>')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ right: 15, top: 15, bottom: 10 })
          }
          .width('100%')

          // 新游列表
          Column() {
            // 洛克王国：世界
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('洛克王国：世界')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('《洛克王国：世界》正式上线！')
                  .fontSize(12)
                  .fontColor('#999999')
                Row() {
                  Text('1000万+')
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .flexGrow(1)
              Button('下载')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)

            // 2048游戏（替换人生模拟系统）
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('2048')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('经典数字拼图游戏，挑战你的智力')
                  .fontSize(12)
                  .fontColor('#999999')
                Row() {
                  Text('100万+')
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .flexGrow(1)
              Button('立即玩')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/game2048/Game2048' })
                })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)

            // 异人之下
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('异人之下')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('魔方工作室群3D格斗竞技新游')
                  .fontSize(12)
                  .fontColor('#999999')
                Row() {
                  Text('300万+')
                    .fontSize(12)
                    .fontColor('#999999')
                }
              }
              .flexGrow(1)
              Button('预约')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor('#ffffff')

          // 治愈系游戏，温暖你的心
          Row() {
            Text('治愈系游戏，温暖你的心')
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#333333')
              .margin({ left: 15, top: 15, bottom: 10 })
            Blank()
            Text('>')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ right: 15, top: 15, bottom: 10 })
          }
          .width('100%')

          // 治愈系游戏列表
          Column() {
            // 开店很难吗
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('开店很难吗')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('开店真的很难，不信你来试试')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .flexGrow(1)
              Button('立即玩')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)

            // 毛线解压馆
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('毛线解压馆')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('最好玩的毛线消除！')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .flexGrow(1)
              Button('立即玩')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)

            // 根本关不住我
            Row() {
              Image($r('app.media.ic_game'))
                .width(60)
                .height(60)
                .margin({ left: 15, right: 10 })
              Column() {
                Text('根本关不住我')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ bottom: 5 })
                Text('挑战你的反应速度')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .flexGrow(1)
              Button('立即玩')
                .width(80)
                .height(30)
                .fontSize(14)
                .fontColor('#07C160')
                .backgroundColor('#F0FFF4')
                .borderRadius(15)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Blank()
          Blank()
          Blank()
        }
        .width('100%')
      }
      .width('100%')
      .flexGrow(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}
