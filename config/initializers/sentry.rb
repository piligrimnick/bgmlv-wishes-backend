# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_BACKEND_DSN']
  
  # Определяем окружение для разделения метрик (development/production)
  config.environment = Rails.env
  
  # Включаем breadcrumbs для более детального логирования
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
  # Performance Monitoring (APM) с traces_sample_rate = 0.1 (10%)
  config.traces_sample_rate = 0.1
  
  # Устанавливаем release version (если есть)
  config.release = ENV['SENTRY_RELEASE'] if ENV['SENTRY_RELEASE'].present?
  
  # Фильтруем чувствительные данные
  config.send_default_pii = false
  
  # Настройки для Rails
  config.rails.report_rescued_exceptions = true
  
  # Игнорируем стандартные Rails exceptions, которые не являются реальными ошибками
  config.excluded_exceptions += [
    'ActionController::RoutingError',
    'ActiveRecord::RecordNotFound'
  ]
  
  # Настройки для отладки (включаем только в development при необходимости)
  config.debug = false
  
  # Опционально: фильтруем параметры (пароли, токены и т.д.)
  config.before_send = lambda do |event, hint|
    # Можно добавить дополнительную логику фильтрации здесь
    event
  end
end
