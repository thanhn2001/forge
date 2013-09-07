Given(/^I am in a forge project named "([^"]+)"$/) do |name|
  cli = Forge::CLI.new

  cli.shell.mute do
    Forge::Project.create(File.join(current_dir, name), {:name => name}, cli)
  end

  cd name
end

