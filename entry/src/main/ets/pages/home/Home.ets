import router from '@ohos.router'
import ListChatItem, { ChatItemData } from '../../component/ListChatItem'
import WechatToolbar from '../../component/WechatToolbar'
import { getMessageList, MessageSummary } from '../../utils/ChatApi'
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
      this.loadMessageList()
    } else {
      Toast.show('请先登录')
      this.isLoading = false
    }
  }

  private async loadMessageList() {
    try {
      console.info(`[Home] 开始获取消息列表 (query_message_list), userId: ${this.userId}`)
      const messages: MessageSummary[] = await getMessageList(this.userId)

      if (messages && messages.length > 0) {
        this.chatList = messages.map((msg, index): ChatItemData => {
          return {
            headSrc: AVATAR_LIST[index % AVATAR_LIST.length],
            nickname: msg.user_name || '未知用户',
            content: msg.new_message || '暂无消息',
            time: '刚刚',
            friend_id: msg.user_id
          } as ChatItemData
        })
        console.info(`[Home] 成功加载 ${this.chatList.length} 条会话`)
      } else {
        console.info(`[Home] 消息列表为空`)
        this.chatList = []
      }
    } catch (err) {
      console.error(`[Home] 获取消息列表异常: ${JSON.stringify(err)}`)
      Toast.show('加载会话失败')
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      WechatToolbar({ 
        title: `微信(${this.chatList.length})`,
        onSearchClick: () => {
          router.pushUrl({ url: 'pages/chat/SearchMessagePage' })
        }
      })

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
