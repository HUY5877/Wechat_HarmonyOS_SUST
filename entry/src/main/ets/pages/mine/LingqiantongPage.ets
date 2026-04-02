import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import { Toast } from '../../utils/Toast';
import { queryChangePass, transferToBalance, transferToLingqiantong, queryChange } from '../../utils/WalletApi';

@CustomDialog
struct LqtTransferDialog {
  controller: CustomDialogController
  title: string = '转账金额'
  confirmText: string = '确定'
  @State amountStr: string = ''
  onConfirm: (amount: number) => void = () => {}

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      TextInput({ placeholder: '请输入金额', text: this.amountStr })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.amountStr = value
        })
        .margin({ left: 20, right: 20, bottom: 20 })

      Row() {
        Button('取消')
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Grey)
          .onClick(() => {
            this.controller.close()
          })
          .layoutWeight(1)

        Button(this.confirmText)
          .backgroundColor(Color.Transparent)
          .fontColor('#F0A70A')
          .onClick(() => {
            const amount = parseFloat(this.amountStr)
            if (isNaN(amount) || amount <= 0) {
              Toast.show('请输入有效金额')
              return
            }
            this.controller.close()
            this.onConfirm(amount)
          })
          .layoutWeight(1)
      }
      .margin({ bottom: 10 })
    }
    .width('80%')
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}

@Entry
@Component
export default struct LingqiantongPage {
  @StorageProp('userId') userId: string = '未登录'
  @State balancePass: number = 0.00
  
  transferInDialogController: CustomDialogController = new CustomDialogController({
    builder: LqtTransferDialog({
      title: '转入零钱通 (从零钱)',
      confirmText: '转入',
      onConfirm: (amount: number) => {
        this.handleTransferIn(amount)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  transferOutDialogController: CustomDialogController = new CustomDialogController({
    builder: LqtTransferDialog({
      title: '转出到零钱',
      confirmText: '转出',
      onConfirm: (amount: number) => {
        this.handleTransferOut(amount)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  aboutToAppear() {
    this.fetchBalance()
  }

  onPageShow() {
    this.fetchBalance()
  }

  async fetchBalance() {
    if (this.userId === '未登录') return
    this.balancePass = await queryChangePass(this.userId)
  }

  async handleTransferIn(amount: number) {
    Toast.show('正在处理...')
    // Check balance first
    const balance = await queryChange(this.userId)
    if (balance < amount) {
      Toast.show('零钱余额不足')
      return
    }
    const success = await transferToLingqiantong(this.userId, amount)
    if (success) {
      Toast.show('转入成功')
      this.fetchBalance()
    } else {
      Toast.show('转入失败，请稍后再试')
    }
  }

  async handleTransferOut(amount: number) {
    if (this.balancePass < amount) {
      Toast.show('零钱通余额不足')
      return
    }
    Toast.show('正在处理...')
    const success = await transferToBalance(this.userId, amount)
    if (success) {
      Toast.show('转出成功')
      this.fetchBalance()
    } else {
      Toast.show('转出失败，请稍后再试')
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .onClick(() => {
            router.back()
          })
        
        Blank()
        
        Image($r('app.media.ic_more'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
      }
      .width('100%')
      .height(50 + WindowManager.statusBarHeight)
      .padding({ left: 16, right: 16, top: WindowManager.statusBarHeight })
      .backgroundColor('#F0A70A')

      Scroll() {
        Column() {
          // 头部信息
          Column() {
            Image($r('app.media.ic_moment_pic')) // 使用现有图标占位
              .width(40)
              .height(40)
              .margin({ bottom: 12 })
              .fillColor(Color.White)

            Text('零钱通')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .margin({ bottom: 8 })

            Row() {
              Image($r('app.media.ic_scan')) // 使用现有图标占位
                .width(14)
                .height(14)
                .fillColor(Color.White)
                .margin({ right: 4 })
              Text('资金安全保障中 >')
                .fontSize(12)
                .fontColor(Color.White)
                .opacity(0.8)
            }
          }
          .width('100%')
          .margin({ top: 20, bottom: 20 })

          // 主卡片
          Column() {
            // 卡片顶部提示
            Text('清明假期收益与转出规则 >')
              .fontSize(13)
              .fontColor('#F0A70A')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 12, bottom: 12 })
              .onClick(() => Toast.show('规则详情未开发'))
            
            Divider().color('#F5F5F5').strokeWidth(1)

            // 基金信息
            Row() {
              Image($r('app.media.ic_red_pkg')) // 占位图标
                .width(16)
                .height(16)
                .margin({ right: 6 })
              Text('由华夏基金管理 >')
                .fontSize(13)
                .fontColor(Color.Black)
            }
            .width('100%')
            .padding({ left: 16, top: 16 })
            .onClick(() => Toast.show('基金详情未开发'))

            // 账户余额
            Column() {
              Text('账户余额')
                .fontSize(14)
                .fontColor(Color.Black)
                .margin({ bottom: 8 })
              
              Row() {
                Text('¥ ')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.Black)
                Text(this.balancePass.toFixed(2))
                  .fontSize(40)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.Black)
              }
              .alignItems(VerticalAlign.Bottom)
              .margin({ bottom: 12 })

              Text('资金明细')
                .fontSize(13)
                .fontColor('#576B95')
                .onClick(() => Toast.show('资金明细未开发'))
            }
            .width('100%')
            .margin({ top: 30, bottom: 40 })

            // 收益信息
            Row() {
              Column() {
                Text('7日年化收益率 >')
                  .fontSize(12)
                  .fontColor(Color.Grey)
                  .margin({ bottom: 8 })
                Text('1.0770%')
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Color.Black)
                  .margin({ bottom: 6 })
                Text('华夏财富宝货币A')
                  .fontSize(10)
                  .fontColor(Color.Grey)
                  .backgroundColor('#F5F5F5')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(4)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => Toast.show('收益率详情未开发'))

              Divider().vertical(true).height(40).color('#E5E5E5')

              Column() {
                Text('累计收益 >')
                  .fontSize(12)
                  .fontColor(Color.Grey)
                  .margin({ bottom: 8 })
                Text('¥2.62')
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Color.Black)
                  .margin({ bottom: 6 })
                Text('昨日 ¥0.01')
                  .fontSize(10)
                  .fontColor(Color.Grey)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => Toast.show('累计收益详情未开发'))
            }
            .width('100%')
            .margin({ bottom: 40 })

            // 操作按钮
            Row() {
              Button('转出')
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#F5F5F5')
                .fontColor('#F0A70A')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ right: 10 })
                .onClick(() => {
                  if (this.userId === '未登录') {
                    Toast.show('请先登录')
                    return
                  }
                  this.transferOutDialogController.open()
                })
              
              Button('转入')
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#F0A70A')
                .fontColor(Color.White)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ left: 10 })
                .onClick(() => {
                  if (this.userId === '未登录') {
                    Toast.show('请先登录')
                    return
                  }
                  this.transferInDialogController.open()
                })
            }
            .width('100%')
            .padding({ left: 24, right: 24 })
            .margin({ bottom: 30 })

            // 定时转入
            Row() {
              Image($r('app.media.ic_listen')) // 占位图标
                .width(14)
                .height(14)
                .fillColor('#F0A70A')
                .margin({ right: 4 })
              Text('设置定时转入 >')
                .fontSize(13)
                .fontColor('#F0A70A')
            }
            .margin({ bottom: 24 })
            .onClick(() => Toast.show('定时转入未开发'))

          }
          .width('92%')
          .backgroundColor(Color.White)
          .borderRadius(8)

          // 更多产品标题
          Text('更多产品')
            .fontSize(13)
            .fontColor(Color.White)
            .opacity(0.8)
            .width('92%')
            .textAlign(TextAlign.Start)
            .margin({ top: 24, bottom: 8 })

          // 理财通卡片
          Column() {
            Row() {
              Image($r('app.media.ic_red_pkg')) // 占位图标
                .width(20)
                .height(20)
                .margin({ right: 8 })
              Text('理财通')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.Black)
              Blank()
              Image($r('app.media.ic_more'))
                .width(8)
                .height(14)
            }
            .width('100%')
            .padding(16)

            Divider().color('#F5F5F5').strokeWidth(1).margin({ left: 16, right: 16 })

            Row() {
              Column() {
                Text('追求更高收益')
                  .fontSize(15)
                  .fontColor(Color.Black)
                  .margin({ bottom: 4 })
                Text('特邀用户专享')
                  .fontSize(12)
                  .fontColor(Color.Grey)
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Text('null')
                .fontSize(15)
                .fontColor(Color.Black)
            }
            .width('100%')
            .padding(16)
          }
          .width('92%')
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 40 })
          .onClick(() => Toast.show('理财通未开发'))

        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0A70A')
  }
}
