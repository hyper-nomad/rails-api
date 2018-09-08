# 仮実装
class NakedEmail
  attr_reader :origin, :host, :domain

  def initialize _email
    @origin = _email
    raise 'email format error' if _email.split(/@/).count != 2
    @host, @domain = _email.split(/@/)
  end

  def == obj
    self.naked == obj.naked
  end

  def naked_before_hashed
    if Gmail::AliasDomains.include? @domain
      Gmail.new(@origin).naked_before_hashed!
    else
      @origin
    end
  end

  def naked
    Digest::SHA256.hexdigest(naked_before_hashed)
  end

  class Gmail
    attr_reader :origin, :host, :domain

    AliasDomains = %w(gmail.com googlemail.com).freeze

    def self.gmail? _email
      AliasDomains.include?(_email)
    end

    def initialize _email
      @origin = _email
      raise 'email format error' if _email.split(/@/).count != 2
      @host, @domain = _email.split(/@/)
    end

    def naked_before_hashed!
      ignore_plus_alias!
      ignore_period_alias!
      ignore_domain_alias!
      concat
    end

    private

    # '+' charactor (ex. test@gmail.com, test+alias@gmail.com)
    def ignore_plus_alias!
      matched = @host.match(/([^+]+)/)
      return unless matched
      @host = matched[1]
    end

    # Period (ex. aa@gmail.com, a.a@gmail.com)
    def ignore_period_alias!
      @host = @host.split(/\./).join
    end

    # Domain (ex. gmail.com, googlemail.com)
    def ignore_domain_alias!
      @domain = @domain.sub(/^#{AliasDomains.join('|')}$/, AliasDomains.first)
    end

    def concat
      [@host, @domain].join('@')
    end
  end
end
