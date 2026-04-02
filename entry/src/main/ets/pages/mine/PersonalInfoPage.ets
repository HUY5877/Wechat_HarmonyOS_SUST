import router from '@ohos.router'
import { PhotoPickerUtils } from '../../utils/PhotoPickerUtils'
import { Toast } from '../../utils/Toast'
import { getUserInfo, updateUserInfo } from '../../utils/LoginApi'
import AppStorage from '@ohos.app.ability.common'
import WindowManager from '../../utils/WindowManager'

@Entry
@Component
export default struct PersonalInfoPage {
  @State userId: string = AppStorage.get('userId') || '未登录'
  @State imgPath: Resource | string = ''
  @State userName: string = '加载中...'
  @State userAccount: string = '加载中...'
  @State userStatus: string = ''
  @State profilePictureId: string = '0'
  @State isLoading: boolean = true
  @State showStatusPicker: boolean = false
  @State statusOptions: string[] = ['开心', '不开心', '忙碌', '悠闲', '兴奋', '疲惫']

  aboutToAppear() {
    if (this.userId !== '未登录') {
      this.fetchUserInfo()
    }
  }

  private async fetchUserInfo() {
    this.isLoading = true
    try {
      const res = await getUserInfo(this.userId)
      if (res) {
        this.userName = res.name || '无名氏'
        this.userAccount = res.account || '未知账号'
        this.userStatus = res.status || ''
        this.profilePictureId = res.profile_picture_id || '0'
        
        // 根据数据库中的头像ID，映射到本地的资源图片
        if (this.profilePictureId === '0') {
          this.imgPath = $r('app.media.avatar_0')
        } else if (this.profilePictureId === '1') {
          this.imgPath = $r('app.media.avatar_1')
        } else {
          this.imgPath = $r('app.media.ic_user_head1')
        }
      } else {
        Toast.show('获取用户信息失败')
      }
    } catch (err) {
      console.error('获取用户信息异常:', err)
      Toast.show('请求用户信息失败')
    } finally {
      this.isLoading = false
    }
  }

  private async updateInfo() {
    if (this.isLoading) return
    
    this.isLoading = true
    try {
      const res = await updateUserInfo(this.userId, this.userName, this.userStatus, this.profilePictureId)
      if (res.success) {
        Toast.show('更新成功')
        router.back()
      } else {
        Toast.show(res.message || '更新失败')
      }
    } catch (err) {
      console.error('更新用户信息异常:', err)
      Toast.show('请求失败')
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      // 头部
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#07c160')
          .margin({ left: 15 })
          .padding(10)
          .onClick(() => {
            router.back()
          })

        Blank()

        Text('完成')
          .fontSize(16)
          .fontColor('#07c160')
          .margin({ right: 15 })
          .padding(10)
          .onClick(() => {
            this.updateInfo()
          })
      }
      .width('100%')
      .height(80)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)
      .padding({ top: 40 })

      Divider().strokeWidth(1).color('#f0f0f0')

      // 头像
      Row() {
        Text('头像')
          .fontSize(16)
          .fontColor(Color.Black)
          .width(80)
          .margin({ left: 15 })

        Image(this.imgPath || $r('app.media.ic_user_head1'))
          .width(60)
          .height(60)
          .borderRadius(8)
          .margin({ right: 15 })

        Image($r('app.media.ic_more'))
          .width(9)
          .height(16.364)
          .margin({ right: 15 })
      }
      .width('100%')
      .height(80)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)
      .onClick(() => {
        PhotoPickerUtils.openGallery(
          uri => {
            this.imgPath = uri
            // 这里可以根据实际情况更新 profilePictureId
            // 暂时使用随机值模拟
            this.profilePictureId = Math.floor(Math.random() * 2).toString()
          }, errMsg => {
            Toast.show(errMsg)
          }
        )
      })

      Divider().strokeWidth(1).color('#f0f0f0')

      // 昵称
      Row() {
        Text('昵称')
          .fontSize(16)
          .fontColor(Color.Black)
          .width(80)
          .margin({ left: 15 })

        TextInput({ placeholder: '请输入昵称', text: this.userName })
          .type(0)
          .placeholderColor('#999999')
          .fontColor(Color.Black)
          .fontSize(16)
          .layoutWeight(1)
          .margin({ right: 15 })
          .onChange(value => {
            this.userName = value
          })

        Image($r('app.media.ic_more'))
          .width(9)
          .height(16.364)
          .margin({ right: 15 })
      }
      .width('100%')
      .height(60)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)

      Divider().strokeWidth(1).color('#f0f0f0')

      // 微信号
      Row() {
        Text('微信号')
          .fontSize(16)
          .fontColor(Color.Black)
          .width(80)
          .margin({ left: 15 })

        Text(this.userAccount)
          .fontSize(16)
          .fontColor('#999999')
          .layoutWeight(1)
          .margin({ right: 15 })

        Image($r('app.media.ic_more'))
          .width(9)
          .height(16.364)
          .margin({ right: 15 })
      }
      .width('100%')
      .height(60)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)

      Divider().strokeWidth(1).color('#f0f0f0')

      // 状态
      Row() {
        Text('状态')
          .fontSize(16)
          .fontColor(Color.Black)
          .width(80)
          .margin({ left: 15 })

        Text(this.userStatus || '请选择状态')
          .fontSize(16)
          .fontColor(this.userStatus ? Color.Black : '#999999')
          .layoutWeight(1)
          .margin({ right: 15 })

        Image($r('app.media.ic_more'))
          .width(9)
          .height(16.364)
          .margin({ right: 15 })
      }
      .width('100%')
      .height(60)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)
      .onClick(() => {
        this.showStatusPicker = true
      })

      // 状态选择器
      if (this.showStatusPicker) {
        Column() {
          Blank()

          Column() {
            List() {
              ForEach(this.statusOptions, (option: string) => {
                ListItem() {
                  Row() {
                    Text(option)
                      .fontSize(16)
                      .fontColor(this.userStatus === option ? '#07c160' : Color.Black)
                      .layoutWeight(1)
                    if (this.userStatus === option) {
                      Text('✓')
                        .fontSize(16)
                        .fontColor('#07c160')
                        .margin({ right: 15 })
                    } else {
                      Blank().width(16).height(16).margin({ right: 15 })
                    }
                  }
                  .width('100%')
                  .height(50)
                  .padding({ left: 15 })
                  .onClick(() => {
                    this.userStatus = option
                  })
                }
              })
            }
            .width('100%')
            .height(300)
            .backgroundColor(Color.White)

            Divider().strokeWidth(1).color('#f0f0f0')

            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor('#07c160')
                .margin({ left: 15 })
                .padding(10)
                .onClick(() => {
                  this.showStatusPicker = false
                })

              Blank()

              Text('确定')
                .fontSize(16)
                .fontColor('#07c160')
                .margin({ right: 15 })
                .padding(10)
                .onClick(() => {
                  this.showStatusPicker = false
                })
            }
            .width('100%')
            .height(50)
            .alignItems(VerticalAlign.Center)
            .backgroundColor(Color.White)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .position({ x: 0, y: 0 })
        .zIndex(1000)
      }

      Divider().strokeWidth(1).color('#f0f0f0')

      // 更多选项
      Row() {
        Text('更多')
          .fontSize(16)
          .fontColor(Color.Black)
          .width(80)
          .margin({ left: 15 })

        Blank()

        Image($r('app.media.ic_more'))
          .width(9)
          .height(16.364)
          .margin({ right: 15 })
      }
      .width('100%')
      .height(60)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)

      Blank().layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}
