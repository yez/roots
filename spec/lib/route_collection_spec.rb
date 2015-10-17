require_relative '../spec_helper'
require_relative '../../lib/route_collection'

module Roots
  describe RouteCollection do
    before do
      allow_any_instance_of(described_class).to receive(:main_app_name) { 'SomeGreatApp' }
    end

    describe '#initialize' do
      let(:fake_route) { Object.new }

      subject { described_class.new(app_routes: [fake_route]) }

      it 'sets the @application_routes variable' do
        expect(subject.instance_variable_get(:@application_routes)).to_not be_nil
      end

      it 'sets the @engine_routes variable' do
        expect(subject.instance_variable_get(:@engine_routes)).to_not be_nil
      end

      it 'creates Roots::Routes for each passed in route' do
        expect(subject.instance_variable_get(:@application_routes)).to_not be_empty

        expect(subject.instance_variable_get(:@application_routes).all? { |r| r.is_a?(Roots::Route) }).to eq(true)
      end

      context 'app routes contain an engine mount route' do
        let(:engine_mount_route) do
          Class.new do
            def app
              Class.new do
                def app
                  Class.new do |klass|
                    def self.ancestors
                      [Rails::Engine]
                    end

                    def self.name
                      self.class.name
                    end
                  end
                end
              end.new
            end
          end.new
        end

        xit 'adds it to the engine routes for the engine name' do
          expect_any_instance_of(described_class)
            .to receive(:add_engine_route)
            .with([], engine_mount_route, 'Class')

          described_class.new(app_routes: [engine_mount_route])
        end
      end


      context 'engine routes are present' do
        subject { described_class.new(app_routes: [fake_route], eng_routes: [{ engine: 'Whatever', routes: [fake_route]}]) }

        it 'initializes routes as Roots::Engine' do
          expect(subject.instance_variable_get(:@engine_routes)).to_not be_empty

          subject.instance_variable_get(:@engine_routes).each do |engine_name, routes|
            expect(routes.all? { |r| r.is_a?(Roots::EngineRoute) }).to eq(true)
          end
        end
      end

      context 'route is internal' do
        before do
          allow_any_instance_of(
            ActionDispatch::Routing::RouteWrapper
            ).to receive(:internal?) { true }
        end

        it 'does not add it to @routes' do
          expect(subject.instance_variable_get(:@application_routes)).to be_empty
        end
      end
    end
  end
end