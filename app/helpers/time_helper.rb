module TimeHelper
  def time_range from, to
    _next = (from > to) ? I18n.t('time.next') : '' rescue ''
    to_watch(from) + "〜" + _next + (to_watch(to) rescue '')
  end

  def to_watch time
    wt = to_0watch time
    wt.sub(/^0/, '')
  end

  # 最小1分
  def to_expiration seconds
    days, remainder = seconds.divmod(24*60*60)
    return "#{days}日" if days != 0
    hours, remainder = remainder.divmod(60*60)
    return "#{hours}時間" if hours != 0
    minutes, remainder = remainder.divmod(60)
    "#{minutes == 0 ? 1 : minutes}分"
  end

  def to_0watch time
    wt = I18n.l(time, format: :watch)
  end
end

