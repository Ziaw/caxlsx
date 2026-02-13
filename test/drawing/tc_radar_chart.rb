# frozen_string_literal: true

require 'tc_helper'

class TestRadarChart < Minitest::Test
  def setup
    @p = Axlsx::Package.new
    ws = @p.workbook.add_worksheet
    @row = ws.add_row ["one", 1, Time.now]
    @chart = ws.add_chart Axlsx::RadarChart, title: "fishery"
  end

  def teardown; end

  def test_initialization
    assert_equal(:standard, @chart.radar_style, "radar_style default incorrect")
    assert_equal(@chart.series_type, Axlsx::RadarSeries, "series type incorrect")
    assert_kind_of(Axlsx::CatAxis, @chart.cat_axis, "category axis not created")
    assert_kind_of(Axlsx::ValAxis, @chart.val_axis, "value axis not created")
  end

  def test_radar_style
    assert_raises(ArgumentError, "require valid radar_style") { @chart.radar_style = :inverted }
    refute_raises { @chart.radar_style = :filled }
    assert_equal(:filled, @chart.radar_style)
    refute_raises { @chart.radar_style = :marker }
    assert_equal(:marker, @chart.radar_style)
  end

  def test_to_xml
    schema = Nokogiri::XML::Schema(File.open(Axlsx::DRAWING_XSD))
    doc = Nokogiri::XML(@chart.to_xml_string)
    errors = schema.validate(doc)

    assert_empty(errors)
  end

  def test_to_xml_with_series
    @chart.add_series data: [1, 2, 3], labels: ["a", "b", "c"], title: "test"
    schema = Nokogiri::XML::Schema(File.open(Axlsx::DRAWING_XSD))
    doc = Nokogiri::XML(@chart.to_xml_string)
    errors = schema.validate(doc)

    assert_empty(errors)
  end
end
