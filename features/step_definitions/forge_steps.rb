require 'fileutils'

Given(/^a new theme named "([^"]+)"$/) do |name|
  cli = Forge::CLI.new
  cli.shell.mute do
    cli.invoke(:create, [File.join(current_dir, name)])
  end
  cd name
end

Given(/^theme "([^"]*)" is using config "([^"]*)"$/) do |path, config_name|
  target = Forge.root.join("fixtures", path)
  config_path = File.join(current_dir, "config-#{config_name}.rb")
  config_dest = File.join(current_dir, "config.rb")
  FileUtils.cp(config_path, config_dest)
end

Given(/^an empty theme$/) do
  step %Q{a directory named "empty_app"}
  step %Q{I cd to "empty_app"}
end

Given(/^a fixture theme "([^"]*)"$/) do |path|
  # This step can be reentered from several places but we don't want
  # to keep re-copying and re-cd-ing into ever-deeper directories
  next if File.basename(current_dir) == path

  # step %Q{a directory named "#{path}"}
  mkdir path

  target_path = Forge.root.join("fixtures", path)
  FileUtils.cp_r(target_path, current_dir)

  cd path
end

Given(/^a built theme at "([^\"]*)"$/) do |path|
  step %Q{a fixture app "#{path}"}
  step %Q{I run `forge build`}
end

Given(/^was successfully built$/) do
  step %Q{a directory named "build" should exist}
  step %Q{the exit status should be 0}
end

Given(/^a successfully built theme at "([^\"]*)"$/) do |path|
  step %Q{a built app at "#{path}"}
  step %Q{was successfully built}
end

Given(/^a built theme at "([^\"]*)" with flags "([^\"]*)"$/) do |path, flags|
  step %Q{a fixture app "#{path}"}
  step %Q{I run `forge build #{flags}`}
end

Given(/^a successfully built theme at "([^\"]*)" with flags "([^\"]*)"$/) do |path, flags|
  step %Q{a built app at "#{path}" with flags "#{flags}"}
  step %Q{was successfully built}
end
