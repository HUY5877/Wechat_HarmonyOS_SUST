import router from '@ohos.router'
import WindowManager from '../../utils/WindowManager'

@Entry
@Component
export default struct PaymentPage {
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(22)
          .height(22)
          .margin({ left: 16 })
          .fillColor(Color.White)
          .onClick(() => {
            router.back()
          })

        Text('付款')
          .fontSize(18)
          .fontColor(Color.White)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('关闭')
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ right: 16 })
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .height(53)
      .backgroundColor('#07c160')

      // 白色内容区域
      Column() {
        // 二维码区域
        Column() {
          // 使用图片显示二维码
          Image($r('app.media.Qcode'))
            .width(200)
            .height(200)
            .margin({ top: 40, bottom: 20 })

          // 提示文字
          Row() {
            Text('用于向商家付款时出示使用')
              .fontSize(12)
              .fontColor('#999999')
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 30 })
        }
        .width('100%')
        .padding({ top: 20, bottom: 30 })

        Divider()
          .color('#e0e0e0')
          .strokeWidth(1)
          .margin({ left: 20, right: 20 })

        // 底部提示
        Row() {
          Text('该功能用于向商家付款时出示使用')
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 20, bottom: 20 })
      }
      .width('94%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 20 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#07c160')
    .padding({ top: WindowManager.statusBarHeight })
  }
}
