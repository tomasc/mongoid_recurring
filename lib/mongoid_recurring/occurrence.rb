require 'mongoid'

module MongoidRecurring
  class Occurrence
    include Mongoid::Document

    field :dtstart, type: DateTime
    field :dtend, type: DateTime

    attr_accessor :all_day

    embedded_in :schedule, class_name: 'MongoidRecurring::Occurrence'

    validates :dtstart, presence: true
    validates :dtend, presence: true

    before_save :set_dtend
    before_save :adjust_dates_for_all_day

    # ---------------------------------------------------------------------

    scope :for_datetime_range, -> (dtstart, dtend) {
      dtstart = dtstart.beginning_of_day if dtstart.instance_of?(Date)
      dtend = dtend.end_of_day if dtend.instance_of?(Date)
      where( :dtstart.lte => dtend.to_datetime, :dtend.gte => dtstart.to_datetime )
    }

    scope :from_datetime, -> (dtstart) {
      dtstart = dtstart.beginning_of_day if dtstart.instance_of?(Date)
      where( :dtstart.gte => dtstart.to_datetime )
    }

    scope :to_datetime, -> (dtend) {
      dtend = dtend.end_of_day if dtend.instance_of?(Date)
      where( :dtend.lte => dtend.to_datetime )
    }

    # =====================================================================

    def <=> other
      sort_key <=> other.sort_key
    end

    def sort_key
      dtstart
    end

    def all_day?
      self.all_day == true
    end

    private # =============================================================

    def set_dtend
      self.dtend ||= dtstart
    end

    def adjust_dates_for_all_day
      return unless all_day?
      self.dtstart = dtstart.beginning_of_day
      self.dtend = dtend.end_of_day
    end
  end
end
