@Preview
@Component
export struct MessageActionSheet {
  @Prop showDelete: boolean = true
  onCopy: () => void = () => {}
  onDelete: () => void = () => {}
  onForward: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    Column() {
      Row() {
        if (this.showDelete) {
          Button('删除')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#ffffff')
            .borderRadius(8)
            .height(40)
            .layoutWeight(1)
            .onClick(() => {
              this.onDelete()
            })
        }

        Button('复制')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onCopy()
          })

        Button('转发')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onForward()
          })

        Button('取消')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onCancel()
          })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor('#ffffff')
      .borderRadius(8)
    }
    .width('100%')
    .backgroundColor('#80000000')
    .justifyContent(FlexAlign.End)
    .padding({ bottom: 8 })
  }
}