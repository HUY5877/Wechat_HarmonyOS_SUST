import prompt from '@ohos.promptAction'
import router from '@ohos.router'
import ListContactItem from '../../component/ListContactItem'
import WechatToolbar from '../../component/WechatToolbar'
import ContactApi, { FriendDetail } from '../../utils/ContactApi'
import DataItem, { ContactItem } from './DataItem'

@Preview
@Component
export default struct Contact {
  private scroller: Scroller = new Scroller()
  @StorageProp('userId') currentUserId: string = ''

  @State private dataList: DataItem[] = [
    {
      title: '',
      contactList: [
        { name: "新的朋友", head: $r("app.media.ic_new_friend") },
        { name: "群聊", head: $r("app.media.ic_group_chat") },
        { name: "标签", head: $r("app.media.ic_tag") },
        { name: "公众号", head: $r("app.media.ic_official_account") }
      ]
    }
  ]
  @State private isLoading: boolean = true
  @State private errorMessage: string = ''
  private letterList: string[] =
    ['↑', '☆', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
      'V', 'W', 'X', 'Y', 'Z', '#']

  async aboutToAppear() {
    if (!this.currentUserId) {
      this.currentUserId = "1" // Fallback if no user is specified
    }
    await this.loadContacts()
  }

  async loadContacts() {
    this.isLoading = true
    this.errorMessage = ''
    try {
      console.log('开始加载通讯录，用户ID:', this.currentUserId);
      
      // 1. 获取通讯录列表（返回 friend_id 列表）
      const contacts = await ContactApi.getContacts(this.currentUserId)
      console.log('获取通讯录成功，好友数量:', contacts.length)
      console.log('通讯录原始数据:', JSON.stringify(contacts))
      
      if (contacts.length === 0) {
        this.errorMessage = '暂无好友，请先添加好友'
        this.isLoading = false
        return
      }
      
      // 2. 根据每个 friend_id 查询好友详细信息
      const friendDetails: FriendDetail[] = []
      for (const contact of contacts) {
        console.log('查询好友详情，friend_id:', contact.friend_id);
        const detail = await ContactApi.getFriendDetail(contact.friend_id)
        if (detail) {
          friendDetails.push(detail)
          console.log('好友详情:', JSON.stringify(detail));
        } else {
          console.log('未获取到好友详情，friend_id:', contact.friend_id);
        }
      }
      
      console.log('获取到好友详情数量:', friendDetails.length);
      
      if (friendDetails.length === 0) {
        this.errorMessage = '无法获取好友信息'
        this.isLoading = false
        return
      }
      
      // 3. 按字母分组显示
      const groupedData = this.groupContactsByLetter(friendDetails)
      const topItems = this.dataList.find(item => item.title === '')
      if (topItems) {
        this.dataList = [topItems, ...groupedData]
      } else {
        this.dataList = groupedData
      }
      console.log('分组后的数据:', JSON.stringify(this.dataList));
      
    } catch (error) {
      console.error('加载通讯录失败:', JSON.stringify(error))
      this.errorMessage = '加载通讯录失败: ' + JSON.stringify(error)
      console.log('加载通讯录失败')
    }
    this.isLoading = false
  }

  groupContactsByLetter(friends: FriendDetail[]): DataItem[] {
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
    
    friends.forEach((friend: FriendDetail, index: number) => {
      // 使用好友的 name，如果没有则使用 account
      const friendName = friend.name || friend.account || '未知用户'
      const firstLetter = this.getFirstLetter(friendName)
      
      if (!grouped[firstLetter]) {
        grouped[firstLetter] = []
      }
      grouped[firstLetter].push({
        name: friendName,
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

  getFirstLetter(name: string): string {
    if (!name || name.length === 0) {
      return '#'
    }
    const firstChar = name.charAt(0).toUpperCase()
    // 如果是英文字母，返回字母；否则返回 #
    if (firstChar >= 'A' && firstChar <= 'Z') {
      return firstChar
    }
    // 对于中文字符，简单处理返回首字符
    return firstChar
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
        } else if (this.errorMessage.length > 0) {
          Column() {
            Text(this.errorMessage)
              .fontSize(16)
              .fontColor(Color.Gray)
              .margin({ bottom: 20 })
            Button('重新加载')
              .onClick(() => {
                this.loadContacts()
              })
          }
          .width("100%")
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.dataList.length === 1 && this.dataList[0].title === '') {
          // If only top options are loaded but no contacts
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
          
          Column() {
            Text("暂无好友")
              .fontSize(16)
              .fontColor(Color.Gray)
              .margin({ bottom: 20, top: 40 })
            Button('添加好友')
              .onClick(() => {
                router.pushUrl({ url: 'pages/contact/AddFriendPage' })
              })
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
              console.log('滚动到索引:', target)
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
