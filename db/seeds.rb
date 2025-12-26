# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding Sentinel database..."

# Create sample host groups
if defined?(HostGroup)
  HostGroup.find_or_create_by!(name: 'Web Servers') do |group|
    group.description = 'Production web application servers'
    group.color = '#3B82F6'
    group.auto_assign_rules = [
      { field: 'role', operator: 'eq', value: 'web' }
    ]
  end

  HostGroup.find_or_create_by!(name: 'Workers') do |group|
    group.description = 'Background job workers'
    group.color = '#10B981'
    group.auto_assign_rules = [
      { field: 'role', operator: 'eq', value: 'worker' }
    ]
  end

  HostGroup.find_or_create_by!(name: 'Databases') do |group|
    group.description = 'Database servers'
    group.color = '#F59E0B'
    group.auto_assign_rules = [
      { field: 'role', operator: 'eq', value: 'database' }
    ]
  end

  puts "Created #{HostGroup.count} host groups"
end

puts "Seeding complete!"
