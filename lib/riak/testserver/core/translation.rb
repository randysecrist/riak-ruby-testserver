module Riak
  module TestServer
    # Methods for doing i18n string lookup
    module Translation
      # The scope of i18n messages
      def i18n_scope
        :riak_testserver
      end

      # Provides the translation for a given internationalized message
      def t(message, options={})
        I18n.t("#{i18n_scope}.#{message}", options)
      end
    end
  end
end

