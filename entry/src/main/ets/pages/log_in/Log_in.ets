import router from '@ohos.router'
import { Toast } from '../../utils/Toast'
import WindowManager from '../../utils/WindowManager'
import { login } from '../../utils/LoginApi'

@Entry
@Component
export default struct Log_in {
  @State private account: string = ''
  @State private password: string = ''
  @State private loading: boolean = false

  build() {
    Column() {
      Column() {
        Column() {
          Image($r('app.media.ic_user_head2'))
            .width(76)
            .height(76)
            .borderRadius(38)
            .margin({ bottom: 14 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 40, bottom: 24 })

        Column() {
          Row() {
            Text('账号')
              .fontSize(16)
              .fontColor('#A8A8A8')
              .width(56)
            TextInput({ placeholder: '手机号/账号', text: this.account })
              .type(InputType.Normal)
              .placeholderColor('#6B6B6B')
              .fontColor('#EDEDED')
              .caretColor('#1AAD19')
              .onChange(v => this.account = v)
              .height(40)
              .fontSize(16)
              .layoutWeight(1)
          }
          .height(40)
          .width('100%')
          Divider()
            .strokeWidth(1)
            .color('#1f1f1f')
            .margin({ top: 6, bottom: 4 })

          Row() {
            Text('密码')
              .fontSize(16)
              .fontColor('#A8A8A8')
              .width(56)
            TextInput({ placeholder: '请填写微信密码', text: this.password })
              .type(InputType.Password)
              .placeholderColor('#6B6B6B')
              .fontColor('#EDEDED')
              .caretColor('#1AAD19')
              .onChange(v => this.password = v)
              .height(40)
              .fontSize(16)
              .layoutWeight(1)
          }
          .height(40)
          .width('100%')
          Divider()
            .strokeWidth(1)
            .color('#1f1f1f')
            .margin({ top: 6 })
        }
        .width('88%')
        .alignSelf(ItemAlign.Center)

        Button(this.loading ? '登录中…' : '登录')
          .type(ButtonType.Capsule)
          .width('88%')
          .height(46)
          .fontSize(17)
          .fontColor(Color.White)
          .backgroundColor(this.canSubmit() ? '#1AAD19' : '#2B6F39')
          .borderRadius(23)
          .alignSelf(ItemAlign.Center)
          .margin({ top: 28 })
          .onClick(() => {
            if (this.canSubmit() && !this.loading) {
              this.doLogin()
            }
          })

        Divider().color('#0000').strokeWidth(0).layoutWeight(1)

        Row() {
          Text('找回密码')
            .fontSize(13)
            .fontColor('#6B8FB2')
            .onClick(() => Toast.show('请联系管理员'))
          Text('  ')
          Text('紧急冻结')
            .fontSize(13)
            .fontColor('#6B8FB2')
            .onClick(() => Toast.show('暂未开通'))
          Text('  ')
          Text('注册')
            .fontSize(13)
            .fontColor('#6B8FB2')
            .onClick(() => {
              router.pushUrl({ url: 'pages/log_in/Register' })
            })
        }
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 26 })
        .width('100%')
      }
      .width('100%')
      .padding({ top: WindowManager.statusBarHeight })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B0B0B')
  }

  private canSubmit(): boolean {
    return this.account.trim().length > 0 && this.password.length > 0 && !this.loading
  }

  private formatAccount(): string {
    const s = this.account.replace(/\s/g, '')
    if (s.length === 11) {
      return `${s.substring(0, 3)} ${s.substring(3, 7)} ${s.substring(7)}`
    }
    return s
  }

  private async doLogin() {
    if (this.loading) {
      return
    }
    this.loading = true
    try {
      const res = await login(this.account, this.password)
      if (res.success) {
        // 将 user_id 存入全局 AppStorage
        if (res.userId) {
          AppStorage.setOrCreate<string>('userId', String(res.userId))
        }
        Toast.show(res.message)
        router.clear()
        router.pushUrl({ url: 'pages/Index' })
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
