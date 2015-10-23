require 'mongoid'

module MongoidRecurring
  class Occurence
    include Mongoid::Document

    field :dtstart, type: DateTime
    field :dtend, type: DateTime

    attr_accessor :all_day

    embedded_in :schedule, class_name: 'MongoidRecurring::Occurence'

    validates :dtstart, presence: true
    validates :dtend, presence: true

    before_save :set_dtend
    before_save :adjust_dates_for_all_day

    # =====================================================================

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
