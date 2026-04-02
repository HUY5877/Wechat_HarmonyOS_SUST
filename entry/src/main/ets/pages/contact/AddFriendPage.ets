import router from '@ohos.router';
import prompt from '@ohos.promptAction';
import WindowManager from '../../utils/WindowManager';
import ContactApi from '../../utils/ContactApi';
import { getAvatarResource } from '../../utils/AvatarUtils';

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
            .width("80%")
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
            .margin({ right: 16 })
            .onClick(() => {
              this.searchByAccount()
            })
        }
        .width("100%")
        .height(50)
        .alignItems(VerticalAlign.Center)
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
                Image(getAvatarResource(item.profile_picture_id || '0'))
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
                Column() {
                  Text("添加到通讯录")
                    .fontSize(14)
                    .fontColor("#57be6a")
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .borderRadius(4)
                    .border({ width: 1, color: "#57be6a" })
                }
                .width(100)
                .height(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onClick(() => {
                  console.log('点击了添加到通讯录按钮，account:', item.account)
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
    if (this.userId === '未登录') {
      console.log('请先登录')
      return
    }

    if (this.searchText.trim() === '') {
      console.log('请输入微信号或手机号')
      return
    }

    this.isSearching = true
    this.searchResults = []

    try {
      const result = await ContactApi.addFriend(this.userId, this.searchText)
      if (result.result === 'success') {
        this.searchResults = [{
          friend_id: '',
          account: this.searchText,
          name: this.searchText,
          status: '',
          profile_picture_id: ''
        }]
      } else {
        console.log(result.text || '未找到该用户')
      }
    } catch (error) {
      console.log('搜索失败')
    }

    this.isSearching = false
  }

  async addFriend(account: string) {
    console.log('开始执行addFriend方法，account:', account, 'userId:', this.userId)
    
    if (this.userId === '未登录') {
      console.log('请先登录')
      return
    }

    try {
      console.log('调用ContactApi.addFriend，userId:', this.userId, 'account:', account)
      const result = await ContactApi.addFriend(this.userId, account)
      console.log('ContactApi.addFriend返回结果:', JSON.stringify(result))
      
      if (result.result === 'success') {
        console.log('已发送好友请求')
        // 显示添加成功的弹窗
        prompt.showToast({
          message: '已发送好友请求',
          duration: 2000
        })
        
        this.searchText = ''
        this.searchResults = []
        
        // 延迟返回，让用户看到弹窗
        setTimeout(() => {
          console.log('准备返回上一页')
          router.back()
        }, 1500)
      } else {
        console.log('添加失败，原因:', result.text || '未知错误')
        // 显示添加失败的弹窗
        prompt.showToast({
          message: result.text || '添加失败',
          duration: 2000
        })
      }
    } catch (error) {
      console.error('添加失败，错误:', error)
      // 显示添加失败的弹窗
      prompt.showToast({
        message: '添加失败',
        duration: 2000
      })
    }
  }
}