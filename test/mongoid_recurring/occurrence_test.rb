require 'test_helper'

module MongoidRecurring
  describe Occurrence do

    let(:dtstart) { DateTime.now }
    let(:dtend) { dtstart + 1.day }

    subject { Occurrence.new }

    it { _(subject).must_respond_to :dtstart }
    it { _(subject).must_respond_to :dtend }

    # ---------------------------------------------------------------------

    describe 'when dtend not specified' do
      let(:doc) { Occurrence.new(dtstart: dtstart) }

      before { doc.run_callbacks(:save) }

      it 'sets it to dtend' do
        _(doc.dtend).must_equal doc.dtstart
      end
    end

    # ---------------------------------------------------------------------

    describe 'when all_day' do
      let(:doc) { Occurrence.new(dtstart: dtstart, dtend: dtend, all_day: true) }

      before { doc.run_callbacks(:save) }

      it 'adjusts dtstart to beginning of day' do
        _(doc.dtstart).must_equal doc.dtstart.beginning_of_day
      end

      it 'adjusts dtend to end of day' do
        _(doc.dtend).must_equal doc.dtend.end_of_day
      end
    end
  end
end
