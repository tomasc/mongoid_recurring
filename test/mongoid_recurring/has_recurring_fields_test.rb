require 'test_helper'

module MongoidRecurring
  describe HasRecurringFields do

    let(:start_date) { Date.parse '22/10/2015' }

    let(:ice_cube_schedule) {
      IceCube::Schedule.new(start_date) do |s|
        s.add_recurrence_rule IceCube::Rule.daily(1).count(7)
      end
    }

    subject { MyDocument.new( schedule: ice_cube_schedule ) }

    # ---------------------------------------------------------------------

    it { _(subject).must_respond_to :dtstart }
    it { _(subject).must_respond_to :dtend }
    it { _(subject).must_respond_to :all_day }
    it { _(subject).must_respond_to :schedule }

    it { _(subject).must_respond_to :occurrences }

    # =====================================================================

    describe 'on before save' do
      before { subject.run_callbacks(:save) }

      it 'expands schedule to occurrences' do
        _(subject.occurrences).must_be :present?
      end
    end

    describe 'when no schedule' do
      let(:dtstart) { DateTime.now }
      let(:doc) { MyDocument.new( dtstart: dtstart ) }

      before { doc.run_callbacks(:save) }

      it 'stores recurrence based on dtsart & dtend' do
        _(doc.occurrences.length).must_equal 1
      end
    end

  end
end
