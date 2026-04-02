import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import { Toast } from '../../utils/Toast';
import { queryChange, transferToLingqiantong, transferToBalance } from '../../utils/WalletApi';

@CustomDialog
struct TransferDialog {
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
          .fontColor('#07C160')
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
export default struct BalancePage {
  @StorageProp('userId') userId: string = '未登录'
  @State balance: number = 0.00
  @State isRefreshing: boolean = false

  transferDialogController: CustomDialogController = new CustomDialogController({
    builder: TransferDialog({
      title: '转入零钱通',
      confirmText: '转入',
      onConfirm: (amount: number) => {
        this.handleTransferToLingqiantong(amount)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  rechargeDialogController: CustomDialogController = new CustomDialogController({
    builder: TransferDialog({
      title: '充值金额',
      confirmText: '充值',
      onConfirm: (amount: number) => {
        this.handleRecharge(amount)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  withdrawDialogController: CustomDialogController = new CustomDialogController({
    builder: TransferDialog({
      title: '提现金额',
      confirmText: '提现',
      onConfirm: (amount: number) => {
        this.handleWithdraw(amount)
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
    this.balance = await queryChange(this.userId)
  }

  async handleTransferToLingqiantong(amount: number) {
    if (this.balance < amount) {
      Toast.show('余额不足')
      return
    }
    
    Toast.show('正在处理...')
    const success = await transferToLingqiantong(this.userId, amount)
    if (success) {
      Toast.show('转入成功')
      this.fetchBalance()
    } else {
      Toast.show('转入失败，请稍后再试')
    }
  }

  async handleRecharge(amount: number) {
    Toast.show('正在处理...')
    // 充值：从零钱通转入零钱
    const success = await transferToBalance(this.userId, amount)
    if (success) {
      Toast.show('充值成功')
      this.fetchBalance()
    } else {
      Toast.show('充值失败，零钱通余额可能不足')
    }
  }

  async handleWithdraw(amount: number) {
    if (this.balance < amount) {
      Toast.show('余额不足')
      return
    }
    
    Toast.show('正在处理...')
    // 提现：从零钱转入零钱通
    const success = await transferToLingqiantong(this.userId, amount)
    if (success) {
      Toast.show('提现成功')
      this.fetchBalance()
    } else {
      Toast.show('提现失败，请稍后再试')
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back()
          })
        
        Blank()
        
        Text('零钱明细')
          .fontSize(16)
          .fontColor(Color.Black)
          .onClick(() => {
            Toast.show('该功能暂未开发')
          })
      }
      .width('100%')
      .height(50 + WindowManager.statusBarHeight)
      .padding({ left: 16, right: 16, top: WindowManager.statusBarHeight })
      .backgroundColor(Color.White)

      Column() {
        // 中间金额区域
        Image($r('app.media.ic_collect'))
          .width(60)
          .height(60)
          .margin({ top: 40, bottom: 20 })

        Text('我的零钱')
          .fontSize(16)
          .fontColor(Color.Black)
          .margin({ bottom: 16 })

        Row() {
          Text('¥ ')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
          Text(this.balance.toFixed(2))
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
        }
        .margin({ bottom: 24 })
        .alignItems(VerticalAlign.Bottom)

        Text('转入零钱通，能赚又能花 >')
          .fontSize(13)
          .fontColor('#DDA02B')
          .onClick(() => {
            if (this.userId === '未登录') {
              Toast.show('请先登录')
              return
            }
            this.transferDialogController.open()
          })

        // 按钮区域
        Button('充值')
          .width('100%')
          .height(48)
          .backgroundColor('#07C160')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 120, bottom: 16 })
          .onClick(() => {
            if (this.userId === '未登录') {
              Toast.show('请先登录')
              return
            }
            this.rechargeDialogController.open()
          })

        Button('提现')
          .width('100%')
          .height(48)
          .backgroundColor('#F2F2F2')
          .fontColor('#07C160')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            if (this.userId === '未登录') {
              Toast.show('请先登录')
              return
            }
            this.withdrawDialogController.open()
          })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
      .layoutWeight(1)

      // 底部说明文字
      Column() {
        Text('常见问题')
          .fontSize(12)
          .fontColor('#576B95')
          .margin({ bottom: 8 })
          .onClick(() => {
            Toast.show('该功能暂未开发')
          })
        
        Text('本服务由财付通提供')
          .fontSize(12)
          .fontColor(Color.Grey)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
