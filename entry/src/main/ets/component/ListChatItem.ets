@Preview
@Component
export default struct ListChatItem {
  data: ChatItemData = { headSrc: $r("app.media.ic_user_head1"),
    nickname: "同事小李"
  }

  build() {
    Row() {
      Image(this.data.headSrc)
        .width(60)
        .height(60)
        .margin({ right: 15 })
        .objectFit(ImageFit.Cover)
        .borderRadius(6)
        .borderWidth(2)
        .borderColor("#f0f0f0")

      Text(this.data.nickname)
        .fontColor(Color.Black)
        .fontSize(19)
        .fontWeight(500)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      Blank()
    }
    .width("100%")
    .height(80)
    .backgroundColor(Color.White)
    .padding({ left: 15, right: 15 })
  }
}

export interface ChatItemData {
  headSrc?: Resource
  nickname?: string
  content?: string
  time?: string
  friend_id?: string
}