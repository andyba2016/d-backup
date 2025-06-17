# name: local-backup-plugin
# about: Create custom backup file
# version: 0.1
# authors: atarrio

after_initialize do
    require_relative "lib/custom_backup/local_backuper"
end
