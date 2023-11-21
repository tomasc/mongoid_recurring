require 'mongoid'
require 'mongoid_ice_cube_extension'

module MongoidRecurring
  module HasRecurringFields

    def self.included base
      base.extend ClassMethods
      base.class_eval do
        @@schedule_duration = 1.year
      end
    end

    # =====================================================================

    module ClassMethods
      def has_recurring_fields options={}
         @@schedule_duration = options[:schedule_duration] if options[:schedule_duration].present?

        field :dtstart, type: DateTime
        field :dtend, type: DateTime
        field :all_day, type: Mongoid::Boolean, default: false

        field :schedule, type: MongoidIceCubeExtension::Schedule
        field :schedule_dtend, type: DateTime

        # ---------------------------------------------------------------------

        embeds_many :occurrences, class_name: 'MongoidRecurring::Occurrence', order: :dtstart.asc

        validates :dtstart, presence: true

        before_save :expand_schedule_to_occurrences

        # ---------------------------------------------------------------------

        scope :for_datetime_range, -> (dtstart, dtend) {
          where({ occurrences: { "$elemMatch" => Occurrence.for_datetime_range(dtstart, dtend).selector } })
        }

        scope :from_datetime, -> (dtstart) {
          where( occurrences: { "$elemMatch" => Occurrence.from_datetime(dtstart).selector } )
        }

        scope :to_datetime, -> (dtend) {
          where( occurrences: { "$elemMatch" => Occurrence.to_datetime(dtend).selector } )
        }
      end
    end

    private # =============================================================

    def expand_schedule_to_occurrences
      self.occurrences = schedule.present? ? occurrences_from_schedule : occurrences_from_model
    end

    def occurrences_from_schedule
      schedule.occurrences(schedule_dtend || (schedule.start_time + @@schedule_duration)).collect { |o| MongoidRecurring::Occurrence.new( dtstart: o.start_time, dtend: o.end_time, all_day: all_day ) }
    end

    def occurrences_from_model
      [ MongoidRecurring::Occurrence.new( dtstart: dtstart, dtend: dtend, all_day: all_day ) ]
    end

  end
end
