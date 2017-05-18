namespace :verman do
  desc "check git repo and merge if header is different"
  task update: :environment do
    repo = Git.open(Rails.root)
    repo.fetch

    if repo.object('origin/HEAD').diff(repo.object('HEAD')).size > 0 then
      repo.pull

      # restart puma
      File.delete Rails.root.join('tmp', 'pid', 'server.pid')
      File.open(Rails.root.join('tmp', 'restart.txt'), 'w') {}
    end
  end

end
