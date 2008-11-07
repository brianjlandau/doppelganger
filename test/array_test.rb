require File.dirname(__FILE__) + '/test_helper'

class DoppelgangerArrayTest < Test::Unit::TestCase
  
  context 'extended array object' do
    should "identify duplicate elements" do
      assert ![1,1,2].duplicates?(4)
      assert ![1,1,2].duplicates?(2)
      assert [1,1,2].duplicates?(1)

      assert ![].duplicates?(1)
    end
  end
  
end

