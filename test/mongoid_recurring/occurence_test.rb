require 'test_helper'

module MongoidRecurring
  describe Occurence do

    let(:dtstart) { DateTime.now }
    let(:dtend) { dtstart + 1.day }

    subject { Occurence.new }

    it { subject.must_respond_to :dtstart }
    it { subject.must_respond_to :dtend }

    # ---------------------------------------------------------------------

    describe 'when dtend not specified' do
      let(:doc) { Occurence.new(dtstart: dtstart) }

      before { doc.run_callbacks(:save) }

      it 'sets it to dtend' do
        doc.dtend.must_equal doc.dtstart
      end
    end

    # ---------------------------------------------------------------------

    describe 'when all_day' do
      let(:doc) { Occurence.new(dtstart: dtstart, dtend: dtend, all_day: true) }

      before { doc.run_callbacks(:save) }

      it 'adjusts dtstart to beginning of day' do
        doc.dtstart.must_equal doc.dtstart.beginning_of_day
      end

      it 'adjusts dtend to end of day' do
        doc.dtend.must_equal doc.dtend.end_of_day
      end
    end
  end
end
