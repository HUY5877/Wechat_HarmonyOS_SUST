import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import { Toast } from '../../utils/Toast';
import { queryChange } from '../../utils/WalletApi';

@Component
struct ServiceSectionItem {
  iconSrc: Resource | string = '';
  title: string = '';

  build() {
    Column() {
      Image(this.iconSrc)
        .width(28)
        .height(28)
        .margin({ bottom: 8 })
      Text(this.title)
        .fontSize(13)
        .fontColor('#333333')
    }
    .width('25%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 16, bottom: 20 })
    .onClick(() => {
      Toast.show('该功能暂未开发')
    })
  }
}

@Entry
@Component
export default struct ServicePage {
  @StorageProp('userId') userId: string = '未登录'
  @State balance: number = 0.00

  aboutToAppear() {
    this.fetchBalance()
  }

  onPageShow() {
    this.fetchBalance()
  }

  async fetchBalance() {
    if (this.userId === '未登录') return
    this.balance = await queryChange(this.userId)
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .onClick(() => {
            // 如果是在主 tab 里的页面，pushUrl 到主页面可能需要特别处理，或者使用 router.back()
            router.back()
          })
        
        Text('服务')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 24 }) // 抵消左侧返回键宽度以居中
      }
      .width('100%')
      .height(50 + WindowManager.statusBarHeight)
      .padding({ left: 16, right: 16, top: WindowManager.statusBarHeight })
      .backgroundColor('#EDEDED')

      // 可滚动内容区域
      Scroll() {
        Column() {
          // 顶部绿色卡片
          Row() {
            // 收付款
            Column() {
              Image($r('app.media.ic_scan'))
                .width(36)
                .height(36)
                .margin({ bottom: 12 })
              Text('收付款')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              router.pushUrl({ url: 'pages/mine/PaymentPage' })
            })
            
            Column() {
              Image($r('app.media.ic_card_pkg'))
                .width(36)
                .height(36)
                .margin({ bottom: 12 })
              Text('钱包')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
              Text(`¥${this.balance.toFixed(2)}`)
                .fontSize(12)
                .fontColor(Color.White)
                .margin({ top: 4 })
                .opacity(0.8)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              router.pushUrl({ url: 'pages/mine/WalletPage' })
            })
          }
          .width('100%')
          .padding({ top: 25, bottom: 25 }) // 减小绿色卡片的上下内边距
          .backgroundColor('#27A959')
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 金融理财
          Column() {
            Text('金融理财')
              .fontSize(13)
              .fontColor('#999')
              .width('100%')
              .padding({ left: 16, top: 16, bottom: 4 })

            Row() {
              ServiceSectionItem({ iconSrc: $r('app.media.ic_card_pkg'), title: '信用卡还款' })
              ServiceSectionItem({ iconSrc: $r('app.media.ic_red_pkg'), title: '理财通' })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 生活服务
          Column() {
            Text('生活服务')
              .fontSize(13)
              .fontColor('#999')
              .width('100%')
              .padding({ left: 16, top: 16, bottom: 4 })

            Row() {
              ServiceSectionItem({ iconSrc: $r('app.media.ic_service'), title: '手机充值' })
              ServiceSectionItem({ iconSrc: $r('app.media.ic_miniprogram'), title: '生活缴费' })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 交通出行
          Column() {
            Text('交通出行')
              .fontSize(13)
              .fontColor('#999')
              .width('100%')
              .padding({ left: 16, top: 16, bottom: 4 })

            Row() {
              ServiceSectionItem({ iconSrc: $r('app.media.ic_location'), title: '出行服务' })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })

        }
        .padding({ left: 12, right: 12, top: 12, bottom: 40 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EDEDED')
  }
}
