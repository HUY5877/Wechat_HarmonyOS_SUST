import prompt from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';
import { Toast } from '../../utils/Toast';
import WindowManager from '../../utils/WindowManager';
import { searchMessage, SearchMessageItem } from '../../utils/LoginApi';

@Entry
@Component
export default struct SearchMessagePage {
  private context = getContext(this) as common.UIAbilityContext;
  private controller: TextInputController = new TextInputController()
  private keyboardHeight: number = 0
  private chatName: string = ''
  private chatFriendId: string = ''
  @State private searchText: string = ''
  @State private searchResults: SearchMessageItem[] = []
  @State private isSearching: boolean = false
  @StorageProp('userId') userId: string = ''

  async aboutToAppear() {
    const params = router.getParams() as Record<string, string>
    if (params) {
      this.chatName = params['name'] || ''
      this.chatFriendId = params['friend_id'] || ''
    }
    await window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (height) => {
        this.keyboardHeight = height;
      })
    })
  }

  onBackPress() {
    return this.keyboardHeight > 0
  }

  async onSearch() {
    if (!this.searchText.trim()) {
      Toast.show('请输入搜索关键字')
      return
    }

    console.info(`[SearchMessagePage] 开始搜索，关键字: ${this.searchText.trim()}, friendId: ${this.chatFriendId}`)
    this.isSearching = true
    this.searchResults = []

    try {
      const result = await searchMessage(this.userId, this.chatFriendId, this.searchText.trim())
      console.info(`[SearchMessagePage] 搜索结果: success=${result.success}, messages.length=${result.messages.length}`)
      if (result.success) {
        console.info(`[SearchMessagePage] 搜索成功，共找到 ${result.messages.length} 条消息`)
        this.searchResults = result.messages
        if (this.searchResults.length === 0) {
          Toast.show('未找到相关消息')
        }
      } else {
        Toast.show(result.message || '搜索失败')
      }
    } catch (err) {
      console.error(`[SearchMessagePage] 搜索异常: ${JSON.stringify(err)}`)
      Toast.show('搜索失败')
    } finally {
      this.isSearching = false
    }
  }

  build() {
    Column() {
      Row() {
        Stack() {
          TextInput({ text: this.searchText, placeholder: '搜索聊天记录', controller: this.controller })
            .placeholderFont({ size: 20, weight: 400 })
            .caretColor(Color.Green)
            .placeholderColor(Color.Grey)
            .width('100%')
            .height("100%")
            .padding({ left: 40, right: 60 })
            .fontSize(20)
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
              this.searchText = value
            })
            .onSubmit(() => {
              this.onSearch()
            })

          Row() {
            Image($r("app.media.ic_search"))
              .colorBlend(Color.Grey)
              .width(20)
              .height(20)
            if (this.searchText.length != 0) {
              Image($r('app.media.ic_delete'))
                .width(20)
                .height(20)
                .colorBlend(Color.Gray)
                .onClick(() => {
                  this.searchText = ""
                  this.searchResults = []
                })
            }
          }
          .width("100%")
          .padding({ left: 10, right: 10 })
          .hitTestBehavior(HitTestMode.None)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .margin({ left: 20 })
        .layoutWeight(1)

        Text("取消")
          .fontColor("#5f6c8a")
          .width(50)
          .height("100%")
          .fontWeight(400)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .onClick(() => {
            if ("1" === router.getLength()) {
              this.context.terminateSelf()
            } else {
              router.back()
            }
          })

        Text("搜索")
          .fontColor("#5f6c8a")
          .width(50)
          .height("100%")
          .fontWeight(400)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .onClick(() => {
            this.onSearch()
          })
      }
      .width("100%")
      .height(40)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10 })

      if (this.isSearching) {
        LoadingProgress()
          .width(40)
          .height(40)
          .margin({ top: 20 })
      } else if (this.searchResults.length > 0) {
        List() {
          ForEach(this.searchResults, (item: SearchMessageItem, index: number) => {
            ListItem() {
              Column() {
                Text(item.content)
                  .fontSize(16)
                  .fontColor(Color.Black)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .padding(10)
                  .borderRadius(4)
              }
              .margin({ left: 15, right: 15, top: 8 })
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/chat/ChatPage',
                params: {
                  name: this.chatName || '聊天记录',
                  friend_id: item.friend_id,
                  messageId: item.message_id
                }
              })
            })
          })
        }
        .layoutWeight(1)
        .margin({ top: 10 })
        .width("100%")
      } else if (this.searchText.trim().length > 0 && !this.isSearching) {
        Text("未找到相关聊天记录")
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ top: 40 })
      } else {
        Text("输入关键字搜索聊天记录")
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ top: 40 })
      }
    }
    .width("100%")
    .height("100%")
    .alignItems(HorizontalAlign.Start)
    .backgroundColor("#f3f3f3")
    .padding({ top: WindowManager.statusBarHeight, bottom: WindowManager.navBarHeight })
  }
}