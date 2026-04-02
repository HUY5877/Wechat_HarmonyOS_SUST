import router from '@ohos.router';
import Toolbar from '../../component/Toolbar';
import { MomentsApi, Moment } from '../../utils/MomentsApi';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct MomentsPage {
  @State momentsList: Moment[] = [];
  @State isLoading: boolean = true;
  private currentUserId: string = MomentsApi.getCurrentUserId();

  aboutToAppear() {
    this.loadMoments();
  }

  onPageShow() {
    // 每次显示页面时刷新
    this.loadMoments();
  }

  async loadMoments() {
    this.isLoading = true;
    try {
      const list: Moment[] = await MomentsApi.queryMoments(this.currentUserId);
      // 按照时间从最近到以前排序
      this.momentsList = (list || []).sort((a, b) => {
        return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
      });
    } catch (e) {
      console.error('Failed to load moments', e);
    } finally {
      this.isLoading = false;
    }
  }

  async deleteMoment(momentsId: string) {
    try {
      const success = await MomentsApi.deleteMoment(this.currentUserId, momentsId);
      if (success) {
        prompt.showToast({ message: '删除成功' });
        this.loadMoments();
      } else {
        prompt.showToast({ message: '删除失败' });
      }
    } catch (e) {
      console.error('Failed to delete moment', e);
    }
  }

  build() {
    Column() {
      Toolbar({
        title: "朋友圈",
        subIconSrc: $r('app.media.ic_camera'),
        onSubClick: () => {
          router.pushUrl({ url: 'pages/moments/PublishMomentPage' });
        }
      })

      if (this.isLoading && this.momentsList.length === 0) {
        LoadingProgress().width(50).height(50).margin({ top: 50 })
      } else if (this.momentsList.length === 0) {
        Text("暂无朋友圈动态")
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ top: 50 })
      } else {
        List() {
          ForEach(this.momentsList, (item: Moment) => {
            ListItem() {
              this.MomentItem(item)
            }
          }, (item: Moment) => item.moments_id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 1, color: '#f0f0f0', startMargin: 15, endMargin: 15 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder MomentItem(item: Moment) {
    Row() {
      Image($r('app.media.ic_user_head1')) // 默认头像
        .width(45)
        .height(45)
        .borderRadius(5)
        .margin({ right: 10, top: 5 })
        .alignSelf(ItemAlign.Start)

      Column() {
        Text(item.moments_user_id === this.currentUserId ? "我" : "用户" + item.moments_user_id)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#576b95') // 微信用户名颜色
          .margin({ bottom: 5 })
          .alignSelf(ItemAlign.Start)

        Text(item.moments_content || "")
          .fontSize(15)
          .fontColor(Color.Black)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 10 })

        Row() {
          Text(item.created_at ? item.created_at.substring(0, 16) : "")
            .fontSize(12)
            .fontColor(Color.Gray)

          Blank()

          if (item.moments_user_id === this.currentUserId) {
            Text("删除")
              .fontSize(12)
              .fontColor('#576b95')
              .onClick(() => {
                this.deleteMoment(item.moments_id)
              })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(15)
  }
}
