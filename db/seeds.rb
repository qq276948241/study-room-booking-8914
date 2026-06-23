User.transaction do
  admin = User.find_or_create_by!(phone: '13800000000') do |u|
    u.name = '管理员'
    u.password = 'admin123'
    u.password_confirmation = 'admin123'
    u.balance = 0
    u.is_admin = true
  end
  puts "创建管理员: #{admin.name}"

  users_data = [
    { name: '张三', phone: '13800000001', password: '123456', balance: 100 },
    { name: '李四', phone: '13800000002', password: '123456', balance: 200 },
    { name: '王五', phone: '13800000003', password: '123456', balance: 50 },
    { name: '赵六', phone: '13800000004', password: '123456', balance: 300 },
    { name: '钱七', phone: '13800000005', password: '123456', balance: 150 }
  ]

  users_data.each do |user_data|
    user = User.find_or_create_by!(phone: user_data[:phone]) do |u|
      u.name = user_data[:name]
      u.password = user_data[:password]
      u.password_confirmation = user_data[:password]
      u.balance = user_data[:balance]
      u.is_admin = false
    end
    puts "创建用户: #{user.name}, 余额: #{user.balance}"
  end
end

Zone.transaction do
  zones_data = [
    { name: '安静区 A', zone_type: 'quiet', hourly_rate: 10.0, description: '适合专注学习，保持安静' },
    { name: '安静区 B', zone_type: 'quiet', hourly_rate: 12.0, description: '靠窗位置，光线充足' },
    { name: '讨论区', zone_type: 'discussion', hourly_rate: 15.0, description: '小组讨论专用区域' },
    { name: 'VIP包间 1', zone_type: 'vip', hourly_rate: 50.0, description: '独立包间，配套齐全' },
    { name: 'VIP包间 2', zone_type: 'vip', hourly_rate: 60.0, description: '豪华包间，带投影仪' }
  ]

  zones_data.each do |zone_data|
    zone = Zone.find_or_create_by!(name: zone_data[:name]) do |z|
      z.zone_type = zone_data[:zone_type]
      z.hourly_rate = zone_data[:hourly_rate]
      z.description = zone_data[:description]
    end
    puts "创建区域: #{zone.name}, 类型: #{zone.zone_type}, 价格: #{zone.hourly_rate}/小时"

    if zone.seats.empty?
      seat_count = case zone.zone_type
                   when 'quiet' then 15
                   when 'discussion' then 8
                   when 'vip' then 1
                   end

      (1..seat_count).each do |i|
        seat = zone.seats.create!(
          seat_number: "#{zone.name[0]}#{sprintf('%02d', i)}",
          has_monitor: i <= 5,
          has_power_outlet: true,
          equipment_notes: i <= 5 ? '配备27寸4K显示器' : '标准座位',
          is_active: true
        )
        puts "  创建座位: #{seat.seat_number}, 显示器: #{seat.has_monitor}"
      end
    end
  end
end

puts "\n种子数据创建完成！"
puts "管理员账号: 13800000000 / admin123"
puts "普通用户账号: 13800000001-13800000005 / 123456"

