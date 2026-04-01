import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import ContactApi from '../../utils/ContactApi';

interface SearchResult {
  friend_id: string;
  name: string;
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
      Row() {
        Image($r("app.media.ic_back_black"))
          .width(22)
          .height(22)
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })
        TextInput({ placeholder: "搜索", text: this.searchText })
          .width("100%")
          .height(40)
          .fontSize(17)
          .backgroundColor("#f0f0f0")
          .padding({ left: 16, right: 16 })
          .borderRadius(20)
          .margin({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.searchText = value
            if (value.length > 0) {
              this.searchContacts()
            } else {
              this.searchResults = []
            }
          })
      }
      .width("100%")
      .height(53)

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
              Image($r("app.media.ic_user_head2"))
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
      this.searchResults = result
    } catch (error) {
      console.log('搜索失败')
    }

    this.isSearching = false
  }
}