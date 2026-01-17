# frozen_string_literal: true

namespace :friendships do
  desc 'Create accepted friendships between all existing users'
  task create_all_friendships: :environment do
    puts 'Starting friendship creation task...'

    users = User.all.to_a
    total_users = users.count

    if total_users < 2
      puts "Not enough users to create friendships. Found #{total_users} user(s)."
      next
    end

    puts "Found #{total_users} users"

    created_count = 0
    skipped_count = 0
    error_count = 0

    ActiveRecord::Base.transaction do
      # Generate all unique pairs (avoid duplicates and self-friendships)
      users.combination(2).each do |user_a, user_b|
        # Check if friendship already exists in either direction
        existing = Friendship.where(
          requester_id: user_a.id,
          addressee_id: user_b.id
        ).or(
          Friendship.where(
            requester_id: user_b.id,
            addressee_id: user_a.id
          )
        ).exists?

        if existing
          skipped_count += 1
          next
        end

        begin
          Friendship.create!(
            requester_id: user_a.id,
            addressee_id: user_b.id,
            status: :accepted
          )
          created_count += 1

          # Print progress every 100 friendships
          puts "Created #{created_count} friendships so far..." if (created_count % 100).zero?
        rescue ActiveRecord::RecordInvalid => e
          error_count += 1
          puts "Error creating friendship between User #{user_a.id} and User #{user_b.id}: #{e.message}"
        end
      end
    end

    puts "\n#{'=' * 60}"
    puts 'Friendship creation task completed!'
    puts '=' * 60
    puts "Total users: #{total_users}"
    puts "Friendships created: #{created_count}"
    puts "Friendships skipped (already exist): #{skipped_count}"
    puts "Errors: #{error_count}"

    # Calculate total possible friendships for n users: n * (n - 1) / 2
    total_possible = (total_users * (total_users - 1)) / 2
    puts "Total possible friendships: #{total_possible}"
    puts '=' * 60
  rescue StandardError => e
    puts "\nTask failed with error: #{e.message}"
    puts e.backtrace.first(5).join("\n")
    raise
  end
end
