module ServiceHourHelper
  def week_days_caption service_hours
    service_hours.sort!{|a, b| a.week_day_order <=> b.week_day_order}

    all = []
    block = []

    service_hours.each_with_index{|sh, i|
      # 営業日表示で祝前日はそのまま、他（月〜日、祝）は一文字だけ
      block << (sh.wday == 'before_hol' ? sh.wday_i18n : sh.wday_i18n[0])
      if (service_hours.length == i + 1) ||
         (service_hours[i + 1].week_day_order > (sh.week_day_order + 1)) ||
         (['hol', 'before_hol'].include?(service_hours[i + 1].wday))
          all << block
          block = []
      end
    }

    all.collect{|block|
      block.length > 2 ? [block.first, block.last].join('〜') : block.join(',')
    }.join(',')
  end
end
