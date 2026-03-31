import router from '@ohos.router'
import { Toast } from '../../utils/Toast'
import WindowManager from '../../utils/WindowManager'
import { register } from '../../utils/LoginApi'

class AvatarItem {
  resource: Resource
  id: string

  constructor(resource: Resource, id: string) {
    this.resource = resource
    this.id = id
  }
}

@CustomDialog
struct AvatarSelectDialog {
  controller?: CustomDialogController
  onSelect?: (uri: Resource, id: string) => void
  private avatars: AvatarItem[] = [
    new AvatarItem($r('app.media.avatar_0'), '0'),
    new AvatarItem($r('app.media.avatar_1'), '1')
  ]

  build() {
    Column() {
      Text('选择头像')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .margin({ top: 20, bottom: 20 })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
        ForEach(this.avatars, (item: AvatarItem) => {
          Image(item.resource)
            .width(80)
            .height(80)
            .borderRadius(40)
            .margin(10)
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(item.resource, item.id)
              }
              this.controller?.close()
            })
        })
      }
      .padding({ left: 16, right: 16, bottom: 20 })
      
      Button('取消')
        .type(ButtonType.Capsule)
        .backgroundColor('#F2F2F2')
        .fontColor('#333333')
        .width('80%')
        .margin({ bottom: 20 })
        .onClick(() => {
          this.controller?.close()
        })
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .width('90%')
  }
}

@Entry
@Component
export default struct Register {
  @State private account: string = ''
  @State private username: string = ''
  @State private password: string = ''
  @State private confirmPassword: string = ''
  @State private loading: boolean = false
  @State private avatarUri: Resource | null = null
  private selectedAvatarId: string = '0' // 默认头像ID

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AvatarSelectDialog({
      onSelect: (uri: Resource, id: string) => {
        this.avatarUri = uri
        this.selectedAvatarId = id
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回')
          .type(ButtonType.Capsule)
          .width(70)
          .height(32)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#1AAD19')
          .onClick(() => {
            router.back()
          })
        Text('注册')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#EDEDED')
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Column() {
        // 头像区域
        Column() {
          if (this.avatarUri !== null) {
            Image(this.avatarUri)
              .width(76)
              .height(76)
              .borderRadius(38)
              .objectFit(ImageFit.Cover)
          } else {
            Column() {
              Text('+')
                .fontSize(40)
                .fontColor('#A8A8A8')
                .fontWeight(FontWeight.Lighter)
            }
            .width(76)
            .height(76)
            .borderRadius(38)
            .backgroundColor('#1F1F1F')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .margin({ top: 40, bottom: 40 })
        .onClick(() => {
          this.selectAvatar()
        })

        // 表单区域
        Column() {
          // 账号输入
          Row() {
            Text('账号')
              .fontSize(16)
              .fontColor('#A8A8A8')
              .width(70)
            TextInput({ placeholder: '请输入账号', text: this.account })
              .type(InputType.Normal)
              .placeholderColor('#6B6B6B')
              .fontColor('#EDEDED')
              .caretColor('#1AAD19')
              .onChange(v => this.account = v)
              .height(40)
              .fontSize(16)
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
          }
          .height(48)
          .width('100%')
          Divider().strokeWidth(1).color('#1f1f1f')

          // 用户名输入
          Row() {
            Text('用户名')
              .fontSize(16)
              .fontColor('#A8A8A8')
              .width(70)
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .type(InputType.Normal)
              .placeholderColor('#6B6B6B')
              .fontColor('#EDEDED')
              .caretColor('#1AAD19')
              .onChange(v => this.username = v)
              .height(40)
              .fontSize(16)
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
          }
          .height(48)
          .width('100%')
          Divider().strokeWidth(1).color('#1f1f1f')

          // 密码输入
          Row() {
            Text('密码')
              .fontSize(16)
              .fontColor('#A8A8A8')
              .width(70)
            TextInput({ placeholder: '请设置密码', text: this.password })
              .type(InputType.Password)
              .placeholderColor('#6B6B6B')
              .fontColor('#EDEDED')
              .caretColor('#1AAD19')
              .onChange(v => this.password = v)
              .height(40)
              .fontSize(16)
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
          }
          .height(48)
          .width('100%')
          Divider().strokeWidth(1).color('#1f1f1f')

          // 确认密码输入
          Row() {
            Text('确认密码')
              .fontSize(16)
              .fontColor('#A8A8A8')
              .width(70)
            TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
              .type(InputType.Password)
              .placeholderColor('#6B6B6B')
              .fontColor('#EDEDED')
              .caretColor('#1AAD19')
              .onChange(v => this.confirmPassword = v)
              .height(40)
              .fontSize(16)
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
          }
          .height(48)
          .width('100%')
          Divider().strokeWidth(1).color('#1f1f1f')
        }
        .width('88%')
        .alignSelf(ItemAlign.Center)

        // 注册按钮
        Button(this.loading ? '注册中…' : '注册')
          .type(ButtonType.Capsule)
          .width('88%')
          .height(46)
          .fontSize(17)
          .fontColor(Color.White)
          .backgroundColor(this.canSubmit() ? '#1AAD19' : '#2B6F39')
          .borderRadius(23)
          .alignSelf(ItemAlign.Center)
          .margin({ top: 40 })
          .onClick(() => {
            if (this.canSubmit() && !this.loading) {
              this.doRegister()
            }
          })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B0B0B')
    .padding({ top: WindowManager.statusBarHeight })
  }

  private canSubmit(): boolean {
    return this.account.trim().length > 0 && 
           this.username.trim().length > 0 &&
           this.password.length > 0 && 
           this.confirmPassword.length > 0 && 
           !this.loading
  }

  private selectAvatar() {
    this.dialogController.open()
  }

  private async doRegister() {
    if (this.password !== this.confirmPassword) {
      Toast.show('两次输入的密码不一致')
      return
    }

    if (this.loading) return
    this.loading = true

    try {
      // 传递账号、密码、用户名和头像ID
      const res = await register(this.account, this.password, this.username, this.selectedAvatarId)
      if (res.success) {
        Toast.show('注册成功，请登录')
        router.back()
      } else {
        Toast.show(res.message)
      }
    } catch (err) {
      Toast.show('请求失败')
    } finally {
      this.loading = false
    }
  }
}
