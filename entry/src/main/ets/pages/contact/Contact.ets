import prompt from '@ohos.promptAction'
import router from '@ohos.router'
import ListContactItem from '../../component/ListContactItem'
import WechatToolbar from '../../component/WechatToolbar'
import ContactApi from '../../utils/ContactApi'
import { FriendInfo } from '../../utils/ContactApi'
import DataItem, { ContactItem } from './DataItem'

@Preview
@Component
export default struct Contact {
  private scroller: Scroller = new Scroller()
  private currentUserId: string = "1"

  @State private dataList: DataItem[] = []
  @State private isLoading: boolean = true

  private letterList: string[] =
    ['↑', '☆', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
      'V', 'W', 'X', 'Y', 'Z', '#']

  async aboutToAppear() {
    await this.loadContacts()
  }

  async loadContacts() {
    this.isLoading = true
    try {
      const friends = await ContactApi.getContacts(this.currentUserId)
      const groupedData = this.groupContactsByLetter(friends)
      this.dataList = groupedData
    } catch (error) {
      prompt.showToast({ message: '加载通讯录失败' })
      this.dataList = []
    }
    this.isLoading = false
  }
  groupContactsByLetter(friends: FriendInfo[]): DataItem[] {
    const grouped: Record<string, ContactItem[]> = {}

    const headImages = [
      $r("app.media.ic_user_head1"),
      $r("app.media.ic_user_head2"),
      $r("app.media.ic_user_head3"),
      $r("app.media.ic_user_head4"),
      $r("app.media.ic_user_head5"),
      $r("app.media.ic_user_head6"),
      $r("app.media.ic_user_head7")
    ]
    friends.forEach((friend: FriendInfo, index: number) => {
      const firstLetter = friend.name.charAt(0).toUpperCase()
      if (!grouped[firstLetter]) {
        grouped[firstLetter] = []
      }
      grouped[firstLetter].push({
        name: friend.name,
        head: headImages[index % headImages.length]
      })
    })

    const result: DataItem[] = []
    Object.keys(grouped).sort().forEach(letter => {
      result.push({
        title: letter,
        contactList: grouped[letter]
      })
    })

    return result
  }

  @Builder
  itemHead(title: string) {
    Text(title)
      .fontSize(14)
      .visibility("" === title ? Visibility.None : Visibility.Visible)
      .backgroundColor("#EDEDED")
      .height(36)
      .width("100%")
      .padding({ left: 20 })
  }

  build() {
    Stack({ alignContent: Alignment.End }) {

      Column() {
        WechatToolbar({
          title: "通讯录",
          onSearchClick: () => {
            router.pushUrl({ url: 'pages/contact/ContactSearchPage' })
          },
          onAddClick: () => {
            router.pushUrl({ url: 'pages/contact/AddFriendPage' })
          }
        })

        if (this.isLoading) {
          Column() {
            Text("加载中...")
              .fontSize(16)
              .fontColor(Color.Gray)
          }
          .width("100%")
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ scroller: this.scroller }) {
            ForEach(this.dataList, (item: DataItem) => {
              ListItemGroup({ header: this.itemHead(item.title) }) {
                ForEach(item.contactList, (contact: ContactItem) => {
                  ListItem() {
                    ListContactItem({ head: contact.head, name: contact.name })
                  }
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/chat/ChatPage',
                      params: { name: contact.name }
                    })
                  })
                })
              }
              .divider({
                strokeWidth: 0.8,
                color: '#f0f0f0',
                startMargin: 85,
                endMargin: 0
              })
            })
          }
          .width('100%')
          .height(0)
          .layoutWeight(1)
          .backgroundColor(Color.White)
        }
      }
      .width("100%")
      .height("100%")

      AlphabetIndexer({ arrayValue: this.letterList, selected: 0 })
        .color(Color.Black)
        .font({ size: 14 })
        .selectedFont({ size: 14 })
        .selectedColor(Color.Black)
        .selectedBackgroundColor(Color.Transparent)
        .usingPopup(true)
        .popupColor(Color.Red)
        .popupBackground("#57be6a")
        .popupFont({ size: 32, weight: FontWeight.Bolder })
        .itemSize(20)
        .alignStyle(IndexerAlign.Right)
        .margin({ top: 80 })
        .onSelect((index: number) => {
          let letter = this.letterList[index]
          let target: number = 0
          for (const item of this.dataList) {
            if (letter === item.title) {
              this.scroller.scrollToIndex(target)
              prompt.showToast({ message: "" + target })
              break
            }
            target++
          }
        })

    }.width("100%")
    .height("100%")

  }
}
