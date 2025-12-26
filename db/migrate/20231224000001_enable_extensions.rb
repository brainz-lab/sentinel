class EnableExtensions < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')

    # TimescaleDB extension - must be created by superuser in init-databases.sql
    # execute "CREATE EXTENSION IF NOT EXISTS timescaledb"
  end
end
