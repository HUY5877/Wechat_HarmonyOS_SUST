import router from '@ohos.router'
import ListMenuItem from '../../component/ListMenuItem'
import ApiService from '../../utils/ApiService'
import { Toast } from '../../utils/Toast'
import { UserInfo } from '../../utils/LoginApi'

@Entry
@Preview
@Component
export default struct AccountSecurityPage {
  @State userInfo: UserInfo = {
    user_id: "",
    account: "",
    name: "",
    status: "",
    profile_picture_id: ""
  }
  async aboutToAppear() {
    try {
      // 这里使用默认的user_id，实际应用中应该从登录信息中获取
      const userId = "1";
      const result = await ApiService.getPersonalHomepage(userId);
      if (result) {
        // Use Type Assertion safely or iterate keys if needed, but since we know the mapping:
        this.userInfo.user_id = result['user_id'] || "";
        this.userInfo.account = result['account'] || "";
        this.userInfo.name = result['name'] || "";
        this.userInfo.status = result['status'] || "";
        this.userInfo.profile_picture_id = result['profile_picture_id'] || "";
      }
    } catch (error) {
      console.error('获取用户信息失败:', error);
      Toast.show('获取用户信息失败');
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .margin({ left: 15, right: 15 })
          .onClick(() => {
            router.back()
          })
        Text('账号与安全')
          .fontSize(17)
          .fontWeight(500)
          .fontColor('#000000')
        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor('#ffffff')

      // 可滚动内容
      Scroll() {
        Column() {
          // 账号与安全选项列表
          Column() {
            Row() {
              Text('微信号')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 15 })
              Blank()
              Row() {
                Text(this.userInfo.account || 'wxid_e2cpu65ss5do22')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ right: 10 })
                Image($r('app.media.ic_more'))
                  .width(9)
                  .height(16.364)
                  .margin({ right: 15 })
              }
            }
            .width('100%')
            .height(56)
            .alignItems(VerticalAlign.Center)
            
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
              
            Row() {
              Text('手机号')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 15 })
              Blank()
              Row() {
                Text(this.userInfo.account || '183******73')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ right: 10 })
                Image($r('app.media.ic_more'))
                  .width(9)
                  .height(16.364)
                  .margin({ right: 15 })
              }
            }
            .width('100%')
            .height(56)
            .alignItems(VerticalAlign.Center)
            
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
              
            ListMenuItem({ title: '微信密码' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '声音锁' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '应急联系人' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '登录过的设备' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '更多安全设置' })
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          // 微信安全中心
          Column() {
            Row() {
              Text('微信安全中心')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 15, bottom: 8 })
            }
            .width('100%')
            
            Row() {
              Text('如果遇到账号被盗，无法登录等问题，可以前往安全中心')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ left: 15, right: 15, bottom: 15 })
              Blank()
              Image($r('app.media.ic_more'))
                .width(9)
                .height(16.364)
                .margin({ right: 15, bottom: 15 })
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Blank()
          Blank()
          Blank()
        }
        .width('100%')
      }
      .width('100%')
      .flexGrow(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}
