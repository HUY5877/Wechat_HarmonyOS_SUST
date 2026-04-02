
import router from '@ohos.router'
import WindowManager from '../../utils/WindowManager'
import { FavoriteApi, FavoriteItem, FavoriteSearchItem } from '../../utils/FavoriteApi'
import { Toast } from '../../utils/Toast'

// Alias for FavoriteItem to maintain compatibility
type FavoriteRecord = FavoriteItem;

@Entry
@Component
export default struct Favorite {
  @State searchText: string = ''
  @State favoriteList: FavoriteItem[] = []
  @State isLoading: boolean = true
  @StorageProp('userId') userId: string = ''
  @State isFirstLoad: boolean = true

  aboutToAppear() {
    if (this.userId) {
      this.loadFavorites()
    } else {
      this.isLoading = false
      Toast.show('用户未登录')
    }
  }

  onPageShow() {
    if (this.isFirstLoad) {
      this.isFirstLoad = false
      return
    }
    if (this.userId) {
      if (this.searchText.trim().length > 0) {
        this.doSearch(this.searchText)
      } else {
        this.loadFavorites()
      }
    }
  }

  private async loadFavorites() {
    this.isLoading = true
    try {
      const data = await FavoriteApi.getFavorites(this.userId)
      this.favoriteList = data
    } catch (e) {
      Toast.show('加载收藏失败')
    } finally {
      this.isLoading = false
    }
  }

  private async doSearch(text: string) {
    if (!this.userId) return
    
    this.isLoading = true
    try {
      if (text.trim().length === 0) {
        await this.loadFavorites()
        return
      }
      
      const data = await FavoriteApi.searchFavorites(this.userId, text)
      // Map search items to the common list format if needed
      this.favoriteList = data.map((item: FavoriteSearchItem): FavoriteItem => {
        return {
          favorites_id: item.favorites_id,
          favorites_user_id: '',
          message_id: item.message_id,
          content: item.favorites_content,
          created_at: item.created_at
        } as FavoriteItem
      })
    } catch (e) {
      Toast.show('搜索失败')
    } finally {
      this.isLoading = false
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
              0, 0, 0, 0, 237/255, // R
              0, 0, 0, 0, 237/255, // G
              0, 0, 0, 0, 237/255, // B
              0, 0, 0, 1, 0        // A
            ]
          )
          .onClick(() => {
            router.back()
          })
        
        Text('收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#EDEDED')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          
        Image($r('app.media.ic_add'))
          .width(24)
          .height(24)
          .fillColor('#EDEDED')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      // 2. 搜索框
      Row() {
        Image($r('app.media.ic_search'))
          .width(16)
          .height(16)
          .fillColor('#8A8A8A')
          .margin({ left: 12, right: 8 })
        
        TextInput({ placeholder: '搜索', text: this.searchText })
          .type(InputType.Normal)
          .placeholderColor('#8A8A8A')
          .fontColor('#EDEDED')
          .backgroundColor(Color.Transparent)
          .height(36)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value
          })
          .onSubmit(() => {
            this.doSearch(this.searchText)
          })
      }
      .width('92%')
      .height(36)
      .backgroundColor('#1A1A1A')
      .borderRadius(6)
      .margin({ top: 8, bottom: 16 })

      // 3. 分类标签 (只保留聊天记录)
      Row() {
        Text('聊天记录')
          .fontSize(14)
          .fontColor('#EDEDED')
      }
      .width('100%')
      .padding({ left: 20, bottom: 16 })
      .justifyContent(FlexAlign.Start)

      // 4. 收藏列表
      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontColor('#8A8A8A')
            .fontSize(14)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.favoriteList.length === 0) {
        Column() {
          Text('暂无收藏记录')
            .fontColor('#8A8A8A')
            .fontSize(14)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 1 }) {
          ForEach(this.favoriteList, (item: FavoriteRecord) => {
            ListItem() {
              Column() {
                Text(item.content)
                  .fontSize(16)
                  .fontColor('#EDEDED')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 12 })
                  .width('100%')

                Row() {
                  Text(item.favorites_user_id ? `来自: ${item.favorites_user_id}` : '聊天记录')
                    .fontSize(12)
                    .fontColor('#8A8A8A')
                  
                  Blank()
                  
                  Text(item.created_at)
                    .fontSize(12)
                    .fontColor('#8A8A8A')
                }
                .width('100%')
              }
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              .backgroundColor('#1A1A1A')
              .width('100%')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/favorite/FavoriteDetail',
                  params: {
                    record: item
                  }
                })
              })
            }
            .margin({ left: 12, right: 12, bottom: 8 })
          }, (item: FavoriteRecord) => item.favorites_id)
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B0B0B')
    .padding({ top: WindowManager.statusBarHeight })
  }
}
