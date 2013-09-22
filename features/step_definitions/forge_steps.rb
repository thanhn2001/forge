Given(/^I am in a xerox project named "([^"]+)"$/) do |name|
  cli = Xerox::CLI.new

  cli.shell.mute do
    Xerox::Project.create(File.join(current_dir, name), { id: name }, cli)
  end

  cd name
end

