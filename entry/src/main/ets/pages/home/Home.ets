import router from '@ohos.router'
import ListChatItem, { ChatItemData } from '../../component/ListChatItem'
import WechatToolbar from '../../component/WechatToolbar'
import { getFriendsList } from '../../utils/LoginApi'
import { Toast } from '../../utils/Toast'

const AVATAR_LIST: Resource[] = [
  $r("app.media.ic_user_head1"),
  $r("app.media.ic_user_head2"),
  $r("app.media.ic_user_head3"),
  $r("app.media.ic_user_head4"),
  $r("app.media.ic_user_head5"),
  $r("app.media.ic_user_head6"),
  $r("app.media.ic_user_head7")
]

@Preview
@Component
export default struct Home {
  @StorageProp('userId') userId: string = ''
  @State chatList: ChatItemData[] = []
  @State isLoading: boolean = true

  aboutToAppear() {
    if (this.userId && this.userId !== '未登录') {
      this.loadFriendsList()
    } else {
      Toast.show('请先登录')
      this.isLoading = false
    }
  }

  private async loadFriendsList() {
    try {
      console.info(`[Home] 开始获取好友列表，userId: ${this.userId}`)
      const result = await getFriendsList(this.userId)

      if (result.success) {
        const friends = result.friends

        if (friends && friends.length > 0) {
          this.chatList = friends.map((friend, index) => {
            const chatItem: ChatItemData = {
              headSrc: AVATAR_LIST[index % AVATAR_LIST.length],
              nickname: friend.name || '未知好友',
              friend_id: friend.friend_id
            }
            return chatItem
          })
          console.info(`[Home] 成功加载 ${this.chatList.length} 个好友`)
        } else {
          console.info(`[Home] 好友列表为空`)
          this.chatList = []
        }
      } else {
        console.error(`[Home] 获取好友列表失败: ${result.message}`)
        Toast.show(result.message || '获取好友列表失败')
      }
    } catch (err) {
      console.error(`[Home] 获取好友列表异常: ${JSON.stringify(err)}`)
      Toast.show('加载好友列表失败')
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      WechatToolbar({ title: `微信(${this.chatList.length})` })

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontColor(Color.Gray)
            .fontSize(16)
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
      } else if (this.chatList.length === 0) {
        Column() {
          Text('暂无好友')
            .fontColor(Color.Gray)
            .fontSize(16)
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
      } else {
        List() {
          ForEach(this.chatList, (item: ChatItemData, index: number) => {
            ListItem() {
              ListChatItem({ data: item })
            }
            .onClick(() => {
              router.pushUrl({
                url: 'pages/chat/ChatPage',
                params: { name: item.nickname, friend_id: item.friend_id }
              })
            })
          })
          ListItem() {
            Divider().color('#0000').strokeWidth(0)
          }
        }
        .divider({ strokeWidth: 0.8, color: '#f0f0f0', startMargin: 90, endMargin: 0 })
        .backgroundColor(Color.White)
        .width("100%")
        .height("100%")
      }

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")
  }
}
