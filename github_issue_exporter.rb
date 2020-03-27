#=================================================================================
# GitHub リポジトリに紐づくissue をJSON 形式でエクスポートする。
# JSONは [{issueの情報}, [{comment1}, {comment2}, ...]] という形式で生成する。
# 添付された画像のエクスポートは非対応。
#
# usage: ruby github_issue_exporter.rb \
#          --repo hekki/github-issue-exporter --export_dir /path/to
#          --github_token xxxxxxxxxxxxxx
#          --dry_run
#=================================================================================

require 'optparse'
require 'octokit'

args = ARGV.getopts(nil, 'repo:', 'export_dir:', 'github_token:', 'dry_run')

repo = args['repo']
export_dir = args['export_dir']
github_token = args['github_token']
dry_run = args['dry_run']

puts '============== dry_run mode ==============' if dry_run

Dir.mkdir(export_dir) unless Dir.exist?(export_dir)

client = Octokit::Client.new(access_token: github_token)
client.auto_paginate = true
issues = client.issues(repo, state: 'all')

issues.each do |issue|
  puts "Start export issue: #{issue.title}"

  comments = client.issue_comments(repo, issue.number)
  comments.map!(&:to_h)
  all_issue_data = [issue.to_h, comments]

  next if dry_run

  File.open("#{export_dir}/#{issue.number}", 'a') do |file|
    file.puts(JSON.generate(all_issue_data))
  end
end

