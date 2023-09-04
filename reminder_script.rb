require 'csv'
require 'date'
require 'time'
require 'tzinfo'
require 'mail'
require 'pry'
require 'dotenv'
Dotenv.load('.env')

# Load CSV and send notifications for matches
def send_notifications(file)
  CSV.foreach(file, headers: true) do |row|
    match_time = DateTime.parse(row['Date']).to_time
    
    next if  DateTime.parse(row['Date']).to_date != Date.today


    time_until_match = match_time - Time.now
    # Send notification 10 minutes before the match
    if time_until_match > 0 #{&& time_until_match <= 600 }
      
      subject = "Upcoming Match Reminder"
      body = "Match Details:\n" \
      "Match Number: #{row['Match Number']}\n" \
      "Round Number: #{row['Round Number']}\n" \
      "Date: #{match_time.strftime('%A, %d %B %Y at %H:%M %p')}\n" \
      "Stadium: #{row['Location']}\n" \
      "Home Team: #{row['Home Team']}\n" \
      "Away Team: #{row['Away Team']}\n" \
      "Don't miss the excitement!"
      send_email(subject, body)
    end

    # Send morning notification
    if Time.now.hour == 8 && tc&& time_until_match <= 86400
      morning_subject = "Morning Match Reminder"
      morning_body = "Good morning! There's a match today at #{match_time_utc.strftime('%H:%M %p')}. Get ready to cheer!"
      send_email(morning_subject, morning_body)
    end
  end
end


def send_email(subject, body)  
  options = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => 'gmail.com',
    :user_name            => ENV['email'],
    :password             => ENV['password'],
    :authentication       => :login,
    :enable_starttls_auto => true
  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  mail = Mail.new do
    from    'sender@gmail.com'
    to      ENV['email_to']
    subject subject
    body    body
  end

  mail.deliver
end

# Specify the path to your CSV file
csv_file = './epl-fixtures-2023.csv'

# Run the script to send notifications
send_notifications(csv_file)
