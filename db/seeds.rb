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

# Create a default project for development
if defined?(Project)
  project = Project.find_or_create_by!(platform_project_id: 'dev-project') do |p|
    p.name = 'Development'
    p.slug = 'development'
    p.environment = 'development'
  end
  puts "Project: #{project.name}"
end

# Create sample host groups
if defined?(HostGroup) && defined?(Project)
  project = Project.find_by!(platform_project_id: 'dev-project')

  HostGroup.find_or_create_by!(name: 'Web Servers', project: project) do |group|
    group.platform_project_id = project.platform_project_id
    group.description = 'Production web application servers'
    group.color = '#3B82F6'
    group.auto_assign_rules = [
      { field: 'role', operator: 'eq', value: 'web' }
    ]
  end

  HostGroup.find_or_create_by!(name: 'Workers', project: project) do |group|
    group.platform_project_id = project.platform_project_id
    group.description = 'Background job workers'
    group.color = '#10B981'
    group.auto_assign_rules = [
      { field: 'role', operator: 'eq', value: 'worker' }
    ]
  end

  HostGroup.find_or_create_by!(name: 'Databases', project: project) do |group|
    group.platform_project_id = project.platform_project_id
    group.description = 'Database servers'
    group.color = '#F59E0B'
    group.auto_assign_rules = [
      { field: 'role', operator: 'eq', value: 'database' }
    ]
  end

  puts "Created #{HostGroup.count} host groups"
end

puts "Seeding complete!"
