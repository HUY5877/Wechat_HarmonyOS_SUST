import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';
import { Toast } from '../../utils/Toast';
import WindowManager from '../../utils/WindowManager';
import { getFriendsList, FriendItem, sendMessage } from '../../utils/LoginApi';

const AVATAR_LIST: Resource[] = [
  $r("app.media.ic_user_head1"),
  $r("app.media.ic_user_head2"),
  $r("app.media.ic_user_head3"),
  $r("app.media.ic_user_head4"),
  $r("app.media.ic_user_head5"),
  $r("app.media.ic_user_head6"),
  $r("app.media.ic_user_head7")
]

interface ForwardParam {
  content: string
}

@Entry
@Component
export default struct ForwardPage {
  private context = getContext(this) as common.UIAbilityContext;
  private controller: TextInputController = new TextInputController()
  private keyboardHeight: number = 0
  private forwardContent: string = ''
  @State private searchText: string = ''
  @State private allFriends: FriendItem[] = []
  @State private filteredFriends: FriendItem[] = []
  @State private isLoading: boolean = true
  @State private showConfirmDialog: boolean = false
  @State private selectedFriend: FriendItem | null = null
  @State private isSending: boolean = false
  @StorageProp('userId') userId: string = ''

  async aboutToAppear() {
    const params = router.getParams() as ForwardParam
    if (params && params.content) {
      this.forwardContent = params.content
    }

    await window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (height) => {
        this.keyboardHeight = height;
      })
    })

    await this.loadFriends()
  }

  onBackPress() {
    return this.keyboardHeight > 0
  }

  async loadFriends() {
    if (!this.userId) {
      Toast.show('用户未登录')
      this.isLoading = false
      return
    }

    try {
      const result = await getFriendsList(this.userId)
      if (result.success && result.friends) {
        this.allFriends = result.friends
        this.filteredFriends = result.friends
      }
    } catch (err) {
      console.error(`[ForwardPage] 加载好友异常: ${JSON.stringify(err)}`)
    } finally {
      this.isLoading = false
    }
  }

  onSearch(value: string) {
    this.searchText = value
    if (!value.trim()) {
      this.filteredFriends = this.allFriends
    } else {
      const keyword = value.toLowerCase()
      this.filteredFriends = this.allFriends.filter((friend: FriendItem) => {
        const name = friend.name || ''
        return name.toLowerCase().includes(keyword)
      })
    }
  }

  onSelectFriend(friend: FriendItem) {
    this.selectedFriend = friend
    this.showConfirmDialog = true
  }

  onConfirmForward = async () => {
    if (!this.selectedFriend || !this.forwardContent) {
      Toast.show('转发内容无效')
      this.showConfirmDialog = false
      return
    }

    this.isSending = true
    try {
      const result = await sendMessage(this.userId, this.selectedFriend.friend_id, this.forwardContent)
      if (result.success) {
        AppStorage.setOrCreate('needRefreshChat', true)
        Toast.show('转发成功')
        router.back()
      } else {
        Toast.show(result.message || '转发失败')
      }
    } catch (err) {
      console.error(`[ForwardPage] 转发异常: ${JSON.stringify(err)}`)
      Toast.show('转发失败')
    } finally {
      this.isSending = false
      this.showConfirmDialog = false
    }
  }

  build() {
    Column() {
      Row() {
        Stack() {
          TextInput({ text: this.searchText, placeholder: '搜索好友', controller: this.controller })
            .placeholderFont({ size: 18, weight: 400 })
            .caretColor(Color.Green)
            .placeholderColor(Color.Grey)
            .width('100%')
            .height("100%")
            .padding({ left: 40, right: 60 })
            .fontSize(18)
            .fontColor(Color.Black)
            .borderRadius(8)
            .stateStyles({
              normal: {.backgroundColor(Color.White)
              },
              pressed: {.backgroundColor(Color.White)
              },
              clicked: {.backgroundColor(Color.White)
              },
              focused: {.backgroundColor(Color.White)
              }
            })
            .onChange((value: string) => {
              this.onSearch(value)
            })

          Row() {
            Image($r("app.media.ic_search"))
              .colorBlend(Color.Grey)
              .width(18)
              .height(18)
            if (this.searchText.length != 0) {
              Image($r('app.media.ic_delete'))
                .width(18)
                .height(18)
                .colorBlend(Color.Gray)
                .onClick(() => {
                  this.searchText = ""
                  this.filteredFriends = this.allFriends
                })
            }
          }
          .width("100%")
          .padding({ left: 10, right: 10 })
          .hitTestBehavior(HitTestMode.None)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .margin({ left: 15 })
        .layoutWeight(1)

        Text("取消")
          .fontColor("#5f6c8a")
          .width(50)
          .height("100%")
          .fontWeight(400)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .onClick(() => {
            router.back()
          })
      }
      .width("100%")
      .height(40)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10, left: 15, right: 15 })

      Divider()
        .margin({ top: 10 })
        .color("#e6e6e6")

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontColor(Color.Gray)
            .fontSize(14)
            .margin({ top: 10 })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredFriends.length === 0) {
        Column() {
          Text('暂无好友')
            .fontColor(Color.Gray)
            .fontSize(16)
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.filteredFriends, (friend: FriendItem, index: number) => {
            ListItem() {
              Row() {
                Image(AVATAR_LIST[index % AVATAR_LIST.length])
                  .width(44)
                  .height(44)
                  .borderRadius(4)

                Text(friend.name || '未知好友')
                  .fontSize(16)
                  .fontColor(Color.Black)
                  .margin({ left: 12 })

                Blank()
              }
              .width("100%")
              .padding({ left: 15, right: 15, top: 10, bottom: 10 })
              .backgroundColor(Color.White)
            }
            .onClick(() => {
              this.onSelectFriend(friend)
            })
          })
        }
        .divider({ strokeWidth: 0.5, color: '#f0f0f0', startMargin: 71 })
        .layoutWeight(1)
        .width("100%")

        if (this.showConfirmDialog) {
          Column() {
            Blank()
              .onClick(() => {
                this.showConfirmDialog = false
              })
          }
          .width("100%")
          .height("100%")
          .backgroundColor('rgba(0,0,0,0.4)')
          .position({ x: 0, y: 0 })

          Column() {
            Text(this.selectedFriend?.name || '')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.Black)
              .margin({ top: 20, bottom: 15 })

            Text(this.forwardContent)
              .fontSize(14)
              .fontColor(Color.Gray)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ bottom: 20 })

            Divider()
              .color("#e6e6e6")

            if (this.isSending) {
              Text('发送中...')
                .fontSize(16)
                .fontColor(Color.Gray)
                .width("100%")
                .textAlign(TextAlign.Center)
                .padding({ top: 15, bottom: 15 })
            } else {
              Text('转发')
                .fontSize(16)
                .fontColor("#5f6c8a")
                .width("100%")
                .textAlign(TextAlign.Center)
                .padding({ top: 15, bottom: 15 })
                .onClick(() => {
                  this.onConfirmForward()
                })

              Divider()
                .color("#e6e6e6")

              Text('取消')
                .fontSize(16)
                .fontColor(Color.Gray)
                .width("100%")
                .textAlign(TextAlign.Center)
                .padding({ top: 15, bottom: 15 })
                .onClick(() => {
                  this.showConfirmDialog = false
                })
            }
          }
          .width(280)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .position({ x: "50%", y: "50%" })
          .translate({ x: -140, y: -80 })
        }
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f3f3f3")
    .padding({ top: WindowManager.statusBarHeight, bottom: WindowManager.navBarHeight })
  }
}