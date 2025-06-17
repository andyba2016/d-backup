#!/usr/bin/env ruby

require 'fileutils'
require 'aws-sdk-s3'
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

  if SiteSetting.d_backup_s3_enable
    s3_client = Aws::S3::Client.new(
      region: SiteSetting.d_backup_s3_region.presence || 'us-east-1',
      access_key_id: SiteSetting.d_backup_s3_access_key.presence || 'test',
      secret_access_key: SiteSetting.d_backup_s3_secret_key.presence || 'test',
      endpoint: SiteSetting.d_backup_s3_endpoint.presence || 'http://localhost:4566',
      force_path_style: true
    )

    bucket = SiteSetting.d_backup_s3_bucket.presence || 'my-test-bucket'
    object_key = File.basename(dest_file)

    puts "[INFO] Uploading to S3 bucket '#{bucket}' as '#{object_key}'..."

    s3_client.put_object(
      bucket: bucket,
      key: object_key,
      body: File.open(dest_file, 'rb')
    )
  end

else
  puts "[ERROR] Backup failed or did not return a filename."
end
