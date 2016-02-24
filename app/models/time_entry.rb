require 'csv'

class TimeEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  has_many :tags, through: :task

  validates_presence_of :task_id
  validates_presence_of :user_id

  def calculate_duration
    ((DateTime.now.to_i - self.start_time.to_i) / 60.0).round
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end
end
