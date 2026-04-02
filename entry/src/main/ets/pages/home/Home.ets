import router from '@ohos.router'
import ListChatItem, { ChatItemData } from '../../component/ListChatItem'
import WechatToolbar from '../../component/WechatToolbar'
import { Toast } from '../../utils/Toast'
import ContactApi, { FriendDetail, FriendInfo } from '../../utils/ContactApi'
import { getAvatarResource } from '../../utils/AvatarUtils'

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
      const friends: FriendInfo[] = await ContactApi.getContacts(this.userId)

      if (friends && friends.length > 0) {
        // 查询每个好友的详细信息以获取头像
        const chatItems: ChatItemData[] = []
        for (const friend of friends) {
          console.info(`[Home] 查询好友详情，friend_id: ${friend.friend_id}`)
          const detail: FriendDetail | null = await ContactApi.getFriendDetail(friend.friend_id)
          if (detail) {
            chatItems.push({
              headSrc: getAvatarResource(detail.profile_picture_id || '0'),
              nickname: detail.name || friend.name || '未知好友',
              friend_id: friend.friend_id
            })
          } else {
            // 如果获取不到详情，使用默认头像
            chatItems.push({
              headSrc: getAvatarResource('0'),
              nickname: friend.name || '未知好友',
              friend_id: friend.friend_id
            })
          }
        }
        this.chatList = chatItems
        console.info(`[Home] 成功加载 ${this.chatList.length} 个好友`)
      } else {
        console.info(`[Home] 好友列表为空`)
        this.chatList = []
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
