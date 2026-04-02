import router from '@ohos.router'
import ListMenuItem from '../../component/ListMenuItem'
import { PhotoPickerUtils } from '../../utils/PhotoPickerUtils'
import WindowManager from '../../utils/WindowManager'
import { Toast } from '../../utils/Toast'
import { getUserInfo, UserInfo } from '../../utils/LoginApi'

@Preview
@Component
export default struct Mine {
  @State imgPath: Resource | string = $r('app.media.ic_user_head1')
  @StorageProp('userId') userId: string = '未登录'
  @State userName: string = '加载中...'
  @State userAccount: string = '加载中...'
  @State userStatus: string = ''

  aboutToAppear() {
    if (this.userId !== '未登录') {
      this.fetchUserInfo()
    } else {
      this.userName = '未登录'
      this.userAccount = '-'
    }
  }

  private async fetchUserInfo() {
    try {
      console.info(`[Mine] 准备获取用户信息 (query_personal_homepage)，userId: ${this.userId}`)
      const res: UserInfo | null = await getUserInfo(this.userId)
      
      if (res && res.user_id) {
        this.userName = res.name || '无名氏'
        this.userAccount = res.account || '未知账号'
        this.userStatus = res.status || ''
        
        // 分支逻辑负载头像
        const avatarId = String(res.profile_picture_id)
        if (avatarId === '0') {
          this.imgPath = $r('app.media.avatar_0')
        } else if (avatarId === '1') {
          this.imgPath = $r('app.media.avatar_1')
        } else {
          this.imgPath = $r('app.media.ic_user_head1')
        }
      } else {
        this.userName = '未知用户'
        this.userAccount = '-'
      }
    } catch (err) {
      console.error(`[Mine] 获取用户信息异常: ${JSON.stringify(err)}`)
      this.userName = '未知用户'
    }
  }

  build() {
    Column() {
      // 个人资料卡片
      Row() {
        Image(this.imgPath)
          .width(70)
          .height(70)
          .margin({ left: 25, right: 15 })
          .borderRadius(8)
          .onClick(() => {
            PhotoPickerUtils.openGallery(uri => { this.imgPath = uri; }, errMsg => { Toast.show(errMsg) })
          })

        Column() {
          Text(this.userName)
            .fontColor(Color.Black)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)

          Text(`微信号：${this.userAccount}`)
            .fontColor(Color.Grey)
            .fontSize(14)
            .margin({ top: 8 })

          if (this.userStatus) {
            Text(this.userStatus)
              .fontColor(Color.Grey)
              .margin({ top: 12 })
              .padding({ left: 8, right: 8 })
              .fontSize(12)
              .borderRadius(12)
              .borderWidth(0.5)
              .borderColor('#CCC')
              .backgroundColor(Color.White)
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        
        Image($r('app.media.ic_qrcode'))
          .width(18)
          .height(18)
          .margin({ right: 15 })
          .onClick(() => { router.pushUrl({ url: 'pages/qrcode/MyQrCodePage' }) })

        Image($r("app.media.ic_more"))
          .width(8)
          .height(14)
          .margin({ right: 15 })

      }
      .width("100%")
      .padding({ top: WindowManager.statusBarHeight + 40, bottom: 40 })
      .backgroundColor(Color.White)
      .onClick(() => { router.pushUrl({ url: 'pages/qrcode/MyQrCodePage' }) })

      Divider().color("#f3f3f3").strokeWidth(10)

      ListMenuItem({ 
        title: "服务", 
        iconSrc: $r('app.media.ic_service'), 
        clickHandler: () => { router.pushUrl({ url: 'pages/mine/ServicePage' }) } 
      })
      
      Divider().color("#f3f3f3").strokeWidth(10)

      ListMenuItem({ 
        title: "收藏", 
        iconSrc: $r("app.media.ic_collect"),
        clickHandler: () => { router.pushUrl({ url: 'pages/favorite/Favorite' }) }
      })

      Divider().color("#f3f3f3").strokeWidth(1)

      ListMenuItem({ title: "朋友圈", iconSrc: $r('app.media.ic_moment_pic') })
        .onClick(() => { 
          // 暂时跳转跳转发现页，直到朋友圈详情页开发完成
          Toast.show("更多动态请前往'发现'页查看")
        })

      Divider().color("#f3f3f3").strokeWidth(1)
      ListMenuItem({ title: "卡包", iconSrc: $r('app.media.ic_card_pkg') }).onClick(() => Toast.show("二级页面正在开发中..."))
      Divider().color("#f3f3f3").strokeWidth(1)
      ListMenuItem({ title: "表情", iconSrc: $r('app.media.ic_face_icon') }).onClick(() => Toast.show("二级页面正在开发中..."))
      
      Divider().color("#f3f3f3").strokeWidth(10)

      ListMenuItem({ 
        title: "设置", 
        iconSrc: $r('app.media.ic_setting'),
        clickHandler: () => { router.pushUrl({ url: 'pages/mine/SettingPage' }) }
      })
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")
  }
}
