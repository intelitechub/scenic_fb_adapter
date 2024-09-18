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
          view_name = result.values_at "view_name"
          Scenic::View.new(
            name: view_name,
            definition: extract_definition(result),
            materialized: false,
          )
        end

        def extract_definition(result)
          result["view_source"].strip.sub(/\A.*#{result["name"]}\W*AS\s*/, "")
        end

      end
    end
  end
end
