import router from '@ohos.router'
import ListMenuItem from '../../component/ListMenuItem'
import { PhotoPickerUtils } from '../../utils/PhotoPickerUtils'
import WindowManager from '../../utils/WindowManager'
import { Toast } from '../../utils/Toast'
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
  @State imgPath: string = ""
  @State userInfo: UserInfo = {
    user_id: "",
    account: "",
    name: "亚瑟王",
    status: "",
    profile_picture_id: ""
  }

  async aboutToAppear() {
    try {
      // 这里使用默认的user_id，实际应用中应该从登录信息中获取
      const userId = "1";
      const result = await ApiService.getPersonalHomepage(userId);
      if (result) {
        // 逐个属性赋值，避免结构类型问题
        this.userInfo.user_id = result.user_id || "";
        this.userInfo.account = result.account || "";
        this.userInfo.name = result.name || "亚瑟王";
        this.userInfo.status = result.status || "";
        this.userInfo.profile_picture_id = result.profile_picture_id || "";
      }
    } catch (error) {
      console.error('获取用户信息失败:', error);
      Toast.show('获取用户信息失败');
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
          Text(this.userInfo.name || "亚瑟王")
            .fontColor(Color.Black)
            .fontSize(26)
            .fontWeight(700)

          Text(`微信号：${this.userInfo.account || "wx_023021"}`)
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
      .onClick(unDevTip)

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
