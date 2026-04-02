import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import { Toast } from '../../utils/Toast';
import { queryChange, queryChangePass } from '../../utils/WalletApi';

@Component
struct WalletListItem {
  @Prop iconSrc: Resource | string = '';
  @Prop title: string = '';
  @Prop subtitle?: string = '';
  @Prop rightText?: string = '';
  onClickHandler?: () => void;

  build() {
    Row() {
      Image(this.iconSrc)
        .width(24)
        .height(24)
        .margin({ right: 16 })
      
      Text(this.title)
        .fontSize(16)
        .fontColor(Color.Black)
      
      if (this.subtitle) {
        Text(this.subtitle)
          .fontSize(12)
          .fontColor('#E6A23C')
          .margin({ left: 8 })
      }
      
      Blank()
      
      if (this.rightText) {
        Text(this.rightText)
          .fontSize(16)
          .fontColor(Color.Grey)
          .margin({ right: 8 })
      }
      
      Image($r('app.media.ic_more'))
        .width(8)
        .height(14)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .onClick(() => {
      if (this.onClickHandler) {
        this.onClickHandler()
      } else {
        Toast.show('该功能暂未开发')
      }
    })
  }
}

@Entry
@Component
export default struct WalletPage {
  @StorageProp('userId') userId: string = '未登录'
  @State balance: number = 0.00
  @State balancePass: number = 0.00

  aboutToAppear() {
    this.fetchData()
  }

  onPageShow() {
    this.fetchData()
  }

  async fetchData() {
    if (this.userId === '未登录') return
    this.balance = await queryChange(this.userId)
    this.balancePass = await queryChangePass(this.userId)
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.pushUrl({ url: 'pages/mine/ServicePage' })
          })
        
        Text('钱包')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('账单')
          .fontSize(16)
          .fontColor(Color.Black)
          .onClick(() => {
            Toast.show('该功能暂未开发')
          })
      }
      .width('100%')
      .height(50 + WindowManager.statusBarHeight)
      .padding({ left: 16, right: 16, top: WindowManager.statusBarHeight })
      .backgroundColor('#EDEDED')

      Scroll() {
        Column() {
          // 第一组
          Column() {
            WalletListItem({ 
              iconSrc: $r('app.media.ic_collect'), 
              title: '零钱', 
              rightText: `¥${this.balance.toFixed(2)}`,
              onClickHandler: () => {
                router.pushUrl({ url: 'pages/mine/BalancePage' })
              }
            })
            Divider().color('#F5F5F5').strokeWidth(1).margin({ left: 56 })
            WalletListItem({ 
              iconSrc: $r('app.media.ic_moment_pic'), 
              title: '零钱通', 
              subtitle: '收益率1.07%', 
              rightText: `¥${this.balancePass.toFixed(2)}`,
              onClickHandler: () => {
                router.pushUrl({ url: 'pages/mine/LingqiantongPage' })
              }
            })
            Divider().color('#F5F5F5').strokeWidth(1).margin({ left: 56 })
            WalletListItem({ 
              iconSrc: $r('app.media.ic_card_pkg'), 
              title: '银行卡',
              onClickHandler: () => {
                router.pushUrl({ url: 'pages/mine/BankCardPage' })
              }
            })
            Divider().color('#F5F5F5').strokeWidth(1).margin({ left: 56 })
            WalletListItem({ iconSrc: $r('app.media.ic_group_chat'), title: '亲属卡' })
          }
          .backgroundColor(Color.White)
          .margin({ top: 8, bottom: 8 })

          // 第二组
          Column() {
            WalletListItem({ iconSrc: $r('app.media.ic_red_pkg'), title: '数字人民币' })
          }
          .backgroundColor(Color.White)
          .margin({ bottom: 8 })

          // 第三组
          Column() {
            WalletListItem({ iconSrc: $r('app.media.ic_scan'), title: '支付分' })
            Divider().color('#F5F5F5').strokeWidth(1).margin({ left: 56 })
            WalletListItem({ iconSrc: $r('app.media.ic_service'), title: '客服中心' })
          }
          .backgroundColor(Color.White)
          .margin({ bottom: 8 })
          
          Blank()

          // 底部链接
          Row() {
            Text('身份信息')
              .fontSize(12)
              .fontColor('#576B95')
              .onClick(() => { Toast.show('该功能暂未开发') })
            Text(' | ')
              .fontSize(12)
              .fontColor('#D9D9D9')
              .margin({ left: 8, right: 8 })
            Text('支付设置')
              .fontSize(12)
              .fontColor('#576B95')
              .onClick(() => { Toast.show('该功能暂未开发') })
          }
          .margin({ top: 40, bottom: 30 })
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }
        .constraintSize({ minHeight: '100%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EDEDED')
  }
}
