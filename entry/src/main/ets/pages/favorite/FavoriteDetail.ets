import router from '@ohos.router'
import WindowManager from '../../utils/WindowManager'
import { FavoriteApi, FavoriteItem } from '../../utils/FavoriteApi'
import FavoriteApi, { FavoriteItem } from '../../utils/FavoriteApi'
import { Toast } from '../../utils/Toast'

@Entry
@Component
export default struct FavoriteDetail {
  @State record: FavoriteItem | null = null
  @StorageProp('userId') userId: string = ''
  @State isDeleting: boolean = false

  aboutToAppear() {
    const params = router.getParams() as Record<string, object>
    if (params && params['record']) {
      this.record = params['record'] as FavoriteItem
    } else {
      Toast.show('参数错误')
      router.back()
    }
  }

  private async doDelete() {
    if (!this.userId || !this.record) return
    this.isDeleting = true
    try {
      const res = await FavoriteApi.deleteFavorite(this.userId, this.record.message_id)
      if (res.result === 'success') {
        Toast.show('删除成功')
        router.back()
      } else {
        Toast.show(res.text || '删除失败')
      }
    } catch (e) {
      Toast.show('删除失败')
    } finally {
      this.isDeleting = false
    }
  }

  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .colorFilter(
            [
              0, 0, 0, 0, 7/255,   // R = 7
              0, 0, 0, 0, 193/255, // G = 193
              0, 0, 0, 0, 96/255,  // B = 96
              0, 0, 0, 1, 0        // A保持不变
            ]
          )
          .onClick(() => {
            router.back()
          })
        
        Text('详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#EDEDED')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          
        Text('删除')
          .fontSize(16)
          .fontColor('#FA5151')
          .onClick(() => {
            if (!this.isDeleting) {
              this.doDelete()
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 2. 内容区
      if (this.record) {
        Scroll() {
          Column() {
            Row() {
              Text(this.record.favorites_user_id ? `来自: ${this.record.favorites_user_id}` : '聊天记录')
                .fontSize(14)
                .fontColor('#8A8A8A')
              
              Blank()
              
              Text(this.record.created_at)
                .fontSize(14)
                .fontColor('#8A8A8A')
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 20, bottom: 10 })

            Text(this.record.content)
              .fontSize(16)
              .fontColor('#EDEDED')
              .width('100%')
              .padding({ left: 20, right: 20, top: 10, bottom: 20 })
          }
          .width('100%')
          .backgroundColor('#1A1A1A')
          .borderRadius(8)
          .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B0B0B')
    .padding({ top: WindowManager.statusBarHeight })
  }
}