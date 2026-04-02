@Preview
@Component
export default struct ListMenuItem {
  iconSrc?: Resource
  title: string = "朋友圈"
  news: string = ""
  newsIconSrc?: Resource
  clickHandler?: () => void

  build() {
    Row() {
      if (this.iconSrc) {
        Image(this.iconSrc)
          .width(25)
          .height(25)
          .margin({ right: 18 })
      }
      Text(this.title)
        .fontColor(Color.Black)
        .fontSize(16)
        .margin({ right: 10 })
      Blank()
      Text(this.news)
        .fontColor(Color.Gray)
        .fontSize(16)
        .margin({ right: 6 })
      Image(this.newsIconSrc)
        .width(this.newsIconSrc === null ? 0 : 35)
        .height(this.newsIconSrc === null ? 0 : 35)
        .margin({ right: 6 })
        .borderRadius(4)
      Image($r("app.media.ic_more"))
        .width(9)
        .height(16.364)
    }
    .width("100%")
    .height(60)
    .backgroundColor("#fff")
    .padding({ left: this.iconSrc ? 15 : 15, right: 15 })
    .onClick(() => {
      if (this.clickHandler) {
        this.clickHandler()
      }
    })
  }
}