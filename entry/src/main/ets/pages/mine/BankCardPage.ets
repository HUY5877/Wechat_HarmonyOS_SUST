import router from '@ohos.router';
import WindowManager from '../../utils/WindowManager';
import { Toast } from '../../utils/Toast';
import { queryBankCards, addBankCard, deleteBankCard, BankCardItem as ApiBankCardItem } from '../../utils/WalletApi';

@Component
struct BankCardItem {
  bankName: string = '';
  cardType: string = '储蓄卡';
  cardNumber: string = '';
  bgColor: string = '#C24D50'; // 默认红色背景
  showBalanceCheck: boolean = false;
  iconSrc: Resource | string = $r('app.media.ic_collect'); // 使用现有图标作为默认
  onDeleteClick?: () => void;

  build() {
    Column() {
      Row() {
        // 左侧图标区域
        Stack() {
          Circle({ width: 28, height: 28 })
            .fill(Color.White)
            .opacity(0.8)
          Image(this.iconSrc)
            .width(18)
            .height(18)
            .fillColor(this.bgColor) // 简单将图标颜色设为与背景相同以模拟镂空效果
        }
        .margin({ right: 12 })

        // 银行名称和类型
        Column() {
          Text(`${this.bankName}${this.cardType}`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
          
          if (this.showBalanceCheck) {
            Text('可查询余额')
              .fontSize(12)
              .fontColor(Color.White)
              .opacity(0.7)
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20 })

      // 卡号
      Row() {
        Text('····  ····  ····  ')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ top: 6 }) // 稍微调整小圆点对齐
        Text(this.cardNumber)
          .fontSize(20)
          .fontColor(Color.White)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ right: 20, bottom: 20 })
      .margin({ top: 12 })

    }
    .width('100%')
    .backgroundColor(this.bgColor)
    .borderRadius(8)
    .margin({ bottom: 12 })
    .onClick(() => {
      // 简单交互：点击卡片提示并可选择解绑
      if (this.onDeleteClick) {
        AlertDialog.show({
          title: '解绑银行卡',
          message: `确定要解绑尾号 ${this.cardNumber} 的${this.bankName}吗？`,
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '解绑',
            fontColor: '#FA5151',
            action: () => {
              this.onDeleteClick?.()
            }
          }
        })
      } else {
        Toast.show(`${this.bankName}详情未开发`)
      }
    })
  }
}

@CustomDialog
struct AddBankCardDialog {
  controller: CustomDialogController
  @State bankName: string = ''
  @State bankCard: string = ''
  onConfirm: (bankName: string, bankCard: string) => void = () => {}

  build() {
    Column() {
      Text('添加银行卡')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      TextInput({ placeholder: '请输入银行名称 (如: 工商银行)', text: this.bankName })
        .onChange((value: string) => {
          this.bankName = value
        })
        .margin({ left: 20, right: 20, bottom: 10 })

      TextInput({ placeholder: '请输入银行卡号', text: this.bankCard })
        .type(InputType.Number)
        .onChange((value: string) => {
          this.bankCard = value
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

        Button('添加')
          .backgroundColor(Color.Transparent)
          .fontColor('#07C160')
          .onClick(() => {
            if (!this.bankName.trim() || !this.bankCard.trim()) {
              Toast.show('请填写完整信息')
              return
            }
            this.controller.close()
            this.onConfirm(this.bankName.trim(), this.bankCard.trim())
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

class CardStyle {
  bgColor: string = '';
  iconSrc: Resource | string = '';
}

@Entry
@Component
export default struct BankCardPage {
  @StorageProp('userId') userId: string = '未登录'
  @State bankCards: ApiBankCardItem[] = []

  addCardDialogController: CustomDialogController = new CustomDialogController({
    builder: AddBankCardDialog({
      onConfirm: (bankName: string, bankCard: string) => {
        this.handleAddCard(bankName, bankCard)
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  aboutToAppear() {
    this.fetchBankCards()
  }

  onPageShow() {
    this.fetchBankCards()
  }

  async fetchBankCards() {
    if (this.userId === '未登录') return
    this.bankCards = await queryBankCards(this.userId)
  }

  async handleAddCard(bankName: string, bankCard: string) {
    Toast.show('正在添加...')
    const success = await addBankCard(this.userId, bankCard, bankName)
    if (success) {
      Toast.show('添加成功')
      this.fetchBankCards()
    } else {
      Toast.show('添加失败，请稍后再试')
    }
  }

  async handleDeleteCard(bankCard: string) {
    Toast.show('正在解绑...')
    const success = await deleteBankCard(this.userId, bankCard)
    if (success) {
      Toast.show('解绑成功')
      this.fetchBankCards()
    } else {
      Toast.show('解绑失败，请稍后再试')
    }
  }

  // 辅助方法：根据银行名称分配颜色和图标
  getCardStyle(bankName: string): CardStyle {
    const style = new CardStyle();
    if (bankName.includes('工商')) { style.bgColor = '#CA5A5E'; style.iconSrc = $r('app.media.ic_moment_pic'); return style; }
    if (bankName.includes('农')) { style.bgColor = '#216AB0'; style.iconSrc = $r('app.media.ic_location'); return style; }
    if (bankName.includes('中国')) { style.bgColor = '#C54A54'; style.iconSrc = $r('app.media.ic_card_pkg'); return style; }
    if (bankName.includes('建设')) { style.bgColor = '#1A5A98'; style.iconSrc = $r('app.media.ic_listen'); return style; }
    if (bankName.includes('招商')) { style.bgColor = '#CC4A54'; style.iconSrc = $r('app.media.ic_collect'); return style; }
    if (bankName.includes('邮政')) { style.bgColor = '#00833F'; style.iconSrc = $r('app.media.ic_moment'); return style; }
    style.bgColor = '#5A5A5A'; style.iconSrc = $r('app.media.ic_card_pkg'); return style; // 默认灰色
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back_black')) // 使用现有的黑色返回图标
          .width(24)
          .height(24)
          .colorFilter([
            -1, 0, 0, 0, 255, // R
            0, -1, 0, 0, 255, // G
            0, 0, -1, 0, 255, // B
            0, 0, 0, 1, 0     // A
          ]) // 通过颜色矩阵将黑色反转为白色
          .onClick(() => {
            router.pushUrl({ url: 'pages/mine/WalletPage' })
          })
        
        Text('银行卡')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 24 }) // 为了让标题真正居中，抵消左侧返回键的宽度
      }
      .width('100%')
      .height(50 + WindowManager.statusBarHeight)
      .padding({ left: 16, right: 16, top: WindowManager.statusBarHeight })
      .backgroundColor('#1A1A1A') // 页面背景色

      Scroll() {
        Column() {
          // 动态渲染银行卡列表
          ForEach(this.bankCards, (item: ApiBankCardItem) => {
            BankCardItem({
              bankName: item.bank,
              cardNumber: item.bankCard && item.bankCard.length >= 4 ? item.bankCard.slice(-4) : (item.bankCard || ''), // 只显示后4位
              bgColor: this.getCardStyle(item.bank).bgColor,
              showBalanceCheck: true,
              iconSrc: this.getCardStyle(item.bank).iconSrc,
              onDeleteClick: () => {
                this.handleDeleteCard(item.bankCard)
              }
            })
          })

          // 添加银行卡按钮
          Row() {
            Text('+')
              .fontSize(20)
              .fontColor(Color.White)
              .margin({ right: 12 })
            Text('添加银行卡')
              .fontSize(16)
              .fontColor(Color.White)
            Text('绑新卡送立减金')
              .fontSize(12)
              .fontColor('#DDA02B')
              .margin({ left: 8 })
          }
          .width('100%')
          .height(60)
          .padding({ left: 20 })
          .backgroundColor('#222222')
          .borderRadius(8)
          .onClick(() => {
            if (this.userId === '未登录') {
              Toast.show('请先登录')
              return
            }
            this.addCardDialogController.open()
          })

        }
        .padding({ left: 12, right: 12, top: 16, bottom: 40 })
        .constraintSize({ minHeight: '100%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部说明文字
      Text('本服务由财付通提供')
        .fontSize(12)
        .fontColor(Color.Grey)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A1A') // 整体深色背景
  }
}
