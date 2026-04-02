import router from '@ohos.router'
import ListMenuItem from '../../component/ListMenuItem'

@Entry
@Preview
@Component
export default struct SettingPage {
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
        Text('设置')
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
          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          // 设置选项列表
          Column() {
            ListMenuItem({ 
              title: '账号与安全',
              clickHandler: () => {
                router.pushUrl({ url: 'pages/mine/AccountSecurityPage' })
              }
            })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '青少年模式' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '关怀模式' })
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          Column() {
            ListMenuItem({ title: '新消息通知' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '聊天' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '设备' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '通用' })
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          // 隐私分类
          Column() {
            Row() {
              Text('隐私')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 15, top: 10, bottom: 10 })
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          Column() {
            ListMenuItem({ title: '朋友权限' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '个人信息与权限' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '个人信息收集清单' })
            Divider()
              .vertical(false)
              .color('#f3f3f3')
              .strokeWidth(1)
            ListMenuItem({ title: '第三方信息共享清单' })
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          Column() {
            Row() {
              Text('插件')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 15, right: 5 })
              Text('输入法「语音转文字」全面升级')
                .fontSize(14)
                .fontColor('#666666')
              Blank()
              Image($r('app.media.ic_more'))
                .width(9)
                .height(16.364)
                .margin({ right: 15 })
            }
            .width('100%')
            .height(56)
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          Column() {
            Row() {
              Text('关于微信')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 15 })
              Blank()
              Row() {
                Text('•')
                  .fontSize(16)
                  .fontColor('#ff3b30')
                  .margin({ right: 5 })
                Image($r('app.media.ic_more'))
                  .width(9)
                  .height(16.364)
                  .margin({ right: 15 })
              }
            }
            .width('100%')
            .height(56)
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          Column() {
            ListMenuItem({ title: '帮助与反馈' })
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          Column() {
            Row() {
              Text('切换账号')
                .fontSize(16)
                .fontColor('#333333')
                .margin({ left: 15 })
              Blank()
            }
            .width('100%')
            .height(56)
          }
          .width('100%')
          .backgroundColor('#ffffff')

          Divider()
            .vertical(false)
            .color('#f3f3f3')
            .strokeWidth(10)

          Column() {
            Row() {
              Text('退出')
                .fontSize(16)
                .fontColor('#ff3b30')
                .margin({ left: 15 })
              Blank()
            }
            .width('100%')
            .height(56)
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
