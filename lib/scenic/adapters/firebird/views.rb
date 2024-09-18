module Scenic
  module Adapters
    class Firebird
      class Views
        def initialize(connection)
          @connection = connection
        end

        def all
          views_from_firebird.map(&method(:to_scenic_view))
        end

        private

        attr_reader :connection

        def views_from_firebird
          connection.execute(<<-SQL)
            SELECT 
              rdb$relation_name AS view_name,
              rdb$view_source AS view_source
            FROM rdb$relations
            WHERE
              rdb$relation_type = 1 AND rdb$system_flag = 0
            ORDER BY rdb$relation_id;
          SQL

        end

        def to_scenic_view(result)
          Scenic::View.new(
            name: result["view_name"],
            definition: result["view_source"].strip,
            materialized: false,
          )
        end

      end
    end
  end
end