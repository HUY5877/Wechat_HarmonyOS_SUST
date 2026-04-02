
import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import ContactApi from '../../utils/ContactApi';
import promptAction from '@ohos.promptAction';

interface SearchResult {
  friend_id: string;
  account: string;
  name: string;
  status: string;
  profile_picture_id: string;
}

@Entry
@Component
export default struct AddFriendPage {
  @State private searchText: string = ''
  @State private searchResults: SearchResult[] = []
  @State private isSearching: boolean = false
  private currentUserId: string = "1"

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
        Text("添加朋友")
          .fontSize(18)
          .fontColor(Color.Black)
          .margin({ left: 20 })
      }
      .width("100%")
      .height(53)

      Column() {
        Row() {
          TextInput({ placeholder: "微信号/手机号", text: this.searchText })
            .layoutWeight(1)
            .height(50)
            .fontSize(17)
            .backgroundColor(Color.White)
            .padding({ left: 16, right: 16 })
            .borderRadius(0)
            .onChange((value: string) => {
              this.searchText = value
            })

          Text("搜索")
            .fontSize(16)
            .fontColor("#57be6a")
            .margin({ left: 12, right: 16 })
            .onClick(() => {
              this.searchByAccount()
            })
        }
        .width("100%")
        .backgroundColor(Color.White)

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
                Column() {
                  Text(item.name)
                    .fontSize(17)
                    .fontColor(Color.Black)
                  Text("微信号: " + item.account)
                    .fontSize(14)
                    .fontColor(Color.Gray)
                }
                .alignItems(HorizontalAlign.Start)
                Blank()
                Text("添加到通讯录")
                  .fontSize(14)
                  .fontColor("#57be6a")
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(4)
                  .border({ width: 1, color: "#57be6a" })
                  .onClick(() => {
                    this.addFriend(item.account)
                  })
              }
              .width("100%")
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor(Color.White)
            })
          }
          .width("100%")
          .backgroundColor("#f0f0f0")
        } else if (this.searchText.length > 0) {
          Column() {
            Text("未找到用户")
              .fontSize(16)
              .fontColor(Color.Gray)
          }
          .width("100%")
          .padding({ top: 20 })
        }
      }
      .margin({ top: 20 })

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")
    .padding({ top: WindowManager.statusBarHeight })
  }

  async searchByAccount() {
    if (this.searchText.trim() === '') {
      console.log('请输入微信号或手机号')
      return
    }

    this.isSearching = true
    this.searchResults = []

    try {
      // 使用 searchContacts 搜索用户
      const results = await ContactApi.searchContacts(this.currentUserId, this.searchText)
      if (results && results.length > 0) {
        // 获取每个搜索结果的详细信息
        for (const friend of results) {
          const detail = await ContactApi.getFriendDetail(friend.friend_id)
          if (detail) {
            this.searchResults.push({
              friend_id: detail.friend_id,
              account: detail.account,
              name: detail.name,
              status: detail.status,
              profile_picture_id: detail.profile_picture_id
            })
          }
        }
      } else {
        console.log('未找到该用户')
      }
    } catch (error) {
      console.log('搜索失败:', error)
    }

    this.isSearching = false
  }

  async addFriend(account: string) {
    AlertDialog.show({
      title: '添加朋友',
      message: `确定要添加 ${account} 为朋友吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消添加')
        }
      },
      secondaryButton: {
        value: '确定',
        fontColor: '#57be6a',
        action: async () => {
          try {
            const result = await ContactApi.addFriend(this.currentUserId, account)
            if (result.result === 'success') {
              // 添加成功，显示提示
              promptAction.showToast({
                message: '添加成功',
                duration: 2000
              })
              // 返回到主页 Index，并选中通讯录 Tab (index=1)
              router.replaceUrl({ 
                url: 'pages/Index',
                params: { tabIndex: 1 }
              })
            } else if (result.text && result.text.includes('已拥有好友')) {
              // 已经是好友
              promptAction.showToast({
                message: '该用户已经是您的好友',
                duration: 2000
              })
              // 返回到主页 Index，并选中通讯录 Tab (index=1)
              router.replaceUrl({ 
                url: 'pages/Index',
                params: { tabIndex: 1 }
              })
            } else {
              promptAction.showToast({
                message: result.text || '添加失败',
                duration: 2000
              })
            }
          } catch (error) {
            promptAction.showToast({
              message: '网络错误，添加失败',
              duration: 2000
            })
          }
        }
      }
    })
  }
}
