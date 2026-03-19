# Standup

一个很小的 macOS 菜单栏应用：

- 连续清醒 30 分钟后弹出站立提醒
- 提醒窗口会一直停留，直到手动确认后才重新计时
- 屏幕休眠、电脑休眠、锁屏或解锁后会重新开始计时
- 构建后产物是独立 `.app`，不需要靠终端常驻

## 开发与构建

```bash
swift build
./Scripts/build-app.sh
open build/Standup.app
```

`build-app.sh` 和 `build-dmg.sh` 默认只做本地开发构建；如果没有提供 `SIGNING_IDENTITY`，它们会退回 ad-hoc 签名，这种包在别的 Mac 上通常会被 Gatekeeper 拒绝。

## 正式发布 DMG

先准备好：

- `Developer ID Application` 证书
- `notarytool` 的 keychain profile

然后执行：

```bash
export SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)"
export NOTARYTOOL_KEYCHAIN_PROFILE="standup-notary"
./Scripts/release-dmg.sh
```

这会完成：

- 正式签名 `.app`
- 生成 `dmg`
- 提交 notarization
- staple 公证票据到最终 `dmg`

## 当前实现

- 菜单栏常驻图标，点击可看到剩余时间
- 到点弹出必须手动确认的浮动提醒窗
- 到点播放系统提示音并发送原生通知横幅
- 可手动“立即重新计时”
- 可手动“立即显示提醒”做测试

## 登录时启动

当前版本没有内置登录项注册。若你希望开机自启，可以先手动把 `build/Standup.app` 加到“系统设置 -> 通用 -> 登录项”。
