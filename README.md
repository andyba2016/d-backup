# Local Backup Plugin for Discourse

This plugin enables creating local backups of Discourse without uploading them to S3 or deleting the local backup file.

## ⚠️ Disclaimer

This plugin is provided "as is" without warranty of any kind. Use at your own risk.

The authors are not responsible for any data loss, corruption, or unexpected behavior caused by the use of this plugin.

It is strongly recommended to test thoroughly in a staging environment before deploying to production.


## Installation

Copy the `local_backup_plugin` folder into the `plugins/` directory of your Discourse installation.

## Usage

To run the local backup:

```bash
cd /var/www/discourse
bundle exec ruby plugins/local_backup_plugin/bin/run_local_backup.rb


