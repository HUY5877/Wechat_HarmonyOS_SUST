import router from '@ohos.router'
import ListMenuItem from '../../component/ListMenuItem'
import { PhotoPickerUtils } from '../../utils/PhotoPickerUtils'
import WindowManager from '../../utils/WindowManager'
import { Toast } from '../../utils/Toast'
import { getUserInfo, logout } from '../../utils/LoginApi'
import promptAction from '@ohos.promptAction'
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
  @State imgPath: Resource | string = $r('app.media.ic_user_head1')
  @StorageProp('userId') userId: string = '未登录'
  @State userName: string = '加载中...'
  @State userAccount: string = '加载中...'
  @State userStatus: string = ''
  private refreshTimer: number = 0

  aboutToAppear() {
    if (this.userId !== '未登录') {
      this.fetchUserInfo()
      // 每1秒自动刷新一次用户信息
      this.refreshTimer = setInterval(() => {
        console.info('[Mine] 定时刷新用户信息')
        this.fetchUserInfo()
      }, 1000)
    } else {
      this.userName = '未登录'
      this.userAccount = '-'
    }
  }

  aboutToDisappear() {
    // 清除定时器，避免内存泄漏
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
      this.refreshTimer = 0
      console.info('[Mine] 清除刷新定时器')
    }
  }

  onPageShow() {
    // 每次页面显示时都重新获取用户信息，确保数据是最新的
    if (this.userId !== '未登录') {
      console.info('[Mine] 页面显示，开始获取最新用户信息')
      this.fetchUserInfo()
    }
  }

  // 当页面从后台返回时也重新获取用户信息
  onForeground() {
    if (this.userId !== '未登录') {
      console.info('[Mine] 页面从后台返回，开始获取最新用户信息')
      this.fetchUserInfo()
    }
  }

  private async fetchUserInfo() {
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
      console.info(`[Mine] 准备获取用户信息，userId: ${this.userId}`)
      const res = await getUserInfo(this.userId)
      console.info(`[Mine] 获取用户信息结果: ${JSON.stringify(res)}`)
      if (res && res.success && res.data) {
        this.userName = res.data.name || '无名氏'
        this.userAccount = res.data.account || '未知账号'
        this.userStatus = ''

        // 获取后端的头像ID
        const avatarId = String(res.data.profile_picture_id || '0')
        console.info(`[Mine] 尝试加载头像ID: ${avatarId}`)
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
        this.userStatus = ''
      }
    } catch (err) {
      console.error(`[Mine] 获取用户信息异常: ${JSON.stringify(err)}`)
      this.userName = '未知用户'
      this.userAccount = '-'
      this.userStatus = ''
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
          Text(`昵称：${this.userName}`)
            .fontColor(Color.Black)
            .fontSize(16)
            .fontWeight(700)

          Text(`微信号：${this.userInfo.account || "wx_023021"}`)
            .fontColor(Color.Grey)
            .fontSize(16)
            .margin({ top: 15 })

          Text(this.userStatus || '请选择状态')
            .fontColor(this.userStatus ? Color.Black : '#999999')
            .margin({ top: 15 })
            .padding({ left: 10, right: 10 })
            .height(30)
            .fontSize(15)
            .borderRadius(20)
            .textAlign(TextAlign.Center)
            .borderWidth(1)
            .borderColor('#07c160')
            .backgroundColor('#f0f9ff')
            .onClick(() => {
              router.pushUrl({ url: 'pages/mine/PersonalInfoPage' })
            })
        }
        .margin({ top: 40 })
        .alignItems(HorizontalAlign.Start)

        Blank()

        Image($r('app.media.ic_qrcode'))
          .width(18)
          .height(18)
          .margin({ right: 15 })
          .onClick(() => { router.pushUrl({ url: 'pages/qrcode/MyQrCodePage' }) })

        Image($r("app.media.ic_more"))
          .width(9)
          .height(16.364)
          .margin({ top: 38, right: 15 })

      }
      .width("100%")
      .padding({ top: WindowManager.statusBarHeight + 40, bottom: 40 })
      .backgroundColor(Color.White)
      .onClick(() => {
        router.pushUrl({ url: 'pages/mine/PersonalInfoPage' })
      })

      Divider().color("#f3f3f3").strokeWidth(10)
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
        iconSrc: $r('app.media.ic_service'),
        clickHandler: () => {
          console.log('点击了服务选项')
          router.pushUrl({ url: 'pages/mine/ServicePage' })
        }
      })
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
      ListMenuItem({ title: "朋友圈", iconSrc: $r('app.media.ic_moment_pic') })
        .onClick(() => {
          // 暂时跳转跳转发现页，直到朋友圈详情页开发完成
          Toast.show("更多动态请前往'发现'页查看")
        })

      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(1)
        .lineCap(LineCapStyle.Round)
      ListMenuItem({
        title: "朋友圈",
        iconSrc: $r('app.media.ic_moment_pic')
      })
        .onClick(() => {
          router.pushUrl({ url: 'pages/moments/MomentsPage' })
        })
      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(1)
        .lineCap(LineCapStyle.Round)
      ListMenuItem({
        title: "卡包",
        iconSrc: $r('app.media.ic_card_pkg')
      }).onClick(() => { Toast.show('二级页面正在开发中...') })
      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(1)
        .lineCap(LineCapStyle.Round)
      ListMenuItem({
        title: "表情",
        iconSrc: $r('app.media.ic_face_icon')
      }).onClick(() => { Toast.show('二级页面正在开发中...') })
      Divider()
        .vertical(false)
        .color("#f3f3f3")
        .strokeWidth(10)
        .lineCap(LineCapStyle.Round)
      ListMenuItem({
        title: "设置",
        iconSrc: $r('app.media.ic_setting')
      })
        .onClick(() => { Toast.show('二级页面正在开发中...') })

      // 退出登录按钮
      if (this.userId !== '未登录') {
        Button("退出登录")
          .width('90%')
          .height(45)
          .margin({ top: 30, bottom: 20 })
          .backgroundColor('#ff4d4f')
          .fontColor(Color.White)
          .fontSize(16)
          .borderRadius(8)
          .onClick(() => {
            this.showLogoutConfirm();
          })
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")


  }

  /**
   * 显示退出登录确认对话框
   */
  private showLogoutConfirm() {
    promptAction.showDialog({
      message: "确定要退出登录吗？",
      buttons: [
        {
          text: "取消",
          color: "#666666"
        },
        {
          text: "确定",
          color: "#ff4d4f"
        }
      ]
    }).then(result => {
      if (result.index === 1) {
        // 用户点击了确定
        this.performLogout();
      }
    });
  }

  /**
   * 执行退出登录操作
   */
  private performLogout() {
    try {
      logout();
      Toast.show("退出登录成功");
      // 跳转到登录页面
      router.replaceUrl({ url: 'pages/log_in/Log_in' });
    } catch (error) {
      console.error('退出登录失败:', error);
      Toast.show("退出登录失败");
    }
  }
}

const unDevTip = () => {
  Toast.show("二级页面正在开发中...")
}
