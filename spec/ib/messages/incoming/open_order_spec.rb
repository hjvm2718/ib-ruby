require 'order_helper'

shared_examples_for 'OpenOrder message' do
  it { should be_an IB::Messages::Incoming::OpenOrder }
  its(:message_type) { should == :OpenOrder }
  its(:message_id) { should == 5 }
  its(:version) { should == 30}
  its(:data) { should_not be_empty }
  its(:local_id) { should be_an Integer }
  its(:status) { should =~ /Submit/ }
  its(:to_human) { should =~
      /<OpenOrder: <Stock: WFC USD> <Order: LMT DAY buy 100 @ 9.13 .*Submit.* #\d+\/\d+ from 1111/ }

  it 'has proper contract accessor' do
    c = subject.contract
    expect( c ).to be_an IB::Contract
    expect( c.symbol).to eq 'WFC'
    expect( c.exchange).to eq 'NYSE'
  end

  it 'has proper order accessor' do
    o = subject.order
    expect( o ).to be_an IB::Order
    expect( o.client_id ).to eq 1111
    expect( o.parent_id ).to be_zero
    expect( o.local_id ).to be_an Integer
    expect( o.perm_id ).to  be_an Integer
    expect( o.order_type).to eq :limit
    expect( o.tif).to eq :day
    expect( o.status).to match /Submit/
  end

  it 'has proper order_state accessor' do
    os = subject.order_state
     expect( os.local_id).to be_an Integer
     expect( os.perm_id).to be_an Integer
     expect( os.client_id).to eq 1111
     expect( os.parent_id).to be_zero
     expect( os.status).to match /Submit/
  end

  it 'has class accessors as well' do
    expect( subject.class.message_id).to eq 5
    expect( subject.class.version).to eq 30 # Message versions supported
    expect( subject.class.message_type).to eq :OpenOrder
  end

end

describe IB::Messages::Incoming::OpenOrder do

  context 'Instantiated with data Hash' do
    subject do
      IB::Messages::Incoming::OpenOrder.new :version => 30,
                                            :order =>
                                                {:local_id => 1313,
                                                 :perm_id => 172323928,
                                                 :client_id => 1111,
                                                 :parent_id => 0,
                                                 :side => :buy,
                                                 :order_type => :limit,
                                                 :limit_price => 9.13,
                                                 :total_quantity => 100,
                                                },
                                            :order_state =>
                                                {:local_id => 1313,
                                                 :perm_id => 172323928,
                                                 :client_id => 1111,
                                                 :parent_id => 0,
                                                 :status => 'PreSubmitted',
                                                },
                                            :contract =>
                                                {:symbol => 'WFC',
                                                 :exchange => 'NYSE',
                                                 :currency => 'USD',
                                                 :sec_type => :stock
                                                }
    end

    it_behaves_like 'OpenOrder message'
  end

  context 'received from IB', :pending => "order statement unclear" do
    before(:all) do
    gw = IB::Gateway.current.presence || IB::Gateway.new( OPTS[:connection].merge(logger: mock_logger, client_id:1056, connect:true, serial_array: false, host: 'localhost'))
    gw.connect if !gw.tws.connected?
    if gw.advisor.test_environment?
      @ib=gw.tws

      place_order IB::Stock[:wfc]
      @ib.wait_for :OpenOrder, 3
      @ib.received?(:OpenOrder).should be_true
    end
    end

    after(:all) { close_connection } # implicitly cancels order

    subject { @ib.received[:OpenOrder].first }

    it_behaves_like 'OpenOrder message'

    #it 'has extended order_state attributes' do
  end
end # describe IB::Messages:Incoming

__END__
11:55:04:543 <- 3-38-22 -0-USD -BAG--0.0---SMART--USD----BUY-1 -MKT------O-0--1-0-0-0-0-0-0-0-2-101360836-1-SELL-SMART-0-0---1-81032967-1-BUY-SMART-0-0---1-0-0--0.0-------0---1-0---0---0-0--0------0-----0--------0---0-0--0-
12:20:02:859 <- 3-38-22 -0-GOOG-BAG--0.0---SMART--USD----BUY-10-LMT-0.01-   -   ---O-0-Original-1-0-0-0-0-0-0-0-2-101360836-1-SELL-SMART-0-0---1-81032967-1-BUY-SMART-0-0---1-0-0--0.0-------0---1-0---0---0-0--0------0-----0--------0---0-0--0-
11:58:07:100 <- 3-38-304-0-GOOG-BAG--0.0---SMART--USD----BUY-10-LMT-0.01-0.0-DAY---O-0-Original-1-0-0-0-0-0-0-0-3-81032967-1-BUY-SMART-0-0---1-81032968-2-SELL-SMART-0-0---1-81032973-1-BUY-SMART-0-0---1-3----0--0.0-------0---1-0---0---0-0--0------0-----0--------0---0-0--0-

22:34:23:993 <- 3-38-17- 0-WFC-STK--0.0---NYSE--USD----BUY-100-LMT-9.13-0.0-DAY---O-0--1-0-0-0-0-0-0-0--0.0-------0---1-0---0---0-0--0------0-----0--------0---0-0--1-
22:34:25:203 <- 3-38-18 -0-WFC-STK--0.0---NYSE--USD----BUY-100-LMT-9.13-0.0-DAY---O-0--1-0-0-0-0-0-0-0--0.0-------0---1-0---0---0-0--0------0-----0--------0---0-0--0-
00:11:37:820 <- 3-38-180-0-WFC-STK--0.0---NYSE--USD----BUY-100-LMT-9.13-   -   ---O-0--1-0-0-0-0-0-0-0--0.0-------0---1-0---0---0-0--0------0-----0--------0---0-0--0-

