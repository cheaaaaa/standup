import SwiftUI

struct ReminderView: View {
    @ObservedObject var controller: StandupController

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("该站起来活动一下了")
                .font(.system(size: 28, weight: .semibold))

            Text("你已经连续清醒 30 分钟。起来走动 1 到 2 分钟，再回来继续工作。")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Text("提醒会一直停留，直到你点击下面的按钮。")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Text("这样不会因为你刚好没看见窗口，30 秒后就自己消失。")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()

                Button("我已站立，重新计时") {
                    controller.acknowledgeReminder()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
