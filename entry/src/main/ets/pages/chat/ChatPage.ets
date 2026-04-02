import router from '@ohos.router';
import Toolbar from '../../component/Toolbar';
import ListChatContentLeftItem from '../../component/ListChatContentLeftItem';
import ListChatContentRightItem from '../../component/ListChatContentRightItem';
import window from '@ohos.window';
import WindowManager from '../../utils/WindowManager';
import ChatFunctionBar from './ChatFuntionBar';
import { ChatContentItemData } from './ChatContentItemData';
import ChatPageParam from './ChatPageParam';
import { Toast } from '../../utils/Toast';
import SpeechRecognizerManager from '../../utils/SpeechRecognizerManager';
import { AudioCaptureManager, RecordFile } from '../../utils/AudioCapturerManager';
import { componentUtils } from '@kit.ArkUI';
import { vibrator } from '@kit.SensorServiceKit';
import { PermissionUtils } from '../../utils/PermissionUtils';
import { getMessagesList, deleteMessage, MessageItem, addFavoriteMessage } from '../../utils/LoginApi';
import { getMessagesList, deleteMessage, MessageItem, sendMessage } from '../../utils/ChatApi';

enum WXInputType {
  /**
   * 语音输入
   */
  voice = 0,
  /**
   * 文本输入
   */
  keyboard = 1
}

enum MessageType {
  /**
   * 声音
   */
  voice = 0,
  /**
   * 文本
   */
  text = 1
}

// 消息
class ChatMessage {
  /**
   * 消息类型：【录音、文本】
   */
  type: MessageType
  /**
   * 内容 [录音-文件路径，文本-内容]
   */
  content: string
  /**
   * 消息时间
   */
  time: string
  /**
   * 声音的持续时间 单位毫秒
   */
  duration?: number
  /**
   * 录音转的文字
   */
  translateText?: string
  /**
   * 是否显示转好的文字
   */
  isShowTranslateText: boolean = false

  constructor(type: MessageType, content: string, duration?: number, translateText?: string) {
    this.type = type
    this.content = content
    const date = new Date()
    this.time = `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`
    this.duration = duration
    this.translateText = translateText
  }
}

enum PressCancelVoicePostText {
  // 没有长按
  none = 0,
  //   长按 没有选中“取消发送”或者"转语音"
  pressing = 1,
  //   取消发送
  cancelVoice = 2,
  //   转文字
  postText = 3
}

/**
 * 长按时，手指的坐标
 */
interface ScreenOffset {
  x: number
  y: number
  width: number
  height: number
}

@Entry
@Component
export default struct ChatPage {
  private name?: string = "微信"
  private friendId?: string = ""
  private targetMessageId?: string = ""
  private controller: TextAreaController = new TextAreaController()
  private scroller: Scroller = new Scroller()
  @State private chatText: string = ''
  @StorageProp('userId') userId: string = ''
  private keyboardHeight: number = 0
  @State private funcBarHeight: number = 0;
  @State private showFuncBar: boolean = false;
  @State private showMessageMenu: boolean = false
  @State private selectedMessageIndex: number = -1
  @State private showPasteButton: boolean = false
  @State private dataList: ChatContentItemData[] = [
    {
      name: "鲁班",
      headSrc: $r("app.media.ic_user_head2"),
      msgType: 0,
      self: true,
      msg: "现在几点了？"
    },
    {
      name: "王昭君",
      headSrc: $r("app.media.ic_user_head3"),
      msgType: 0,
      self: false,
      msg: "10点，怎么了？"
    },
    {
      name: "鲁班",
      headSrc: $r("app.media.ic_user_head2"),
      msgType: 1,
      self: true,
      msg: "",
      img: $r("app.media.ic_its_over")
    },
    {
      name: "鲁班",
      headSrc: $r("app.media.ic_user_head2"),
      msgType: 0,
      self: true,
      msg: "我要迟到了！！！",
    }
    ,
    {
      name: "王昭君",
      headSrc: $r("app.media.ic_user_head3"),
      msgType: 1,
      self: false,
      msg: "",
      img: $r("app.media.ic_hahaha")
    }
    ,
    {
      name: "王昭君",
      headSrc: $r("app.media.ic_user_head3"),
      msgType: 0,
      self: false,
      msg: "那赶紧粗发吧，哈哈哈哈哈哈哈",
    }
    ,
    {
      name: "鲁班",
      headSrc: $r("app.media.ic_user_head2"),
      msgType: 0,
      self: true,
      msg: "嗯嗯，不说了，这就飞奔过去。。。",
    }
  ]
  // 输入框内容
  @State
  textValue: string = ""
  // 输入状态 语音或者文字
  @State
  inputType: WXInputType = WXInputType.keyboard
  // 语音识别的文字
  @State
  voiceToText: string = ""
  // 消息
  @State
  chatList: ChatMessage[] = []
  // 按住说话 录音模态
  @State
  showTalkContainer: boolean = false
  // 长按状态
  @State
  pressCancelVoicePostText: PressCancelVoicePostText = PressCancelVoicePostText.none
  //用来配置 CanvasRenderingContext2D 对象的参数，包括是否开启抗锯齿，true表明开启抗锯齿。
  settings: RenderingContextSettings = new RenderingContextSettings(true)
  //用来创建CanvasRenderingContext2D对象，通过在canvas中调用CanvasRenderingContext2D对象来绘制。
  context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  // 声明波纹定时器id
  voiceTimeId: number = -1
  // 底部录音气泡的坐标
  bubbleScreenOffset: ScreenOffset = {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  }
  // 录音文件名称
  recordFileName: string = ""
  // 发送文本消息
  sendTextMessage = () => {
    if (!this.textValue.trim()) {
      return
    }
    const chat = new ChatMessage(MessageType.text, this.textValue.trim())
    this.chatList.push(chat)
    this.textValue = ""
  }
  // 按住说话 持续触发
  onPressTalk = async (event: TouchEvent) => {
    if (event.type === TouchType.Down) {
      // 手指按下时触发
      this.pressCancelVoicePostText = PressCancelVoicePostText.pressing
      // 按下
      this.showTalkContainer = true
      // 震动反馈
      this.startVibration()

      //  开始录音
      this.onStartRecord()

      // 实时语音识别
      this.onStartSpeechRecognize()

    } else if (event.type === TouchType.Move) {
      // 手指移动时持续触发
      this.pressCancelVoicePostText = PressCancelVoicePostText.pressing
      // 获取当前手指的坐标
      const x = event.touches[0].displayX
      const y = event.touches[0].displayY
      // 判断是否碰到了 “X”
      let isTouchX = x <= this.bubbleScreenOffset.width / 2 && y < this.bubbleScreenOffset.y
      // 判断是否碰到了 "文"
      let isTouchText = x > this.bubbleScreenOffset.width / 2 && y < this.bubbleScreenOffset.y
      if (isTouchX) {
        // 取消发送
        this.pressCancelVoicePostText = PressCancelVoicePostText.cancelVoice
      } else if (isTouchText) {
        // 转换文字
        this.pressCancelVoicePostText = PressCancelVoicePostText.postText
      }
    } else if (event.type === TouchType.Up) {
      // 松开手
      this.showTalkContainer = false
      // 停止录音 res 为录音文件信息，包括录音路径、时长等信息
      const res = await this.stopRecord()
      // 结束AI语音识别
      SpeechRecognizerManager.release()

      if (this.pressCancelVoicePostText === PressCancelVoicePostText.postText) {
        // 转换文字
        this.postText()
      } else if (this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice) {
        // 取消发送
        this.voiceToText = ''
      } else {
        // 发送录音
        this.postVoice(res)
      }
    }
  }

  async aboutToAppear() {
    const params = router.getParams() as ChatPageParam
    this.name = params.name
    this.friendId = params.friend_id
    this.targetMessageId = params.messageId
    await this.loadMessages()
    await window.getLastWindow(getContext(this)).then(currentWindow => {
      currentWindow.on('keyboardHeightChange', (height) => {
        this.keyboardHeight = height;
      })
    })
  }

  onPageShow(): void {
    const shouldRefresh = AppStorage.get<boolean>('needRefreshChat')
    if (shouldRefresh) {
      AppStorage.set('needRefreshChat', false)
      this.loadMessages()
    }
  }

  private async loadMessages() {
    if (!this.userId || !this.friendId) {
      console.info('[ChatPage] userId 或 friendId 为空，跳过加载消息')
      return
    }
    try {
      console.info(`[ChatPage] 开始加载消息，userId: ${this.userId}, friendId: ${this.friendId}`)
      const messages = await getMessagesList(this.userId, this.friendId)

      if (messages && messages.length > 0) {
        const chatItems: ChatContentItemData[] = []
        for (let i = 0; i < messages.length; i++) {
          const msg = messages[i]
          const isSelf = msg.message_user_id === this.userId
          chatItems.push({
            name: isSelf ? this.name : '对方',
            msg: msg.content,
            msgType: 0,
            self: isSelf,
            messageId: msg.message_id
          })
        }
        this.dataList = chatItems
        console.info(`[ChatPage] 成功加载 ${chatItems.length} 条消息`)

        if (this.targetMessageId) {
          const targetIndex = chatItems.findIndex((item: ChatContentItemData) => item.messageId === this.targetMessageId)
          if (targetIndex >= 0) {
            console.info(`[ChatPage] 找到目标消息，index: ${targetIndex}`)
            this.scroller.scrollToIndex(targetIndex)
          } else {
            console.info(`[ChatPage] 未找到目标消息 messageId: ${this.targetMessageId}`)
            this.scroller.scrollToIndex(this.dataList.length - 1)
          }
        } else {
          // 默认进入页面滚动到最底部
          this.scroller.scrollToIndex(this.dataList.length - 1)
        }
      } else {
        console.info('[ChatPage] 暂无历史消息')
        this.dataList = []
      }
    } catch (err) {
      console.error(`[ChatPage] 加载消息异常: ${JSON.stringify(err)}`)
    }
  }
  onBackPress() {
    return this.keyboardHeight > 0
  }

  onMessageLongPress = (index: number): void => {
    this.selectedMessageIndex = index
    this.showMessageMenu = true
  }

  onCopyMessage = (): void => {
    if (this.selectedMessageIndex >= 0 && this.selectedMessageIndex < this.dataList.length) {
      const msg = this.dataList[this.selectedMessageIndex].msg
      if (msg) {
        AppStorage.setOrCreate('copiedMessage', msg)
        Toast.show('已复制到剪贴板')
      }
    }
    this.showMessageMenu = false
  }

  onDeleteMessage = async (): Promise<void> => {
    if (this.selectedMessageIndex >= 0 && this.selectedMessageIndex < this.dataList.length) {
      const msgItem = this.dataList[this.selectedMessageIndex]
      if (!msgItem.messageId) {
        Toast.show('该消息无法删除')
        this.showMessageMenu = false
        return
      }
      try {
        const result = await deleteMessage(this.userId, msgItem.messageId)
        if (result.success) {
          this.dataList.splice(this.selectedMessageIndex, 1)
          Toast.show('删除成功')
        } else {
          Toast.show(result.message || '删除失败')
        }
      } catch (err) {
        Toast.show('删除失败')
      }
    }
    this.showMessageMenu = false
  }

  onForwardMessage = (): void => {
    if (this.selectedMessageIndex >= 0 && this.selectedMessageIndex < this.dataList.length) {
      const msgItem = this.dataList[this.selectedMessageIndex]
      router.pushUrl({
        url: 'pages/chat/ForwardPage',
        params: {
          content: msgItem.msg
        }
      })
    }
    this.showMessageMenu = false
  }

  onCancelMenu = (): void => {
    this.showMessageMenu = false
    this.selectedMessageIndex = -1
  }

  onFavoriteMessage = async (): Promise<void> => {
    if (this.selectedMessageIndex < 0 || this.selectedMessageIndex >= this.dataList.length) {
      Toast.show('消息无效')
      this.showMessageMenu = false
      return
    }

    const msgItem = this.dataList[this.selectedMessageIndex]
    if (!msgItem.messageId) {
      Toast.show('该消息无法收藏')
      this.showMessageMenu = false
      return
    }

    try {
      const result = await addFavoriteMessage(this.userId, msgItem.messageId)
      if (result.success) {
        Toast.show('收藏成功')
      } else {
        Toast.show(result.message || '收藏失败')
      }
    } catch (err) {
      console.error(`[ChatPage] 收藏异常: ${JSON.stringify(err)}`)
      Toast.show('收藏失败')
    }

    this.showMessageMenu = false
  }

  // 开始录音
  onStartRecord = () => {
    // 文件名  唯一
    this.recordFileName = Date.now().toString()
    AudioCaptureManager.startRecord(this.recordFileName)
  }
  // 结束录音
  stopRecord = async () => {
    // res 记录录音文件的路径、时长等信息  这里返回是为了实现 发送录音消息
    const res = await AudioCaptureManager.stopRecord()
    return res
  }
  // 生成声音消息
  postVoice = (res: RecordFile) => {
    // 录音时长  录音结束时间-开始录音时间
    const duration = Math.ceil((res.endRecordTime - res.startRecordTime) / 1000)
    //   生成消息文件
    const voiceChat = new ChatMessage(MessageType.voice, res.recordFilePath, duration)
    //   插入到消息数组中
    this.chatList.push(voiceChat)
    this.dataList.push({
      name: "鲁班",
      headSrc: $r("app.media.ic_user_head2"),
      msgType: 2,
      voicePath: res.recordFilePath,
      self: true,
      msg: `${duration}"`,
      img: $r("app.media.ic_voice_msg_right")
    })
    this.scroller.scrollToIndex(this.dataList.length)
  }
  // 开启ai实时转换声音
  onStartSpeechRecognize = () => {
    // 如果你是完整的一句话，我把它拼接到 this.voiceToText 如果不是，实时显示
    // 缓存一段句子的变量
    let sentence = ""
    SpeechRecognizerManager.init((res) => {
      // console.log("res", JSON.stringify(res))
      //   isFinal  这一句话 你结束了没有
      //   isLast 这一段语音你结束了没有
      // this.voiceToText = res.result
      if (res.isFinal) {
        sentence += res.result
        this.voiceToText = sentence
      } else {
        this.voiceToText = sentence + res.result
      }

    })
  }
  // 生成文字消息
  postText = () => {
    //   生成消息文件
    const TextChat = new ChatMessage(MessageType.text, this.voiceToText)
    //   插入到消息数组中
    this.chatList.push(TextChat)
  }

  build() {
    Column() {
      Toolbar({
        title: this.name,
        subTitle: '',
        subIconSrc: $r("app.media.ic_search"),
        onSubClick: () => {
          router.pushUrl({
            url: 'pages/chat/SearchMessagePage',
            params: {
              name: this.name,
              friend_id: this.friendId
            }
          })
        }
      })
      List({ space: 20, initialIndex: this.dataList.length, scroller: this.scroller }) {
        ForEach(this.dataList, (item: ChatContentItemData, index: number) => {
          ListItem() {
            if (item.self) {
              ListChatContentRightItem({
                data: item,
                onLongPress: (idx) => {
                  this.onMessageLongPress(idx ?? index)
                }
              })
            } else {
              ListChatContentLeftItem({
                data: item,
                onLongPress: (idx) => {
                  this.onMessageLongPress(idx ?? index)
                }
              })
            }
          }
        })
        ListItem() {
          Row().height(px2vp(20))
        }
      }
      .width("100%")
      .height(0)
      // .divider({ strokeWidth: 0.8, color: '#f0f0f0', startMargin: 90, endMargin: 0 }) // 每行之间的分界线
      .layoutWeight(1)

      Row() {

        if (this.inputType == WXInputType.keyboard) {
          Image($r("app.media.ic_use_voice"))
            .width(33)
            .height(33)
            .borderRadius(4)
            .margin({ left: 15, right: 15 })
            .objectFit(ImageFit.Cover)
            .onClick(async () => {
              const result = await PermissionUtils.request(["ohos.permission.MICROPHONE"])
              if (!result) {
                Toast.show("请先授权麦克风权限")
              }
              this.inputType = WXInputType.voice
              this.showFuncBarWithAnim(false)
            })

          TextArea({ text: $$this.chatText, placeholder: '', controller: this.controller })
            .placeholderFont({ size: 20, weight: 400 })
            .caretColor(Color.Green)
            .placeholderColor(Color.Grey)
            .layoutWeight(1)
            .padding({ left: 8, right: 8 })
            .fontSize(20)
            .fontColor(Color.Black)
            .borderRadius(8)// 设置stateStyles，解决点击编辑框会变色的问题
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
            .onClick(() => {
              const copied = AppStorage.get<string>('copiedMessage')
              if (copied) {
                this.showPasteButton = true
              }
            })
            .gesture(
              LongPressGesture()
                .onAction(() => {
                  const copied = AppStorage.get<string>('copiedMessage')
                  if (copied) {
                    this.chatText = this.chatText + copied
                    Toast.show('已粘贴')
                  }
                })
            )
        } else {
          Image($r("app.media.ic_use_keyboard"))
            .width(33)
            .height(33)
            .borderRadius(4)
            .margin({ left: 15, right: 15 })
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              this.inputType = WXInputType.keyboard
            })

          Button("按住 说话")
            .fontColor(Color.Black)
            .layoutWeight(1)
            .type(ButtonType.Normal)
            .borderRadius(8)
            .backgroundColor(Color.White)
            .fontSize(18)
            .bindContentCover($$this.showTalkContainer, this.buildRecordVoiceView,
              { modalTransition: ModalTransition.NONE })
            .onTouch(this.onPressTalk)
        }

        if (this.showPasteButton) {
          Button('粘贴')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#58BE6A')
            .borderRadius(4)
            .height(32)
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              const copied = AppStorage.get<string>('copiedMessage')
              if (copied) {
                this.chatText = this.chatText + copied
                Toast.show('已粘贴')
              }
              this.showPasteButton = false
            })
        }

        Image($r("app.media.ic_emoji_pack"))
          .width(33)
          .height(33)
          .borderRadius(4)
          .margin({ left: 15, right: 5 })
          .objectFit(ImageFit.Cover)
          .onClick(unDevTip)


        Text("发送")
          .fontColor(Color.White)
          .width(65)
          .textAlign(TextAlign.Center)
          .height(36)
          .backgroundColor("#58BE6A")
          .fontSize(18)
          .visibility(this.chatText.length == 0 ? Visibility.None : Visibility.Visible)
          .borderRadius(6)
          .margin({ left: 10, right: 10 })
          .onClick(() => {
            this.sendTextMsg()
          })

        Image($r("app.media.ic_add"))
          .width(33)
          .height(33)
          .borderRadius(4)
          .visibility(this.chatText.length == 0 ? Visibility.Visible : Visibility.None)
          .margin({ left: 15, right: 8 })
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            if (!this.showFuncBar) {
              this.inputType = WXInputType.keyboard
            }
            this.showFuncBarWithAnim(!this.showFuncBar)
          })

      }
      .padding({ top: 10, bottom: 10 })
      .alignItems(VerticalAlign.Bottom)
      .backgroundColor("#f9f9f9")

      Divider()
        .vertical(false)
        .color("#f0f0f0")
        .strokeWidth(1)
        .lineCap(LineCapStyle.Round)

      ChatFunctionBar()
        .height(this.funcBarHeight)

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f1f1f1")
    .padding({ bottom: WindowManager.navBarHeight })
    .bindSheet($$this.showMessageMenu, this.buildMessageActionSheet(), {
      height: 70,
      dragBar: false,
      maskColor: '#80000000',
      onWillDismiss: () => {
        this.showMessageMenu = false
      }
    })
  }

  @Builder
  buildMessageActionSheet() {
    Column() {
      Row() {
        Button('删除')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onDeleteMessage()
          })

        Button('复制')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onCopyMessage()
          })

        Button('转发')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onForwardMessage()
          })

        Button('收藏')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onFavoriteMessage()
          })

        Button('取消')
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .height(40)
          .layoutWeight(1)
          .onClick(() => {
            this.onCancelMenu()
          })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      .backgroundColor('#ffffff')
      .borderRadius(8)
    }
    .width('100%')
    .backgroundColor('#80000000')
    .justifyContent(FlexAlign.End)
    .padding({ bottom: 8 })
  }

  private async sendTextMsg() {
    if (!this.chatText.trim()) {
      return
    }

    if (!this.userId || this.userId === '未登录') {
      Toast.show('请先登录')
      return
    }

    if (!this.friendId) {
      Toast.show('未识别的好友ID')
      return
    }

    const content = this.chatText.trim()
    this.chatText = "" // 立即清空输入框，提升用户体验

    try {
      console.info(`[ChatPage] 发送消息，userId: ${this.userId}, friendId: ${this.friendId}, content: ${content}`)
      const result = await sendMessage(this.userId, this.friendId, content)

      if (result.success) {
        console.info(`[ChatPage] 消息发送成功`)
        // 直接在 UI 上添加，避免等待刷新带来的卡顿感
        this.dataList.push({
          name: "我",
          headSrc: $r("app.media.ic_user_head1"),
          msgType: 0,
          self: true,
          msg: content,
        } as ChatContentItemData)
        this.scroller.scrollToIndex(this.dataList.length)
      } else {
        console.error(`[ChatPage] 消息发送失败: ${result.message}`)
        Toast.show(result.message || '发送失败')
        this.chatText = content // 发送失败时回填文字
      }
    } catch (err) {
      console.error(`[ChatPage] 发送消息异常: ${JSON.stringify(err)}`)
      Toast.show('发送异常')
      this.chatText = content // 发送异常时回填文字
    }
  }

  private showFuncBarWithAnim(show: boolean) {
    animateTo({ duration: 400, curve: Curve.Ease }, () => {
      if (show) {
        this.funcBarHeight = 250;
      } else {
        this.funcBarHeight = 0;
      }
      this.showFuncBar = show;
    })
  }

  @Builder
  buildRecordVoiceView() {
    Column() {
      // 中心波浪线
      Row() {
        if (this.pressCancelVoicePostText !== PressCancelVoicePostText.postText) {
          // 声纹
          this.vocalPrint()

        } else {
          Scroll() {
            // 显示录音的文字
            Text(this.voiceToText)
              .fontSize(12)
              .fontColor("#666")
          }
          .width("100%")
          .height("100%")
        }

        Text()
          .width(10)
          .height(10)
          .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? Color.Red :
            "#95EC6A")
          .position({
            bottom: -5,
            left: "50%"
          })
          .translate({
            x: "-50%"
          })
          .rotate({
            angle: 45
          })
      }
      .width("50%")
      .height(80)
      .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? Color.Red : "#95EC6A")
      .position({
        top: "40%",
        left: "50%"
      })
      .translate({
        x: "-50%"
      })
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 取消和转文字
      Row() {
        // X
        Row() {
          Text("X")
            .fontSize(20)
            .width(80)
            .height(80)
            .borderRadius("50%")
            .fontColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? "#333" : Color.Gray)
            .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? Color.White :
              "#333")
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .fontColor("#ccc")
            .id("cancel_record")
            .rotate({ angle: -15 })
        }

        // 文
        Row() {
          Text("文")
            .fontSize(20)
            .width(80)
            .height(80)
            .borderRadius("50%")
            .fontColor(this.pressCancelVoicePostText === PressCancelVoicePostText.postText ? "#333" : Color.Gray)
            .backgroundColor(this.pressCancelVoicePostText === PressCancelVoicePostText.postText ? Color.White : "#333")
            .textAlign(TextAlign.Center)
            .align(Alignment.Center)
            .id("translate_text")
            .rotate({ angle: 15 })
        }

        // 3  松开发送
        Text(this.pressCancelVoicePostText === PressCancelVoicePostText.cancelVoice ? '取消发送' :
          (this.pressCancelVoicePostText === PressCancelVoicePostText.postText ? '转换文字' : "松开发送"))
          .fontColor("#fff")
          .width("100%")
          .position({
            bottom: 0,
            left: 0
          })
          .textAlign(TextAlign.Center)
      }
      .width("100%")
      .position({
        bottom: "23%"
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 35, right: 35
      })


      Stack() {
        Text()
          .width(800)
          .height(800)
          .backgroundColor("#AAAAAA")
          .borderRadius("50%")// .position({ top: 0 ,left:"-50%"})
            // .position({ top: 0 ,left:"-50%"})
          .position({ top: 0, left: "50%" })
          .translate({
            x: "-50%",
          })

        Image($r("app.media.ic_voice_msg_left"))
          .width(33)
          .height(33)
          .objectFit(ImageFit.Cover)
      }
      .width("100%")
      .height(150)
      .alignContent(Alignment.Center)
      .position({
        bottom: 0
      })
      .id("bottom_bubble")
      .onAppear(() => {
        let modePosition: componentUtils.ComponentInfo = componentUtils.getRectangleById("bottom_bubble");
        this.bubbleScreenOffset.x = px2vp(modePosition.localOffset.x)
        this.bubbleScreenOffset.y = px2vp(modePosition.localOffset.y)
        this.bubbleScreenOffset.width = px2vp(modePosition.size.width)
        this.bubbleScreenOffset.height = px2vp(modePosition.size.height)
      })

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#9F000000")
  }

  /**
   * 录音中的 动态声纹波浪
   */
  @Builder
  vocalPrint() {
    Canvas(this.context)
      .onDisAppear(() => {
        clearInterval(this.voiceTimeId)
      })
      .width('80%')
      .height('80%')
      .onReady(() => {
        clearInterval(this.voiceTimeId)
        this.voiceTimeId = setInterval(() => {
          this.context.clearRect(0, 0, 200, 200)
          for (let index = 0; index < 35; index++) {
            const random = Math.floor(Math.random() * 20)
            let height = 5 + random
            this.context.fillRect(10 + index * 5, 32 - height / 2, 2, height);
          }
        }, 100)
      })
  }

  private async startVibration() {
    try {
      // 触发马达振动
      vibrator.startVibration({
        type: 'time',
        duration: 100,
      }, {
        id: 0,
        usage: 'touch'
      }, () => {
      })
    } catch (err) {
    }
  }
}


const unDevTip = () => {
  Toast.show("功能正在开发中...")
}

