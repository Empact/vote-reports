class District::Level
  LEVELS = {
    'federal' => {
      :fill_color => '#ff0000',
      :stroke_color => '#8b0000',
      :description => 'Congressional District'
    },
    'state_upper' => {
      :fill_color => '#00ff00',
      :stroke_color => '#006400',
      :description => 'Upper House District'
    },
    'state_lower' => {
      :fill_color => '#0000ff',
      :stroke_color => '#00008b',
      :description => 'Lower House District'
    }
  }

  class << self
    def levels
      LEVELS.keys
    end
  end

  def initialize(level)
    @level = level
  end

  def method_missing(method, *args)
    @attrs ||= LEVELS.fetch(level)
    @attrs.fetch(method.to_sym)
  end

  attr_reader :level
  alias_method :to_s, :level
  delegate :to_sym, :to => :level
end