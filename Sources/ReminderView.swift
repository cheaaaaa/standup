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
                Text("\(controller.countdown) 秒")
                    .font(.system(size: 46, weight: .bold, design: .rounded))

                ProgressView(
                    value: Double(StandupController.reminderCountdown - controller.countdown),
                    total: Double(StandupController.reminderCountdown)
                )

                Text("倒计时结束后会自动关闭，并重新开始 30 分钟计时。")
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
