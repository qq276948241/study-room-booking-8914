require_relative 'config/environment'

# 找一个刚创建的预约
reservation = Reservation.last
puts "预约ID: #{reservation.id}"
puts "用户: #{reservation.user.name}"
puts "座位: #{reservation.seat.seat_number}"
puts "状态: #{reservation.status}"
puts "开始: #{reservation.start_time}"
puts "结束: #{reservation.end_time}"
puts "当前时间: #{Time.current}"
puts "end_time > Time.current: #{reservation.end_time > Time.current}"
puts "can_extend?: #{reservation.can_extend?}"
puts ""

# 尝试续约1小时
new_end = reservation.end_time + 1.hour
puts "尝试续约至: #{new_end}"
puts "new_end > end_time: #{new_end > reservation.end_time}"

reservation.errors.clear
result = reservation.extend_booking(new_end)
puts "结果: #{result}"
puts "错误: #{reservation.errors.full_messages.inspect}"
