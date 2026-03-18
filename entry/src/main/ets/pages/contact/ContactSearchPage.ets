import prompt from '@ohos.promptAction';
import router from '@ohos.router';
import window from '@ohos.window';
import WindowManager from '../../utils/WindowManager';
import ContactApi, { FriendInfo } from '../../utils/ContactApi';
import { ContactItem } from '../contact/DataItem';

interface SearchResult {
  friend_id: string;
  friend_name: string;
}

@Entry
@Component
export default struct ContactSearchPage {
  private controller: TextInputController = new TextInputController()
  private keyboardHeight: number = 0
  @State private searchText: string = ''
  @State private searchResults: ContactItem[] = []
  @State private isSearching: boolean = false
  private currentUserId: string = "1"

  private headImages: Resource[] = [
    $r("app.media.ic_user_head1"),
    $r("app.media.ic_user_head2"),
    $r("app.media.ic_user_head3"),
    $r("app.media.ic_user_head4"),
    $r("app.media.ic_user_head5"),
    $r("app.media.ic_user_head6"),
    $r("app.media.ic_user_head7")
  ]

  async aboutToAppear() {
    await window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (height) => {
        this.keyboardHeight = height;
      })
    })
  }

  onBackPress() {
    return this.keyboardHeight > 0
  }

  aboutToDisappear() {
    this.searchText = ''
    this.searchResults = []
  }

  build() {
    Column() {
      Row() {
        Stack() {
          TextInput({ text: this.searchText, placeholder: '搜索', controller: this.controller })
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
              this.doSearch(value)
            })
            .onSubmit(() => {
              this.doSearch(this.searchText)
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
          .width(70)
          .height("100%")
          .fontWeight(400)
          .textAlign(TextAlign.Center)
          .fontSize(19)
          .onClick(() => {
            router.back()
          })
      }
      .width("100%")
      .height(40)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10 })

      if (this.isSearching) {
        Column() {
          Text("搜索中...")
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .width("100%")
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.searchText.length === 0) {
        Column() {
          Text("搜索通讯录")
            .fontColor(Color.Gray)
            .fontSize(15)
        }
        .width("100%")
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 25, top: 20 })
      } else if (this.searchResults.length === 0) {
        Column() {
          Text("无搜索结果")
            .fontColor(Color.Gray)
            .fontSize(15)
        }
        .width("100%")
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 100 })
      } else {
        List() {
          ForEach(this.searchResults, (item: ContactItem, index: number) => {
            ListItem() {
              Row() {
                Image(item.head)
                  .width(48)
                  .height(48)
                  .borderRadius(4)
                  .margin({ right: 12 })
                Text(item.name)
                  .fontSize(17)
                  .fontColor(Color.Black)
              }
              .width("100%")
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/chat/ChatPage',
                params: { name: item.name }
              })
            })
          })
        }
        .width("100%")
        .layoutWeight(1)
        .backgroundColor(Color.White)
      }

    }
    .width("100%")
    .height("100%")
    .alignItems(HorizontalAlign.Start)
    .backgroundColor("#f3f3f3")
    .padding({ top: WindowManager.statusBarHeight, bottom: WindowManager.navBarHeight })
  }

  async doSearch(keyword: string) {
    if (keyword.trim() === '') {
      this.searchResults = []
      return
    }

    this.isSearching = true

    try {
      const results = await ContactApi.searchContacts(this.currentUserId, keyword)
      this.searchResults = results.map((item: FriendInfo, index: number): ContactItem => ({
        name: item.name,
        head: this.headImages[index % this.headImages.length]
      }))
    } catch (error) {
      prompt.showToast({ message: '搜索失败' })
      this.searchResults = []
    }

    this.isSearching = false
  }
}
