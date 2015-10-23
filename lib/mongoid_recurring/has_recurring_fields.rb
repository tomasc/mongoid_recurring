require 'mongoid'
require 'mongoid_ice_cube_extension'

module MongoidRecurring
  module HasRecurringFields

    def self.included base

      base.extend ClassMethods
      base.class_eval do
        @@schedule_duration = 1.year
        attr_accessor :recurring_rules
      end
    end

    # =====================================================================

    module ClassMethods
      def has_recurring_fields options={}
         @@schedule_duration = options[:schedule_duration] if options[:schedule_duration].present?

        field :dtstart, type: DateTime
        field :dtend, type: DateTime
        field :all_day, type: Boolean, default: false

        field :schedule, type: MongoidIceCubeExtension::Schedule
        field :schedule_dtend, type: DateTime

        embeds_many :occurrences, class_name: 'MongoidRecurring::Occurence', order: :dtstart.asc

        validates :dtstart, presence: true

        before_save :expand_schedule_to_occurrences

        scope :for_datetime_range, -> (dtstart, dtend) {
          where( occurrences: { "$elemMatch" => { :dtstart.gte => dtstart.to_datetime, :dtend.lte => dtend.to_datetime } } )
        }
      end
    end

    private # =============================================================

    def expand_schedule_to_occurrences
      self.occurrences = schedule.present? ? occurrences_from_schedule : occurrences_from_model
    end

    def occurrences_from_schedule
      schedule.occurrences(schedule_dtend || (schedule.start_time + @@schedule_duration)).collect { |o| MongoidRecurring::Occurence.new( dtstart: o.start_time, dtend: o.end_time ) }
    end

    def occurrences_from_model
      [ MongoidRecurring::Occurence.new( dtstart: dtstart, dtend: dtend, all_day: all_day ) ]
    end

  end
end