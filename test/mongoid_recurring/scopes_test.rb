require 'test_helper'

module MongoidRecurring
  describe 'scopes' do

    let(:today) { Date.parse('22/10/2015') }
    let(:start_date) { today - 1.month }
    let(:ice_cube_schedule) {
      IceCube::Schedule.new(start_date) do |s|
        s.add_recurrence_rule IceCube::Rule.weekly.count(10)
      end
    }

    let(:all_day_event) { MyDocument.new( dtstart: today, schedule: ice_cube_schedule, all_day: true ) }
    let(:regular_event) { MyDocument.new( dtstart: DateTime.parse('22/10/2015 13:30'), dtend: DateTime.parse('22/10/2015 15:30') ) }

    # =====================================================================

    describe 'one day occurrences' do
      before {
        all_day_event.run_callbacks(:save)
        regular_event.run_callbacks(:save)
      }

      it 'stores occurrences for one day' do
        all_day_event.occurrences.map(&:dtstart).map(&:to_date).must_equal [
          Date.parse('22/09/2015'),
          Date.parse('29/09/2015'),
          Date.parse('06/10/2015'),
          Date.parse('13/10/2015'),
          Date.parse('20/10/2015'),
          Date.parse('27/10/2015'),
          Date.parse('03/11/2015'),
          Date.parse('10/11/2015'),
          Date.parse('17/11/2015'),
          Date.parse('24/11/2015'),
        ]
      end

      it 'stores occurrences that span' do
        regular_event.occurrences.map{ |o| [o.dtstart, o.dtend] }.must_equal [
          [ DateTime.parse('22/10/2015 13:30'), DateTime.parse('22/10/2015 15:30') ]
        ]
      end
    end

    # =====================================================================

    describe 'simple scopes' do
      before { all_day_event.save! }

      describe '.for_datetime_range' do
        it { MyDocument.for_datetime_range( Date.parse('21/09/2015'), Date.parse('23/09/2015') ).first.must_equal all_day_event }
        it { MyDocument.for_datetime_range( Date.parse('20/10/2015'), Date.parse('23/11/2015') ).first.must_equal all_day_event }
        it { MyDocument.for_datetime_range( Date.parse('23/09/2015'), Date.parse('28/09/2015') ).first.must_be_nil }
      end

      describe '.from_datetime' do
        it { MyDocument.from_datetime( Date.parse('22/08/2015') ).first.must_equal all_day_event }
        it { MyDocument.from_datetime( Date.parse('29/09/2015') ).first.must_equal all_day_event }
        it { MyDocument.from_datetime( Date.parse('22/10/2015') ).first.must_equal all_day_event }
        it { MyDocument.from_datetime( Date.parse('24/11/2015') ).first.must_equal all_day_event }
        it { MyDocument.from_datetime( Date.parse('25/11/2015') ).first.must_be_nil }
      end

      describe '.to_datetime' do
        it { MyDocument.to_datetime( Date.parse('21/09/2015') ).first.must_be_nil }
        it { MyDocument.to_datetime( Date.parse('29/09/2015') ).first.must_equal all_day_event }
        it { MyDocument.to_datetime( Date.parse('22/10/2015') ).first.must_equal all_day_event }
        it { MyDocument.to_datetime( Date.parse('24/11/2015') ).first.must_equal all_day_event }
        it { MyDocument.to_datetime( Date.parse('25/11/2015') ).first.must_equal all_day_event }
      end
    end

    describe 'overlapping scopes' do
      before { regular_event.save! }

      describe '.for_datetime_range' do
        it { MyDocument.for_datetime_range( DateTime.parse('22/10/2015 13:31'), DateTime.parse('22/10/2015 15:29') ).first.must_equal regular_event }
        it { MyDocument.for_datetime_range( DateTime.parse('22/10/2015 13:30'), DateTime.parse('22/10/2015 15:30') ).first.must_equal regular_event }
        it { MyDocument.for_datetime_range( DateTime.parse('22/10/2015 13:29'), DateTime.parse('22/10/2015 15:31') ).first.must_equal regular_event }

        it { MyDocument.for_datetime_range( DateTime.parse('22/10/2015 13:29'), DateTime.parse('22/10/2015 15:29') ).first.must_equal regular_event }
        it { MyDocument.for_datetime_range( DateTime.parse('22/10/2015 13:31'), DateTime.parse('22/10/2015 15:31') ).first.must_equal regular_event }

        it { MyDocument.for_datetime_range( DateTime.parse('22/10/2015 15:31'), DateTime.parse('22/10/2015 15:32') ).first.must_be_nil }
        it { MyDocument.for_datetime_range( DateTime.parse('22/10/2015 13:28'), DateTime.parse('22/10/2015 13:29') ).first.must_be_nil }
      end
    end
  end
end
