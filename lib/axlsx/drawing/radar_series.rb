# frozen_string_literal: true

module Axlsx
  # A RadarSeries defines the title, data and labels for radar charts
  # @note The recommended way to manage series is to use Chart#add_series
  # @see Worksheet#add_chart
  # @see Chart#add_series
  class RadarSeries < Series
    # The data for this series.
    # @return [NumDataSource]
    attr_reader :data

    # The labels for this series.
    # @return [Array, SimpleTypedList]
    attr_reader :labels

    # The fill color for this series.
    # Red, green, and blue is expressed as sequence of hex digits, RRGGBB. A perceptual gamma of 2.2 is used.
    # @return [String]
    attr_reader :color

    # An array of rgb colors to apply to your radar chart.
    attr_reader :colors

    # Line width in EMUs (0-20116800)
    # @return [String]
    attr_reader :ln_width

    # show markers on values
    # @return [Boolean]
    attr_reader :show_marker

    # custom marker symbol
    # @return [String]
    attr_reader :marker_symbol

    # Creates a new series
    # @option options [Array, SimpleTypedList] data
    # @option options [Array, SimpleTypedList] labels
    # @option options [Cell, String] title
    # @option options [String] color
    # @option options [String] colors an array of colors to use when rendering each data point
    # @option options [String] ln_width line width in EMUs
    # @param [Chart] chart
    def initialize(chart, options = {})
      @colors = []
      @show_marker = false
      @marker_symbol = options[:marker_symbol] || :default
      super
      self.labels = AxDataSource.new(data: options[:labels]) unless options[:labels].nil?
      self.data = NumDataSource.new(options) unless options[:data].nil?
      @ln_width = options[:ln_width] unless options[:ln_width].nil?
    end

    # @see color
    def color=(v)
      @color = v
    end

    # @see colors
    def colors=(v)
      DataTypeValidator.validate "RadarSeries.colors", [Array], v
      @colors = v
    end

    # @see ln_width
    def ln_width=(v)
      @ln_width = v
    end

    # @see show_marker
    def show_marker=(v)
      Axlsx.validate_boolean(v)
      @show_marker = v
    end

    # @see marker_symbol
    def marker_symbol=(v)
      Axlsx.validate_marker_symbol(v)
      @marker_symbol = v
    end

    # Serializes the object
    # @param [String] str
    # @return [String]
    def to_xml_string(str = +'')
      super do
        if color || ln_width
          str << '<c:spPr>'
          if color
            str << '<a:solidFill><a:srgbClr val="' << color << '"/></a:solidFill>'
          end
          str << '<a:ln'
          if ln_width
            str << ' w="' << ln_width << '"'
          end
          str << '>'
          if color
            str << '<a:solidFill><a:srgbClr val="' << color << '"/></a:solidFill>'
          end
          str << '</a:ln>'
          str << '</c:spPr>'
        end

        if !@show_marker
          str << '<c:marker><c:symbol val="none"/></c:marker>'
        elsif @marker_symbol != :default
          str << '<c:marker><c:symbol val="' << @marker_symbol.to_s << '"/></c:marker>'
        end

        colors.each_with_index do |c, _index|
          str << '<c:spPr><a:solidFill>'
          str << '<a:srgbClr val="' << c << '"/>'
          str << '</a:solidFill><a:ln'
          if @ln_width
            str << ' w="' << @ln_width << '"'
          end
          str << '><a:solidFill><a:srgbClr val="' << c << '"/></a:solidFill></a:ln></c:spPr>'
        end

        @labels.to_xml_string(str) unless @labels.nil?
        @data.to_xml_string(str) unless @data.nil?
      end
    end

    private

    # assigns the data for this series
    def data=(v)
      DataTypeValidator.validate "Series.data", [NumDataSource], v
      @data = v
    end

    # assigns the labels for this series
    def labels=(v)
      DataTypeValidator.validate "Series.labels", [AxDataSource], v
      @labels = v
    end
  end
end
