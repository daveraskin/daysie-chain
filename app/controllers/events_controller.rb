class EventsController < ApplicationController
respond_to :html, :xml, :json


  def new
    @group = Group.find(params[:group_id])
    @event = Event.new
    render layout: false
  end


  def create
    # render :json => params
    @user = User.find(params[:user_id])
    group = Group.find(params[:group_id])
    if group.events << Event.create(event_params)
      redirect_to user_groups_path
    else
      flash[:danger] = "Please fill in all fields"
      redirect_to user_groups_path
    end
  end

  def edit
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:id])
    render layout: false
  end

  def show
    @user = User.find(params[:user_id])
    @group = Group.find(params[:group_id])
    @event = Event.find(params[:id])
  end

  def update
    user = current_user
    @event = Event.find(params[:id])
    @event.min = params[:event][:min]
    @event.max = params[:event][:max]
    @event.date = params[:event][:date]
    @event.day = params[:event][:day]
    @event.time = params[:event][:time]
    if @event.save
      user.attendances << @event.attendances.create(yes: false, no: false, maybe: false, count:0)
    else
      flash[:danger] = "Please fill in all required fields"
    end

    # put your own credentials here
    account_sid = ENV['TWILIO_KEY']
    auth_token = ENV['TWILIO_SECRET']

    p "I can access the account key: #{account_sid}"
    p "I can access the secret: #{auth_token}"
    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token
      p "i've gotten this far: 1"
    @event.group.memberships.each do |member|
      p "i've gotten this far: 2"
      date = @event.date.split("-")
      number = member.user.tel
      name = member.user.firstname
      @client.account.messages.create({
      :from => '+12073583459',
      :to => number,
      :body => "#{name}, you've been invited to #{@event.name} on #{@event.date}, #{@event.time}.  You down?  Reply 'yes #{@event.id}' or 'no #{@event.id}'"
      })
    end
    redirect_to user_groups_path
  end


  def textmessage
      response_array = params["Body"].split(" ")
      body = response_array[0]
      event = response_array[1].to_i
      number = params["From"].to_i
      user = User.find_by_tel(number)
      if user.attendances.find_by_event_id(event)[:invited] == true
        if body.downcase == 'yes'
          attendance = user.attendances.find_by_event_id(event)
          attendance[:yes] = true
          attendance[:maybe] = false
          attendance[:no] = false
          attendance.save
          p "this is the attendance #{attendance}"
          p "attendance, yes: #{attendance[:yes]}"
        elsif body.downcase == 'no'
          attendance = user.attendances.find_by_event_id(event)
          attendance[:yes] = false
          attendance[:maybe] = false
          attendance[:no] = true
          attendance.save
          p attendance
          p attendance[:yes]
        else
          render :json => params
        end
      else

      end
      p "testing"
  end

  private

  def event_params
    params.require(:event).permit(:name, :desc, :max, :loc, :date)
  end

end
