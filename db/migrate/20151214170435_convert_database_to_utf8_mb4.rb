class ConvertDatabaseToUtf8Mb4 < ActiveRecord::Migration
  def change

    # for each string column with unicode content execute:
    varchar_cols =
      {
          'authentications'     => %w{ uid },
          'enumerations'        => %w{ value },
          'institutions'        => %w{ full_name nickname contact_info contact_email url
                                       url_text shib_entity_id shib_domain logo ancestry },
          'labels'              => %w{ desc },
          'plans'               => %w{ solicitation_identifier },
          'published_plans'     => %w{ file_name },
          'requirements'        => %w{ text_brief ancestry },
          'resource_contexts'   => %w{ contact_info contact_email },
          'resources'           => %w{ label },
          'roles'               => %w{ name },
          'sample_plans'        => %w{ url label },
          'tags'                => %w{ tag },
          'users'               => %w{ email first_name last_name token login_id orcid_id auth_token }
      }
    varchar_cols.each_pair do |k, v|
      v.each do |col|
        execute "ALTER TABLE `#{k}` MODIFY `#{col}` VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
      end
    end

    # for each text column with unicode content execute:
    text_cols =
    {
        'comments'            => %w{ value },
        'institutions'        => %w{ desc },
        'plans'               => %w{ name },
        'requirements'        => %w{ text_full default },
        'resource_contexts'   => %w{ name },
        'resources'           => %w{ value text },
        'responses'           => %w{ text_value }

    }
    text_cols.each_pair do |k, v|
      v.each do |col|
        execute "ALTER TABLE `#{k}` MODIFY `#{col}` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
      end
    end

    # for each table that will store unicode execute:
    %w{ authentications authorizations comments enumerations institutions labels plan_states
        plans published_plans requirements requirements_templates resource_contexts resources
        responses roles sample_plans tags user_plans users }.each do |table|
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"
    end
  end
end