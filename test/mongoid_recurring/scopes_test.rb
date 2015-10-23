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

    subject { MyDocument.new( dtstart: today, schedule: ice_cube_schedule ) }

    # =====================================================================

    describe 'occurrences' do
      before { subject.run_callbacks(:save) }

      it 'stores occurrences' do
        subject.occurrences.map(&:dtstart).map(&:to_date).must_equal [
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
    end

    # =====================================================================

    describe '.for_datetime_range' do
      before { subject.save! }

      it { MyDocument.for_datetime_range( Date.parse('21/09/2015'), Date.parse('23/09/2015') ).first.must_equal subject }
      it { MyDocument.for_datetime_range( Date.parse('20/10/2015'), Date.parse('23/11/2015') ).first.must_equal subject }

      it { MyDocument.for_datetime_range( Date.parse('23/09/2015'), Date.parse('28/09/2015') ).first.must_be_nil }
    end

  end
end
