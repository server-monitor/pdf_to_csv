
TargetFile.new.setup

RSpec.describe Base do
  include Base

  mut = :cmd_exist?

  it "should have '#{mut}' method" do
    expect(self).to respond_to mut
  end

  describe mut do
    context 'when command does not exist' do
      it 'should return false' do
        expect(public_send(mut, 'bogus_command')).to eq false
      end
    end

    context 'when command exists' do
      it 'should return true' do
        expect(public_send(mut, 'less')).to eq true
      end
    end
  end
end
