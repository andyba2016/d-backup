# name: d_backup
# about: Custom backup plugin with cron control
# version: 0.1

module ::Jobs
  class DBackupJob < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      return unless SiteSetting.d_backup_enable_daily_job

      Rails.logger.info("[DBackupJob] Starting daily backup job...")
     
     source_dir = Rails.root.join("public", "backups", "default").to_s
     plugin_setting = SiteSetting.d_backup_dest_dir
     dest_dir = Rails.root.join(plugin_setting).to_s   

      # Aquí llamas al código real de tu backup
      user = Discourse.system_user
      backup = CustomBackup::LocalBackuper.new(user.id, with_uploads: true)
      filename = backup.run

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
        Rails.logger.warn("[DBackupJob] Backup failed or did not return a filename.")
      end
    end
  end
end