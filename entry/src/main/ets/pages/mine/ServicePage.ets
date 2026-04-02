import router from '@ohos.router'
import WindowManager from '../../utils/WindowManager'

interface ServiceItem {
  icon: Resource
  name: string
  iconColor: string
}

interface ServiceSection {
  title: string
  items: ServiceItem[]
}

@Entry
@Component
export default struct ServicePage {
  @State walletAmount: string = '¥999999999'

  // 金融理财
  private financeServices: ServiceItem[] = [
    { icon: $r('app.media.ic_card_pkg'), name: '信用卡还款', iconColor: '#07c160' },
    { icon: $r('app.media.ic_collect'), name: '理财通', iconColor: '#ff9500' },
    { icon: $r('app.media.ic_service'), name: '保险服务', iconColor: '#5856d6' }
  ]

  // 生活服务
  private lifeServices: ServiceItem[] = [
    { icon: $r('app.media.ic_game'), name: '手机充值', iconColor: '#07c160' },
    { icon: $r('app.media.ic_location'), name: '生活缴费', iconColor: '#5ac8fa' },
    { icon: $r('app.media.ic_red_pkg'), name: 'Q币充值', iconColor: '#ff3b30' },
    { icon: $r('app.media.ic_moment'), name: '城市服务', iconColor: '#34c759' },
    { icon: $r('app.media.ic_emoji_pack'), name: '腾讯公益', iconColor: '#ff3b30' },
    { icon: $r('app.media.ic_face_icon'), name: '医疗健康', iconColor: '#ff9500' }
  ]

  // 交通出行
  private travelServices: ServiceItem[] = [
    { icon: $r('app.media.ic_voice_call'), name: '出行服务', iconColor: '#007aff' },
    { icon: $r('app.media.ic_voice'), name: '火车票机票', iconColor: '#5856d6' },
    { icon: $r('app.media.ic_group_chat'), name: '滴滴出行', iconColor: '#ff9500' },
    { icon: $r('app.media.ic_miniprogram'), name: '酒店民宿', iconColor: '#34c759' }
  ]

  // 购物消费
  private shoppingServices: ServiceItem[] = [
    { icon: $r('app.media.ic_tag'), name: '品牌发现', iconColor: '#ff2d55' },
    { icon: $r('app.media.ic_collect'), name: '京东购物', iconColor: '#e4393c' },
    { icon: $r('app.media.ic_moment_pic'), name: '美团外卖', iconColor: '#ffc300' },
    { icon: $r('app.media.ic_camera'), name: '电影演出', iconColor: '#ff3b30' },
    { icon: $r('app.media.ic_shoot'), name: '美团团购', iconColor: '#ff9500' },
    { icon: $r('app.media.ic_hahaha'), name: '拼多多', iconColor: '#e02e24' },
    { icon: $r('app.media.ic_its_over'), name: '唯品会', iconColor: '#ff6b9d' },
    { icon: $r('app.media.ic_listen'), name: '转转二手', iconColor: '#34c759' }
  ]

  @Builder
  ServiceGrid(items: ServiceItem[]) {
    Grid() {
      ForEach(items, (item: ServiceItem) => {
        GridItem() {
          Column() {
            // 使用带颜色的背景圆圈来模拟不同服务的图标
            Column() {
              Image(item.icon)
                .width(24)
                .height(24)
                .fillColor(Color.White)
            }
            .width(44)
            .height(44)
            .backgroundColor(item.iconColor)
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 8 })

            Text(item.name)
              .fontSize(12)
              .fontColor('#333333')
          }
          .width('100%')
          .padding({ top: 15, bottom: 15 })
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .columnsGap(0)
    .rowsGap(0)
    .backgroundColor(Color.White)
  }

  @Builder
  ServiceSection(title: string, items: ServiceItem[]) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor('#999999')
        .width('100%')
        .padding({ left: 16, top: 12, bottom: 8 })

      this.ServiceGrid(items)
    }
    .width('100%')
    .backgroundColor('#f5f5f5')
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(22)
          .height(22)
          .margin({ left: 16 })
          .onClick(() => {
            router.back()
          })

        Text('服务')
          .fontSize(18)
          .fontColor(Color.Black)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Image($r('app.media.ic_more'))
          .width(22)
          .height(22)
          .margin({ right: 16 })
          .rotate({ angle: 90 })
      }
      .width('100%')
      .height(53)
      .backgroundColor('#f5f5f5')

      // 可滚动内容区域
      Scroll() {
        Column() {
          // 顶部绿色卡片区域
          Row() {
            // 收付款
            Column() {
              Image($r('app.media.ic_scan'))
                .width(32)
                .height(32)
                .fillColor(Color.White)
                .margin({ bottom: 8 })
              Text('收付款')
                .fontSize(16)
                .fontColor(Color.White)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              router.pushUrl({ url: 'pages/mine/PaymentPage' })
            })

            // 分隔线
            Column()
              .width(1)
              .height(50)
              .backgroundColor('rgba(255,255,255,0.3)')

            // 钱包
            Column() {
              Image($r('app.media.ic_card_pkg'))
                .width(32)
                .height(32)
                .fillColor(Color.White)
                .margin({ bottom: 8 })
              Text('钱包')
                .fontSize(16)
                .fontColor(Color.White)
              Text(this.walletAmount)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.8)')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              // 钱包点击事件
            })
          }
          .width('94%')
          .height(100)
          .backgroundColor('#07c160')
          .borderRadius(12)
          .margin({ top: 12, bottom: 12 })

          // 金融理财
          this.ServiceSection('金融理财', this.financeServices)

          // 生活服务
          this.ServiceSection('生活服务', this.lifeServices)

          // 交通出行
          this.ServiceSection('交通出行', this.travelServices)

          // 购物消费
          this.ServiceSection('购物消费', this.shoppingServices)

          // 底部留白
          Column()
            .width('100%')
            .height(20)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f5f5f5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
    .padding({ top: WindowManager.statusBarHeight })
  }
}
