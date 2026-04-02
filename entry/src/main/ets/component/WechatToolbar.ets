import router from '@ohos.router'
import prompt from '@ohos.promptAction'
import WindowManager from '../utils/WindowManager'

@Preview
@Component
export default struct WechatToolbar {
  title: string = "发现"
  onSearchClick?: () => void
  onAddClick?: () => void

  build() {
    Column() {
      Stack() {
        Text(this.title)
          .fontColor(Color.Black)
          .fontSize(19)
          .fontWeight(500)

        Row() {
          Column() {
            Image($r("app.media.ic_search"))
              .width(22)
              .height(22)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ right: 10 })
          .onClick(() => {
            console.log('搜索按钮被点击');
            if (this.onSearchClick) {
              this.onSearchClick()
            } else {
              router.pushUrl({ url: 'pages/search/SearchPage' })
            }
          })
          Column() {
            Image($r('app.media.ic_add'))
              .width(25)
              .height(25)
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .margin({ right: 10 })
          .onClick(() => {
            console.log('添加按钮被点击');
            if (this.onAddClick) {
              this.onAddClick()
            } else {
              prompt.showToast({ message: "功能正在开发中...", duration: 2000 })
              router.pushUrl({ url: 'pages/HardwareIndexPage' })
            }
          })
        }
        .height("100%")
        .width("100%")
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)

      }
      .width("100%")
      .height(53)
    }.backgroundColor("#f0f0f0")
    .padding({ top: WindowManager.statusBarHeight })
  }
}