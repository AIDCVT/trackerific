class Trackerific::Parsers::USPS < Trackerific::Parsers::Base
  protected

  def response_error
    @response_error ||=
      if @response.code != 200
        Trackerific::Error.new("HTTP returned status #{@response.code}")
      elsif @response['Error']
        Trackerific::Error.new(@response['Error']['Description'])
      elsif @response['TrackResponse'].nil? && @response['CityStateLookupResponse'].nil?
        Trackerific::Error.new('Invalid response from server.')
      else
        false
      end
  end

  def summary
    tracking_info['TrackSummary']
  end

  def events
    tracking_info.fetch('TrackDetail', []).map do |e|
      Trackerific::Event.new(date(e), description(e), location(e))
    end
  end

  private

  def tracking_info
    @response['TrackResponse']['TrackInfo']
  end

  def date(event)
    d = event.split(', ')
    DateTime.parse(d[1..3].join(', '))
  end

  def description(event)
    d = event.split(', ')
    d[0]
  end

  def location(event)
    d = event.split(', ')
    d[4..-1].join(', ')
  end
end
