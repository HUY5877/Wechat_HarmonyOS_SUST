import window from '@ohos.window';

// 像素转换为视口单位
function px2vp(px: number): number {
  return px / 3;
}

export default class WindowManager {
  static statusBarHeight: number = 0
  static navBarHeight: number = 0

  /**
   * 沉浸式全屏(全屏屏幕，且显示状态栏、导航栏)
   * 同步方法：适合一次性定性设置沉浸式状态栏，不会动态调整。此方案大多数场景够用了，用户不会频繁显示|隐藏导航栏。
   * 仅在Ability使用(Ability全局，且初始化状态栏和导航栏的高度)，建议在 Ability --> onWindowStageCreate 中执行
   */
  static immerseFullScreenSync(windowStage: window.WindowStage) {
    // 同步获取一个主窗口实例
    let windowClass: window.Window = windowStage.getMainWindowSync()
    let area = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    let navBar = px2vp(area.bottomRect.height)
    area = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    // 状态栏高度
    const statusBar = px2vp(area.topRect.height)
    if (!navBar) {
      // 优先获取底部指示器导航栏高度，如果没有值得再尝试获取常规导航栏(鸿蒙5.0以下的传统底部三键导航栏)高度，两者显示是互斥的
      navBar = px2vp(area.bottomRect.height)
    }

    // 将值保存到静态变量中，以便后续使用
    WindowManager.statusBarHeight = statusBar
    WindowManager.navBarHeight = navBar

    // 设置窗口布局为沉浸式布局
    windowClass.setWindowLayoutFullScreen(true)
    windowClass.setWindowSystemBarEnable(["status", "navigation"])
    // 设置状态栏和导航栏的背景为透明
    windowClass.setWindowSystemBarProperties({
      navigationBarColor: "#00000000",
      statusBarColor: "#00000000",
      // navigationBarContentColor: "#FF000000",
      // statusBarContentColor: "#FF000000"
    })
  }
}
