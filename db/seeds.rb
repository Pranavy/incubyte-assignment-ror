# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# JobTitle rows in the DB; Employee links via job_title_id (set through the association below).
intern = JobTitle.find_or_create_by!(title: "Intern")
associate_software_engineer = JobTitle.find_or_create_by!(title: "Associate Software Engineer")
software_engineer_1 = JobTitle.find_or_create_by!(title: "Software Engineer 1")
software_engineer_2 = JobTitle.find_or_create_by!(title: "Software Engineer 2")
senior_software_engineer = JobTitle.find_or_create_by!(title: "Senior Software Engineer")
engineering_manager = JobTitle.find_or_create_by!(title: "Engineering Manager")
product_manager = JobTitle.find_or_create_by!(title: "Product Manager")
ux_designer = JobTitle.find_or_create_by!(title: "UX Designer")
data_analyst = JobTitle.find_or_create_by!(title: "Data Analyst")
devops_engineer = JobTitle.find_or_create_by!(title: "DevOps Engineer")

# Diverse employees: all Countries::KEYS, every job title represented, varied salaries for dashboards.
[
  { first_name: "Priya", last_name: "Sharma", country: "IN", job_title: intern, salary: 36_000 },
  { first_name: "Arjun", last_name: "Iyer", country: "IN", job_title: intern, salary: 42_000 },
  { first_name: "Kavya", last_name: "Menon", country: "IN", job_title: associate_software_engineer, salary: 58_000 },
  { first_name: "Rohan", last_name: "Patel", country: "IN", job_title: software_engineer_1, salary: 72_000 },
  { first_name: "Ananya", last_name: "Reddy", country: "IN", job_title: software_engineer_1, salary: 78_500 },
  { first_name: "Vikram", last_name: "Singh", country: "IN", job_title: software_engineer_2, salary: 92_000 },
  { first_name: "Meera", last_name: "Nair", country: "IN", job_title: senior_software_engineer, salary: 115_000 },
  { first_name: "Siddharth", last_name: "Joshi", country: "IN", job_title: engineering_manager, salary: 145_000 },
  { first_name: "Deepa", last_name: "Krishnan", country: "IN", job_title: product_manager, salary: 132_000 },
  { first_name: "Rahul", last_name: "Banerjee", country: "IN", job_title: ux_designer, salary: 68_000 },
  { first_name: "Ishita", last_name: "Das", country: "IN", job_title: data_analyst, salary: 61_000 },
  { first_name: "Nikhil", last_name: "Verma", country: "IN", job_title: devops_engineer, salary: 88_000 },

  { first_name: "Alex", last_name: "Nguyen", country: "US", job_title: associate_software_engineer, salary: 88_000 },
  { first_name: "Taylor", last_name: "Brooks", country: "US", job_title: software_engineer_1, salary: 102_000 },
  { first_name: "Jordan", last_name: "Martinez", country: "US", job_title: software_engineer_1, salary: 108_500 },
  { first_name: "Casey", last_name: "Reed", country: "US", job_title: software_engineer_2, salary: 128_000 },
  { first_name: "Morgan", last_name: "Lee", country: "US", job_title: software_engineer_2, salary: 135_000 },
  { first_name: "Riley", last_name: "Washington", country: "US", job_title: senior_software_engineer, salary: 162_000 },
  { first_name: "Jamie", last_name: "Ortiz", country: "US", job_title: senior_software_engineer, salary: 171_000 },
  { first_name: "Avery", last_name: "Kim", country: "US", job_title: engineering_manager, salary: 195_000 },
  { first_name: "Quinn", last_name: "Foster", country: "US", job_title: product_manager, salary: 142_000 },
  { first_name: "Skyler", last_name: "Hayes", country: "US", job_title: ux_designer, salary: 95_000 },
  { first_name: "Drew", last_name: "Coleman", country: "US", job_title: data_analyst, salary: 89_000 },
  { first_name: "Reese", last_name: "Patel", country: "US", job_title: devops_engineer, salary: 124_000 },
  { first_name: "Blake", last_name: "Murphy", country: "US", job_title: intern, salary: 52_000 },

  { first_name: "Oliver", last_name: "Thompson", country: "GB", job_title: intern, salary: 28_000 },
  { first_name: "Charlotte", last_name: "Davies", country: "GB", job_title: associate_software_engineer, salary: 42_000 },
  { first_name: "Harry", last_name: "Williams", country: "GB", job_title: software_engineer_1, salary: 55_000 },
  { first_name: "Amelia", last_name: "Evans", country: "GB", job_title: software_engineer_2, salary: 68_000 },
  { first_name: "George", last_name: "Clarke", country: "GB", job_title: senior_software_engineer, salary: 82_000 },
  { first_name: "Isla", last_name: "Murphy", country: "GB", job_title: engineering_manager, salary: 95_000 },
  { first_name: "Jack", last_name: "Hughes", country: "GB", job_title: product_manager, salary: 71_000 },
  { first_name: "Poppy", last_name: "Green", country: "GB", job_title: ux_designer, salary: 44_000 },
  { first_name: "Freddie", last_name: "Bell", country: "GB", job_title: data_analyst, salary: 48_000 },
  { first_name: "Lily", last_name: "Ward", country: "GB", job_title: devops_engineer, salary: 62_000 },

  { first_name: "Lukas", last_name: "Hoffmann", country: "DE", job_title: intern, salary: 32_000 },
  { first_name: "Mia", last_name: "Weber", country: "DE", job_title: associate_software_engineer, salary: 54_000 },
  { first_name: "Felix", last_name: "Schneider", country: "DE", job_title: software_engineer_1, salary: 68_000 },
  { first_name: "Emma", last_name: "Fischer", country: "DE", job_title: software_engineer_2, salary: 82_000 },
  { first_name: "Jonas", last_name: "Wolf", country: "DE", job_title: senior_software_engineer, salary: 98_000 },
  { first_name: "Hannah", last_name: "Bauer", country: "DE", job_title: engineering_manager, salary: 118_000 },
  { first_name: "Leon", last_name: "Klein", country: "DE", job_title: product_manager, salary: 88_000 },
  { first_name: "Clara", last_name: "Neumann", country: "DE", job_title: ux_designer, salary: 52_000 },
  { first_name: "Noah", last_name: "Schwarz", country: "DE", job_title: data_analyst, salary: 58_000 },
  { first_name: "Lena", last_name: "Koch", country: "DE", job_title: devops_engineer, salary: 76_000 },

  { first_name: "Jack", last_name: "Wilson", country: "AU", job_title: intern, salary: 48_000 },
  { first_name: "Ruby", last_name: "Taylor", country: "AU", job_title: associate_software_engineer, salary: 72_000 },
  { first_name: "Liam", last_name: "Anderson", country: "AU", job_title: software_engineer_1, salary: 88_000 },
  { first_name: "Zoe", last_name: "Martin", country: "AU", job_title: software_engineer_2, salary: 102_000 },
  { first_name: "Noah", last_name: "Brown", country: "AU", job_title: senior_software_engineer, salary: 128_000 },
  { first_name: "Chloe", last_name: "White", country: "AU", job_title: engineering_manager, salary: 152_000 },
  { first_name: "Ethan", last_name: "Harris", country: "AU", job_title: product_manager, salary: 118_000 },
  { first_name: "Maya", last_name: "Clark", country: "AU", job_title: ux_designer, salary: 78_000 },
  { first_name: "Oscar", last_name: "Lewis", country: "AU", job_title: data_analyst, salary: 82_000 },
  { first_name: "Ella", last_name: "Walker", country: "AU", job_title: devops_engineer, salary: 96_000 }
].each do |row|
  Employee.find_or_create_by!(first_name: row[:first_name], last_name: row[:last_name]) do |employee|
    employee.country = row[:country]
    employee.job_title = row[:job_title]
    employee.salary = row[:salary]
  end
end
