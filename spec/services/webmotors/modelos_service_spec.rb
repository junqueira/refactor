require 'rails_helper'

RSpec.describe Webmotors::ModelosService do
  describe "#fetch" do
    it "must respond to :fetch" do
      expect(subject).to respond_to :fetch
    end

    it "must cache response" do
      expect(Rails.cache).to receive(:fetch).with('webmotors:modelos:1') { '[]' }

      subject.fetch 1
    end

    it "must require one argument as numeral" do
      expect { subject.fetch }.to raise_error ArgumentError, "wrong number of arguments (given 0, expected 1)"

      expect { subject.fetch("invalid") }.to raise_error ArgumentError, "invalid argument type"
      expect { subject.fetch(:invalid) }.to raise_error ArgumentError, "invalid argument type"
      expect { subject.fetch([]) }.to raise_error ArgumentError, "invalid argument type"
      expect { subject.fetch({ type: :invalid }) }.to raise_error ArgumentError, "invalid argument type"
    end

    it "must post on Webmotors API" do
      http = class_double("Net::HTTP").as_stubbed_const

      mock_response = double(:http, body: '[]')
      expect(http).to receive(:post_form) { mock_response }

      subject.fetch "1"
    end

    it "must post on Webmotors API using argument" do
      http = class_double("Net::HTTP").as_stubbed_const

      uri = URI("http://www.webmotors.com.br/carro/modelos")
      mock_response = double(:http, body: '[]')
      expect(http).to receive(:post_form).with(uri, { marca: "1" }) { mock_response }

      expect(subject.fetch "1").to eq []
    end
  end

  describe "#sync!" do
    it "must respond to :sync!" do
      expect(subject).to respond_to :sync!
    end

    it "must require one argument as numeral" do
      expect { subject.sync! }.to raise_error ArgumentError, "wrong number of arguments (given 0, expected 1)"

      expect { subject.sync!("invalid") }.to raise_error ArgumentError, "invalid argument type"
      expect { subject.sync!(:invalid) }.to raise_error ArgumentError, "invalid argument type"
      expect { subject.sync!([]) }.to raise_error ArgumentError, "invalid argument type"
      expect { subject.sync!({ type: :invalid }) }.to raise_error ArgumentError, "invalid argument type"
    end

    it "must call :fetch with argument" do
      Make.delete_all
      Make.create name: "Fiat", webmotors_id: 1
      expect(subject).to receive(:fetch).with(1) { [] }

      subject.sync! 1
    end

    it "must create Models based on :fetch response" do
      Make.delete_all
      Model.delete_all
      Make.create name: "Fiat", webmotors_id: 1
      data = [
        { "Nome" => "F-100" },
        { "Nome" => "Focus" }
      ]
      expect(subject).to receive(:fetch).with(1) { data }

      subject.sync! 1

      expect(Model.count).to eq(2)
      expect(Model.first.name).to eq "F-100"
      expect(Model.first.make).to eq Make.first
      expect(Model.second.name).to eq "Focus"
      expect(Model.second.make).to eq Make.first
    end

    it "must skip duplicated results" do
      Make.delete_all
      Model.delete_all
      Make.create name: "Fiat", webmotors_id: 1
      data = [
        { "Nome" => "F-100" },
        { "Nome" => "Focus" }
      ]

      10.times do
        expect(subject).to receive(:fetch).with(1) { data }
        subject.sync! 1
      end

      expect(Model.count).to eq(2)
    end

    it "must log duplicated results" do
      Make.delete_all
      Model.delete_all
      make = Make.create name: "Fiat", webmotors_id: 1
      Model.create make: make, name: "F-100"

      expect(subject).to receive(:fetch).with(1) { [{"Nome" => "F-100"}] }
      expect(Rails.logger).to receive(:debug).with("Record already registered: {\"Nome\"=>\"F-100\"}")

      subject.sync! 1
    end

    it "must log invalid results" do
      Make.delete_all
      Model.delete_all
      make = Make.create name: "Fiat", webmotors_id: 1
      Model.create make: make, name: "F-100"

      expect(subject).to receive(:fetch).with(1) { [{"Type" => "Invalid"}] }
      expect(Rails.logger).to receive(:debug).with("Resource invalid to import: {\"Type\"=>\"Invalid\"}. Reason: Validation failed: Name can't be blank")

      subject.sync! 1
    end

    it "must raise error when Make not exists" do
      Make.delete_all
      expect { subject.sync! 1 }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Make")
    end

    it "must use ActiveRecord::Base.transaction" do
      active_record = class_double('ActiveRecord::Base').as_stubbed_const
      expect(active_record).to receive :transaction

      subject.sync! 1
    end
  end

  describe "self.sync!" do
    it "must respond to self.sync!" do
      expect(Webmotors::ModelosService).to respond_to :sync!
    end

    it "must require one argument as numeral" do
      expect { Webmotors::ModelosService.sync! }.to raise_error ArgumentError, "wrong number of arguments (given 0, expected 1)"

      expect { Webmotors::ModelosService.sync!("invalid") }.to raise_error ArgumentError, "invalid argument type"
      expect { Webmotors::ModelosService.sync!(:invalid) }.to raise_error ArgumentError, "invalid argument type"
      expect { Webmotors::ModelosService.sync!([]) }.to raise_error ArgumentError, "invalid argument type"
      expect { Webmotors::ModelosService.sync!({ type: :invalid }) }.to raise_error ArgumentError, "invalid argument type"
    end

    it "runs only if cache not exists" do
      expect(Rails.cache).to receive(:exist?).with("webmotors:modelos:1") { false }

      mock_object = double('modelo_service')
      expect(mock_object).to receive :sync!
      expect(Webmotors::ModelosService).to receive(:new) { mock_object }

      Webmotors::ModelosService.sync! 1
    end

    it "do not run if exists cache" do
      expect(Rails.cache).to receive(:exist?).with("webmotors:modelos:1") { true }

      expect(Webmotors::ModelosService).not_to receive(:new)

      Webmotors::ModelosService.sync! 1
    end
  end
end