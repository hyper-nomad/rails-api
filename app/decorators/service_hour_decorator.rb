require 'time_helper'
class ServiceHourDecorator < Draper::Decorator
  include TimeHelper
  delegate_all

  def start_at
    view_time object.start_at
  end

  def end_at
    view_time object.end_at
  end

  def last_order_at
    view_time object.last_order_at
  end


  def start_0at
    view_0time object.start_at
  end

  def end_0at
    view_0time object.end_at
  end

  def last_order_0at
    view_0time object.last_order_at
  end

  def caption
    _range = time_range object.start_at, object.end_at
    _lo = object.last_order_at? ? "(#{ServiceHour.human_attribute_name :last_order} #{view_time(object.last_order_at)})" : ''
    _range + _lo
  end

  def wday_type
    case wday
    when 'sun', 'sat', 'hol'
      ['weekend', 'all']
    when 'before_hol'
      ['all']
    else
      ['weekday', 'all']
    end
  end

  private
  def view_time time
    to_watch(time) rescue nil
  end

  def view_0time time
    to_0watch(time) rescue nil
  end
end
