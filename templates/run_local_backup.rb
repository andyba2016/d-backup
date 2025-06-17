#!/usr/bin/env ruby

require 'fileutils'
require File.expand_path("../config/environment", __dir__)
require_relative "../plugins/d-backup/lib/custom_backup/local_backuper"

# Paths
source_dir = Rails.root.join("public", "backups", "default").to_s

plugin_setting = SiteSetting.d_backup_dest_dir
dest_dir = Rails.root.join(plugin_setting).to_s

# Create destination directory if it doesn't exist
FileUtils.mkdir_p(dest_dir)

# Get system user
user = Discourse.system_user
puts "[INFO] Starting local backup as #{user.username}..."

# Run backup
backup = CustomBackup::LocalBackuper.new(user.id, with_uploads: true)
filename = backup.run

# Verify and move the backup file
if backup.success && filename
  source_file = File.join(source_dir, filename)
  dest_file = File.join(dest_dir, filename)

  if File.exist?(source_file)
    FileUtils.mv(source_file, dest_file)
    puts "[SUCCESS] Backup completed successfully: #{dest_file}"
  else
    puts "[ERROR] Backup file not found: #{source_file}"
  end
else
  puts "[ERROR] Backup failed or did not return a filename."
end
