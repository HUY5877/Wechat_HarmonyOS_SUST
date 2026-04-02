import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import ContactApi, { FriendDetail } from '../../utils/ContactApi';
import { getAvatarResource } from '../../utils/AvatarUtils';

interface SearchResult {
  friend_id: string;
  name: string;
  profile_picture_id: string;
}

@Entry
@Component
export default struct ContactSearchPage {
  @State private searchText: string = ''
  @State private searchResults: SearchResult[] = []
  @State private isSearching: boolean = false
  @StorageProp('userId') userId: string = '未登录'

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r("app.media.ic_back_black"))
          .width(22)
          .height(22)
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })
        Text("搜索")
          .fontSize(18)
          .fontColor(Color.Black)
      }
      .width("100%")
      .height(53)
      .alignItems(VerticalAlign.Center)

      // 搜索输入区域
      Row() {
        Column() {
          TextInput({ placeholder: "搜索", text: this.searchText })
            .width("100%")
            .height(40)
            .fontSize(17)
            .backgroundColor("#f0f0f0")
            .padding({ left: 16, right: 16 })
            .borderRadius(20)
            .onChange((value: string) => {
              this.searchText = value
            })
        }
        .width("80%")
        .margin({ left: 16 })
        Text("搜索")
          .fontSize(16)
          .fontColor("#57be6a")
          .margin({ right: 16 })
          .onClick(() => {
            this.searchContacts()
          })
      }
      .width("100%")
      .height(60)
      .alignItems(VerticalAlign.Center)

      // 搜索结果区域
      if (this.isSearching) {
        Column() {
          Text("搜索中...")
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .width("100%")
        .padding({ top: 20 })
      } else if (this.searchText.length > 0 && this.searchResults.length > 0) {
        Column() {
          ForEach(this.searchResults, (item: SearchResult) => {
            Row() {
              Image(getAvatarResource(item.profile_picture_id))
                .width(40)
                .height(40)
                .borderRadius(4)
                .margin({ right: 12 })
              Text(item.name)
                .fontSize(17)
                .fontColor(Color.Black)
              Blank()
            }
            .width("100%")
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Color.White)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/chat/ChatPage',
                params: { name: item.name }
              })
            })
          })
        }
        .width("100%")
        .backgroundColor("#f0f0f0")
      } else if (this.searchText.length > 0) {
        Column() {
          Text("未找到联系人")
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .width("100%")
        .padding({ top: 20 })
      }

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")
    .padding({ top: WindowManager.statusBarHeight })
  }

  async searchContacts() {
    if (this.userId === '未登录') {
      console.log('请先登录')
      return
    }

    if (this.searchText.trim() === '') {
      this.searchResults = []
      return
    }

    this.isSearching = true

    try {
      const result = await ContactApi.searchContacts(this.userId, this.searchText)
      
      // 获取每个好友的详细信息，包括头像ID
      const searchResultsWithDetails: SearchResult[] = []
      for (const contact of result) {
        const detail = await ContactApi.getFriendDetail(contact.friend_id)
        if (detail) {
          searchResultsWithDetails.push({
            friend_id: detail.friend_id,
            name: detail.name,
            profile_picture_id: detail.profile_picture_id || '0'
          })
        }
      }
      
      this.searchResults = searchResultsWithDetails
    } catch (error) {
      console.log('搜索失败')
    }

    this.isSearching = false
  }
}