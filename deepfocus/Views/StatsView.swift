import SwiftUI
import Charts

struct StatsView: View {
    @Environment(FocusStore.self) private var store
    @Binding var currentView: AppView
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { currentView = .home }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppDesign.textSecondary)
                        .padding(12)
                }
                .buttonStyle(DuolingoGhostButtonStyle())
                
                Text("专注复盘")
                    .font(.system(.title3, design: .rounded)).bold()
                    .foregroundColor(AppDesign.textMain)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    chartSection
                    insightsSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }
    
    private var chartSection: some View {
        let weeklyData = store.getWeeklyStats()
        
        return VStack(alignment: .leading, spacing: 24) {
            Text("本周专注趋势")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(AppDesign.textSecondary)
            
            Chart {
                ForEach(weeklyData, id: \.name) { item in
                    BarMark(
                        x: .value("Day", item.name),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(
                        item.minutes > 60 ? AppDesign.green : AppDesign.blue
                    )
                    .cornerRadius(8)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.textSecondary)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 200)
        }
        .padding(24)
        .duolingoCard()
    }
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            // Highest Day Card
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppDesign.orange.opacity(0.1))
                        .frame(width: 56, height: 56)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppDesign.orange, lineWidth: 2))
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppDesign.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("最高专注日")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(AppDesign.textSecondary)
                        .fontWeight(.bold)
                    // Mock data or calculate from real
                    Text("周三 (180min)")
                        .font(.system(.title3, design: .rounded)).bold()
                        .foregroundColor(AppDesign.textMain)
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppDesign.textSecondary)
                    .font(.system(size: 16, weight: .bold))
            }
            .padding(20)
            .duolingoCard()
            
            // Insight Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppDesign.red.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppDesign.red)
                    }
                    Text("复盘建议")
                        .font(.system(.headline, design: .rounded)).bold()
                        .foregroundColor(AppDesign.textMain)
                }
                
                Text("本周「手机消息」分心占比 60%，建议在下一次专注时开启飞行模式或将手机置于视线之外。")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(AppDesign.textSecondary)
                    .lineSpacing(4)
            }
            .padding(20)
            .background(AppDesign.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppDesign.red, lineWidth: 2)
            )
            .shadow(color: AppDesign.red.opacity(0.3), radius: 0, x: 0, y: 4)
        }
    }
}
