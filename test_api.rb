require_relative 'config/environment'

puts "=" * 60
puts "共享自习室 API 功能测试"
puts "=" * 60

puts "\n1. 基础数据检查"
puts "-" * 60
puts "用户数: #{User.count}"
puts "区域数: #{Zone.count}"
puts "座位数: #{Seat.count}"
puts "预约数: #{Reservation.count}"
puts "交易数: #{Transaction.count}"

puts "\n2. 用户认证测试"
puts "-" * 60
user = User.find_by(phone: '13800000001')
puts "用户: #{user.name}, 余额: #{user.balance}元"
puts "Token: #{user.auth_token[0..20]}..."
puts "认证测试: #{user.authenticate('123456') ? '✓ 密码正确' : '✗ 密码错误'}"

puts "\n3. 座位管理测试"
puts "-" * 60
zone = Zone.find_by(name: '安静区 A')
puts "区域: #{zone.name}, 类型: #{zone.zone_type}, 价格: #{zone.hourly_rate}元/小时"
puts "座位数: #{zone.seats.count}, 可用座位(含显示器): #{zone.seats.with_monitor.count}"
seat = zone.seats.first
puts "示例座位: #{seat.seat_number}, 显示器: #{seat.has_monitor ? '有' : '无'}, 电源: #{seat.has_power_outlet ? '有' : '无'}"

puts "\n4. 预约系统测试"
puts "-" * 60
start_time = 2.hours.from_now
end_time = 4.hours.from_now
puts "预约时间段: #{start_time.strftime('%Y-%m-%d %H:%M')} ~ #{end_time.strftime('%Y-%m-%d %H:%M')}"
puts "座位可用? #{seat.available?(start_time, end_time) ? '✓ 可用' : '✗ 不可用'}"
puts "区域可用座位数: #{zone.available_seats(start_time, end_time).count}"

puts "\n5. 创建预约测试"
puts "-" * 60
puts "预约前余额: #{user.balance}元"
reservation = user.reservations.new(
  seat: seat,
  start_time: start_time,
  end_time: end_time
)
if reservation.save
  puts "✓ 预约成功!"
  puts "  预约ID: #{reservation.id}"
  puts "  时长: #{reservation.duration_hours}小时"
  puts "  费用: #{reservation.total_amount}元"
  puts "  状态: #{reservation.status}"
  puts "  预约后余额: #{user.reload.balance}元"
  puts "  交易记录: #{Transaction.last.description}"
else
  puts "✗ 预约失败: #{reservation.errors.full_messages.join(', ')}"
end

puts "\n6. 预约冲突测试"
puts "-" * 60
user2 = User.find_by(phone: '13800000002')
reservation2 = user2.reservations.new(
  seat: seat,
  start_time: start_time + 30.minutes,
  end_time: end_time + 30.minutes
)
if reservation2.save
  puts "✗ 错误: 预约应该冲突但成功了!"
else
  puts "✓ 冲突检测正常: #{reservation2.errors.full_messages.join(', ')}"
end

puts "\n7. 取消预约测试"
puts "-" * 60
if reservation.can_cancel?
  puts "取消前余额: #{user.balance}元"
  if reservation.cancel
    puts "✓ 取消成功!"
    puts "  状态: #{reservation.reload.status}"
    puts "  取消后余额: #{user.reload.balance}元"
    puts "  退款记录: #{Transaction.last.description}"
  else
    puts "✗ 取消失败"
  end
else
  puts "  此预约不可取消"
end

puts "\n8. 会员充值测试"
puts "-" * 60
puts "充值前余额: #{user.balance}元"
if user.recharge(100)
  puts "✓ 充值成功!"
  puts "  充值后余额: #{user.reload.balance}元"
  puts "  交易记录: #{Transaction.last.description}"
else
  puts "✗ 充值失败"
end

puts "\n9. 月度统计测试"
puts "-" * 60
stats = user.monthly_usage_stats(Date.current.year, Date.current.month)
puts "本月统计:"
puts "  使用时长: #{stats[:total_hours]}小时"
puts "  消费金额: #{stats[:total_spent]}元"
puts "  预约次数: #{stats[:reservation_count]}次"

puts "\n10. 排行榜测试"
puts "-" * 60
leaderboard = Transaction.monthly_leaderboard(Date.current.year, Date.current.month, 5)
puts "本月使用时长排行榜:"
leaderboard.each_with_index do |entry, i|
  puts "  #{i + 1}. #{entry.user_name}: #{entry.total_hours}小时, 消费#{entry.total_spent}元"
end

puts "\n" + "=" * 60
puts "所有测试完成!"
puts "=" * 60
