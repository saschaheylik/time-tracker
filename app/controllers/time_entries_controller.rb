require "csv"

class TimeEntriesController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include TimeEntriesHelper

  before_action :set_time_entry, only: [:show, :edit, :update, :destroy,
                                        :stop_time, :start_time, :continue_time]
  before_action :set_tasks, only: [:new, :edit, :create, :update]
  before_action :set_tag, only: [:report]
  before_action :set_date, only: [:index, :updates_all_time_entries]
  before_action :set_time_entries, only: [:index]
  before_action :set_overrun_entries,
                only: [:index, :updates_all_time_entries],
                if: -> { @date == Date.today }
  before_action -> { ensure_ownership(@tag) }, only: [:report]
  respond_to :html, :js

  def index
    # Tags for reporting
    @tags = current_user.admin ? Tag.all : Tag.where(user: current_user)
  end

  def show
    respond_with(@time_entry)
  end

  def new
    @time_entry = TimeEntry.new(running: true, start_time: Time.now)
    respond_with(@time_entry)
  end

  def edit; end

  def create
    logger.debug "Params: #{time_entry_params}"
    @time_entry = TimeEntry.new(time_entry_params)
    @time_entry.user = current_user
    @time_entry.start_time ||= Time.now

    if @time_entry.save
      redirect_to time_entries_path(date: @time_entry.start_time.to_date)
    else
      render "new"
    end
  end

  def continue_time
    prev_entry = @time_entry

    @time_entry = TimeEntry.new({
        :duration => 0,
        :start_time => Time.now,
        :running => true,
        :goal => prev_entry.goal,
        :result => prev_entry.result,
        :note => prev_entry.note,
        :task_id => prev_entry.task_id,
        :user_id => current_user.id
    })

    if @time_entry.save
      redirect_to time_entries_path
    else
      redirect_to time_entries_path, alert: "Failed to continue time entry"
    end
  end

  def start_time
    @time_entry.start_time = Time.now
    @time_entry.running = true
    if @time_entry.save
      redirect_to time_entries_path
    else
      redirect_to time_entries_path, alert: "Failed to start timer"
    end
  end

  def stop_time
    @time_entry.duration = @time_entry.real_duration
    @time_entry.running = false
    if @time_entry.save
      redirect_to time_entries_path
    else
      redirect_to time_entries_path, alert: "Failed to stop timer"
    end
  end

  def update
    if @time_entry.update(time_entry_params)
      redirect_to time_entries_path(date: @time_entry.start_time.to_date)
    else
      render "edit"
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to time_entries_path
  end

  def report
    redirect_to time_entries_path, alert: "No tag provided!" unless @tag

    @tasks = @tag.tasks.includes(:time_entries).order_last_touched
  end

  def export
    @time_entries = TimeEntry.includes(task: [:tags])
    @time_entries = @time_entries.where(user: current_user) unless current_user.admin?
    send_data @time_entries.to_csv
  end

  def updates_all_time_entries
    @time_entries = TimeEntry.includes(task: :tags).order(start_time: :desc)
    @time_entries = @time_entries.where(user: current_user) unless @admin

    time_entries_arr = []
    @time_entries.each do |t|
        row = [
            "#{t.start_time.to_date}&nbsp;&nbsp;#{t.start_time.strftime("%H:%M")} - #{t.end_time.strftime("%H:%M")}",
            "<b>#{task_with_tag_labels(t.task)}",
            t.goal,
            t.result,
            "<center>#{duration_display(t.real_duration)}</center>"
        ]
        row << entry.user.username if @admin
        row << "
            <div class=\"btn-container\">
              #{if t.running?
                stop_btn stop_time_time_entry_path(t)
              else
                start_btn continue_time_time_entry_path(t)
              end}
              #{ edit_btn edit_time_entry_path(t) }
              #{ delete_btn time_entry_path(t) }
            </div>
            "
        time_entries_arr << row
    end
    render :json => time_entries_arr
  end

  private

  def set_tasks
    @tasks = Task.includes(:time_entries, :tags)
    @tasks = @tasks.where(user: current_user) unless current_user.admin?
    @tasks = @tasks.active.order_todo
    if @time_entry.try(:task) && @tasks.exclude?(@time_entry.task)
      @tasks << @time_entry.task
    end
    @tasks = @tasks.map { |task| [task.explicit_name, task.id] }
  end

  def set_tag
    @tag = Tag.find(params[:tag_id])
  end

  def set_time_entry
    @time_entry = TimeEntry.find(params[:id])
  end

  def set_date
    # If there's a date, make sure all time entries are from that date
    # Default to today
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end

  def set_time_entries
    @time_entries = TimeEntry.includes(task: :tags).order(start_time: :desc).limit(50)
    @time_entries = @time_entries.where(user: current_user) unless @admin
  end

  def set_overrun_entries
    entries = TimeEntry.overrun
                       .includes(task: :tags)
                       .order(start_time: :desc)
    entries = entries.where(user: current_user) unless @admin
    @overrun_entries = entries.group_by { |e| e.start_time.to_date }
                              .sort_by { |date, _entries| date }
                              .to_h
  end

  def time_entry_params
    new_params = params.require(:time_entry).permit(:user_id, :task_id,
                                                    :duration, :start_time,
                                                    :note, :running, :goal,
                                                    :result)

    new_params = remove_stopped_elements(new_params) if new_params[:running] == "1"

    start_time = Time.american_date(new_params[:start_time])
    new_params[:start_time] = Time.zone.local_to_utc(start_time)

    new_params
  end

  def remove_stopped_elements(new_params)
    new_params.reject do |key, _|
      [:duration, :result].include? key.to_sym
    end
  end
end
