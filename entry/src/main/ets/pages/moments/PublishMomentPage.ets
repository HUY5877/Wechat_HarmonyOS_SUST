import router from '@ohos.router';
import Toolbar from '../../component/Toolbar';
import { MomentsApi } from '../../utils/MomentsApi';
import prompt from '@ohos.promptAction';
import WindowManager from '../../utils/WindowManager';

@Entry
@Component
struct PublishMomentPage {
  @State content: string = "";
  @State isPublishing: boolean = false;

  async publish() {
    if (!this.content.trim()) {
      prompt.showToast({ message: "内容不能为空", duration: 2000 });
      return;
    }
    this.isPublishing = true;
    try {
      const success = await MomentsApi.addMoment(MomentsApi.getCurrentUserId(), this.content);
      if (success) {
        prompt.showToast({ message: "发布成功", duration: 2000 });
        router.back();
      } else {
        prompt.showToast({ message: "发布失败", duration: 2000 });
      }
    } catch (e) {
      console.error('Publish moment error:', e);
      prompt.showToast({ message: "网络错误", duration: 2000 });
    } finally {
      this.isPublishing = false;
    }
  }

  build() {
    Column() {
      // 头部
      Row() {
        Text("取消")
          .fontSize(16)
          .fontColor(Color.Black)
          .margin({ left: 15 })
          .padding(10) // 增加点击区域
          .onClick(() => {
            router.back();
          })

        Blank()

        Button("发表")
          .backgroundColor(this.content.trim().length > 0 ? '#07c160' : '#e2e2e2')
          .fontColor(this.content.trim().length > 0 ? Color.White : '#a0a0a0')
          .fontSize(14)
          .width(60)
          .height(30)
          .margin({ right: 15 })
          .onClick(() => {
            if (!this.isPublishing && this.content.trim().length > 0) {
              this.publish();
            }
          })
      }
      .width('100%')
      .backgroundColor("#f1f1f1")
      .alignItems(VerticalAlign.Center)
      .padding({ top: WindowManager.statusBarHeight + 10, bottom: 10, left: 0, right: 0 }) // 适配沉浸式状态栏，防止顶部遮挡，并增加上边距
      .expandSafeArea([SafeAreaType.KEYBOARD]) // 避免键盘遮挡
      .zIndex(999)

      // 文本输入区
      TextArea({ placeholder: "这一刻的想法..." })
        .width('100%')
        .height(150)
        .backgroundColor(Color.White)
        .fontSize(16)
        .padding(15)
        .onChange((value: string) => {
          this.content = value;
        })
        
      if (this.isPublishing) {
        LoadingProgress().width(40).height(40).margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
