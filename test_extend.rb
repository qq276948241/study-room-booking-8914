require_relative 'config/environment'

puts "=" * 60
puts "预约续约功能测试"
puts "=" * 60

user = User.find_by(phone: '13800000004')
# 找一个讨论区的座位，避免和之前测试冲突
zone = Zone.find_by(name: '讨论区')
seat = zone.seats.first

puts "\n用户: #{user.name}, 余额: #{user.balance}元"
puts "座位: #{zone.name} #{seat.seat_number}, 单价: #{zone.hourly_rate}元/小时"

start_time = 1.hour.from_now
end_time = 3.hours.from_now

puts "\n1. 创建初始预约（2小时）"
puts "-" * 60
reservation = user.reservations.new(
  seat: seat,
  start_time: start_time,
  end_time: end_time
)
if reservation.save
  puts "✓ 预约成功: ID=#{reservation.id}"
  puts "  时间: #{reservation.start_time.strftime('%H:%M')} ~ #{reservation.end_time.strftime('%H:%M')}"
  puts "  时长: #{reservation.duration_hours}小时"
  puts "  费用: #{reservation.total_amount}元"
  puts "  余额: #{user.reload.balance}元"
  puts "  可续约: #{reservation.can_extend?}"
else
  puts "✗ 预约失败: #{reservation.errors.full_messages.join(', ')}"
  exit
end

puts "\n2. 续约2小时"
puts "-" * 60
new_end_time = end_time + 2.hours
puts "  续约至: #{new_end_time.strftime('%H:%M')}"
puts "  续时时长: 2.0小时, 预计费用: #{(2 * zone.hourly_rate).round(2)}元"

if reservation.extend_booking(new_end_time)
  puts "✓ 续约成功!"
  reservation.reload
  puts "  新时间: #{reservation.start_time.strftime('%H:%M')} ~ #{reservation.end_time.strftime('%H:%M')}"
  puts "  总时长: #{reservation.duration_hours}小时"
  puts "  总费用: #{reservation.total_amount}元"
  puts "  余额: #{user.reload.balance}元"
  puts "  最近交易: #{Transaction.last.description}"
else
  puts "✗ 续约失败: #{reservation.errors.full_messages.join(', ')}"
end

puts "\n3. 冲突测试 - 另一用户约同座位续约时段"
puts "-" * 60
user2 = User.find_by(phone: '13800000003')
puts "  用户: #{user2.name}, 余额: #{user2.balance}元"

conflict_start = end_time + 30.minutes
conflict_end = new_end_time + 1.hour
reservation2 = user2.reservations.new(
  seat: seat,
  start_time: conflict_start,
  end_time: conflict_end
)
if reservation2.save
  puts "✗ 错误: 应该冲突但成功了!"
else
  puts "✓ 冲突检测正常: #{reservation2.errors.full_messages.join(', ')}"
end

puts "\n4. 续约时长超过24小时测试"
puts "-" * 60
too_long_end = new_end_time + 25.hours
reservation.errors.clear
if reservation.extend_booking(too_long_end)
  puts "✗ 错误: 应该拒绝但成功了!"
else
  puts "✓ 时长限制正常: #{reservation.errors.full_messages.join(', ')}"
end

puts "\n5. 余额不足测试"
puts "-" * 60
user3 = User.find_by(phone: '13800000005')
zone2 = Zone.find_by(name: 'VIP包间 1')
seat2 = zone2.seats.first
puts "  用户: #{user3.name}, 余额: #{user3.reload.balance}元"
reservation3 = user3.reservations.create!(
  seat: seat2,
  start_time: 2.hours.from_now,
  end_time: 3.hours.from_now
)
puts "  创建1小时预约成功, 扣费后余额: #{user3.reload.balance}元"

big_extend_end = reservation3.end_time + 100.hours
reservation3.errors.clear
if reservation3.extend_booking(big_extend_end)
  puts "✗ 错误: 应该余额不足但成功了!"
else
  puts "✓ 余额检测正常: #{reservation3.errors.full_messages.join(', ')}"
end

puts "\n" + "=" * 60
puts "续约功能测试完成!"
puts "=" * 60
