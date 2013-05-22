require 'spec_helper'

describe Label do

  before { @label = Label.new(desc: "MB", group: "data-size") }

  subject { @label }

  it { should respond_to(:desc) }
  it { should respond_to(:group) }

  it { should have_many(:responses)}

  it { should be_valid }

  describe "when desc is blank" do
    before { @label.desc = nil }
    it { should_not be_valid }
  end

  describe "when group is blank" do
    before { @label.group = nil }
    it { should_not be_valid }
  end
end
