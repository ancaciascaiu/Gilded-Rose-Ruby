class GildedRose # better name for this is Item
  attr_reader :name, :days_remaining, :quality

  def initialize(name:, days_remaining:, quality:)
    @name = name
    @days_remaining = days_remaining
    @quality = quality
  end

  def tick
    item_updater = ItemUpdaterFactory.new(name: name).item_updater
    @quality = item_updater.next_quality(days_remaining: days_remaining, quality: quality)
    @days_remaining = item_updater.next_days_remaining(days_remaining: days_remaining)
  end
end

class ItemUpdaterFactory
  attr_reader :name

  def initialize(name:)
    @name = name
  end

  def item_updater
    case name
    when 'Normal Item'
      NormalItemUpdater.new
    when 'Aged Brie', 'Aged Wine', 'Whisky'
      AgingItemUpdater.new(rate_of_change_map: rate_of_change_map[name])
    when 'Sulfuras, Hand of Ragnaros'
      SulfurasUpdater.new
    when 'Backstage passes to a TAFKAL80ETC concert'
      BackstagePassUpdater.new
    when 'Conjured Mana Cake'
      ConjuredManaUpdater.new
    else
      ItemUpdater.new
    end
  end

  private

  def rate_of_change_map
    {
      'Aged Brie' => {1..99999 => 1, -99999..0 => 2},
      'Aged Wine' => {1..99999 => 1, -9..0 => 2, -99999..-10 => 3}
      'Whisky' => {1..99999 => 1, -9..0 => -1, -99999..-10 => 5}
    }
  end
end

class ItemUpdater
  def next_quality(days_remaining:, quality:)
    raise NotImplementedError
  end

  def change_rate(days_remaining:)
    raise NotImplementedError
  end

  def next_days_remaining(days_remaining:)
    days_remaining -= 1
  end
end


class NormalItemUpdater < ItemUpdater
  def next_quality(days_remaining:, quality:)
    [0, quality + change_rate(days_remaining: days_remaining)].max
  end

  def change_rate(days_remaining:)
    if days_remaining > 0
      -1
    else
      -2
    end
  end
end

class AgingItemUpdater < ItemUpdater
  attr_reader :rate_of_change_map

  def initialize(rate_of_change_map:)
    @rate_of_change_map = rate_of_change_map
  end

  def next_quality(days_remaining:, quality:)
    [50, quality + change_rate(days_remaining: days_remaining)].min
  end

  def change_rate(days_remaining:)
    rate_of_change_map.each_pair do |range, rate|
      if range.include?(days_remaining)
        return rate
      end
    end
  end
end

class SulfurasUpdater < ItemUpdater
  def next_quality(days_remaining:, quality:)
    quality
  end

  def change_rate(days_remaining:)
    0
  end

  def next_days_remaining(days_remaining:)
    days_remaining
  end
end

class BackstagePassUpdater < ItemUpdater
  def next_quality(days_remaining:, quality:)
    if days_remaining > 0
      [50, quality + change_rate(days_remaining: days_remaining)].min
    else
      0
    end
  end

  def change_rate(days_remaining:)
    if days_remaining > 10
      1
    elsif days_remaining > 5
      2
    elsif days_remaining > 0
      3
    else
      0
    end
  end
end

class ConjuredManaUpdater < ItemUpdater
  def next_quality(days_remaining:, quality:)
    [0, quality + change_rate(days_remaining: days_remaining)].max
  end

  def change_rate(days_remaining:)
    if days_remaining > 0
      -2
    else
      -4
    end
  end
end

class EnchantedHourglassUpdater < ItemUpdater
  def next_quality(days_remaining:, quality:)
    [0, quality + change_rate(days_remaining: days_remaining)].max
  end

  def change_rate(days_remaining:)
    if days_remaining > 0
      -1
    else
      -2
    end
  end

  def next_days_remaining(days_remaining:)
    days_remaining -= 0.5
  end
end












