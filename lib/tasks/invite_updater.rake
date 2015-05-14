namespace :invite do

  desc "Checks whether scheduled events have passed, and resets all the attendance and event information if they have."

  task :update_invitations => :environment do
    current_time = Time.now.to_f
    Event.where(:active => true).each do |event|
      p "this event is : #{event.inspect}"
      event_date = Date.parse(event[:date]).strftime('%s').to_f
      event_time = Time.parse(event[:time]).to_f - Time.parse(event[:time]).beginning_of_day.to_f
      actual_time = event_date + event_time


      if (current_time - actual_time) > 0
        event[:date] = nil
        event[:time] = nil
        event[:min] = 1
        event[:max] = nil
        event[:active] = false
        event.save

        Attendance.where(:event_id => event[:id]).each do |user|
          user.destroy
        end
      end
    end
  end


end