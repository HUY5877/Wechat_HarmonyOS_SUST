import router from '@ohos.router'
import ListMenuItem from '../../component/ListMenuItem'
import { PhotoPickerUtils } from '../../utils/PhotoPickerUtils'
import WindowManager from '../../utils/WindowManager'
import { Toast } from '../../utils/Toast'
import { getUserInfo } from '../../utils/LoginApi'
import ApiService from '../../utils/ApiService'

// 定义用户信息接口
interface UserInfo {
  user_id: string;
  account: string;
  name: string;
  status: string;
  profile_picture_id: string;
}

@Preview
@Component
export default struct Mine {
  @State imgPath: Resource | string = ""
  @StorageProp('userId') userId: string = '未登录'
  @State userName: string = '加载中...'
  @State userAccount: string = '加载中...'

  @State userInfo: UserInfo = {
    user_id: "",
    account: "",
    name: "亚瑟王",
    status: "",
    profile_picture_id: ""
  }

  aboutToAppear() {
    if (this.userId !== '未登录') {
      this.fetchUserInfo()
      this.fetchExtraUserInfo()
    } else {
      this.userName = '未登录'
      this.userAccount = '-'
    }
  }

  private async fetchUserInfo() {
    try {
      console.info(`[Mine] 准备获取用户信息，userId: ${this.userId}`)
      const res = await getUserInfo(this.userId)
      console.info(`[Mine] 获取用户信息结果: ${JSON.stringify(res)}`)
      if (res.success && res.data) {
        this.userName = res.data.name || '无名氏'
        this.userAccount = res.data.account || '未知账号'
        
        // 获取后端的头像ID
        const avatarId = String(res.data.profile_picture_id)
        console.info(`[Mine] 尝试加载头像ID: ${avatarId}`)
        
        // 根据数据库中的头像ID，映射到本地的资源图片
        if (avatarId === '0') {
          this.imgPath = $r('app.media.avatar_0')
        } else if (avatarId === '1') {
          this.imgPath = $r('app.media.avatar_1')
        } else {
          // 如果没有匹配的头像ID，或者ID为空，使用默认头像
          this.imgPath = $r('app.media.ic_user_head1')
        }
      } else {
        Toast.show(res.message || '获取用户信息失败')
        this.userName = '未知用户'
        this.userAccount = '-'
      }
    } catch (err) {
      console.error(`[Mine] 获取用户信息异常: ${JSON.stringify(err)}`)
      Toast.show('请求用户信息失败')
      this.userName = '未知用户'
      this.userAccount = '-'
    }
  }

  private async fetchExtraUserInfo() {
    try {
      const result = await ApiService.getPersonalHomepage(this.userId);
      if (result) {
        this.userInfo.user_id = result.user_id || "";
        this.userInfo.account = result.account || "";
        this.userInfo.name = result.name || "亚瑟王";
        this.userInfo.status = result.status || "";
        this.userInfo.profile_picture_id = result.profile_picture_id || "";
      }
    } catch (error) {
      console.error('获取用户信息失败:', error);
    }
  }

  build() {
    Column() {

      Row() {
        Image(this.imgPath ? this.imgPath : $r('app.media.ic_user_head1'))
          .width(70)
          .height(70)
          .margin({ left: 25, right: 10 })
          .borderRadius(8)
          .onClick(() => {
            PhotoPickerUtils.openGallery(
              uri => {
                this.imgPath = uri;
              }, errMsg => {
              Toast.show(errMsg)
            })
          })

        Column() {
          Text(`用户ID: ${this.userName || this.userInfo.name}`)
            .fontColor(Color.Black)
            .fontSize(26)
            .fontWeight(700)

          Text(`微信号：${this.userAccount !== '加载中...' ? this.userAccount : this.userInfo.account}`)
            .fontColor(Color.Grey)
            .fontSize(16)
            .margin({ top: 15 })

          Text(this.userInfo.status ? this.userInfo.status : '+ 状态')
            .fontColor(Color.Grey)
            .margin({ top: 20 })
            .padding({ left: 8, right: 8 })
            .height(25)
            .fontSize(15)
            .borderRadius(20)
            .height(26)
            .textAlign(TextAlign.Center)
            .borderWidth(0.7)
            .borderColor('#666')
            .backgroundColor(Color.White)
        }
        .margin({ top: 40 })
        .alignItems(HorizontalAlign.Start)

        Blank()
        Image($r('app.media.ic_qrcode'))
          .width(16)
          .height(16)
          .margin({ top: 38, right: 20 })


        Image($r("app.media.ic_more"))
          .width(9)
          .height(16.364)
          .margin({ top: 38, right: 15 })

      }.width("100%")
      .height(203)
      .backgroundColor(Color.White)
      .padding({ top: WindowManager.statusBarHeight })
      .onClick(() => {
        router.pushUrl({ url: 'pages/qrcode/MyQrCodePage' })
      })

      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(10)
      ListMenuItem({
        title: "服务",
        iconSrc: $r('app.media.ic_service')
      })
      .onClick(unDevTip)
      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(10)
      ListMenuItem({
        title: "收藏",
        iconSrc: $r("app.media.ic_collect")
      })
        .onClick(() => {
          router.pushUrl({ url: 'pages/favorite/Favorite' })
        })

      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(1)
      ListMenuItem({
        title: "朋友圈",
        iconSrc: $r('app.media.ic_moment_pic')
      })
      .onClick(unDevTip)
      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(1)
      ListMenuItem({
        title: "卡包",
        iconSrc: $r('app.media.ic_card_pkg')
      })
      .onClick(unDevTip)
      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(1)
      ListMenuItem({
        title: "表情",
        iconSrc: $r('app.media.ic_face_icon')
      })
      .onClick(unDevTip)
      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(10)
      Row() {
        Image($r('app.media.ic_setting'))
          .width(25)
          .height(25)
          .margin({ right: 18 })
        Text("设置")
          .fontColor(Color.Black)
          .fontSize(16)
          .margin({ right: 10 })
        Blank()
        Image($r("app.media.ic_more"))
          .width(9)
          .height(16.364)
      }
      .width("100%")
      .height(60)
      .backgroundColor("#fff")
      .padding({ left: 15, right: 15 })
      .onClick(() => {
        console.log('点击了设置选项')
        router.pushUrl({
          url: 'pages/mine/SettingPage',
          params: {
            name: '设置'
          }
        }, (err) => {
          if (err) {
            console.log('路由跳转失败:', err)
            Toast.show('跳转失败: ' + err.message)
          } else {
            console.log('路由跳转成功')
          }
        })
      })
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")

  }
}

const unDevTip = () => {
  Toast.show("二级页面正在开发中...")
}
