Given(/^I am in a forge project named "([^"]+)"$/) do |name|
  cli = Forge::CLI.new
  cli.shell.mute do
    cli.invoke(:create, [File.join(current_dir, name)])
  end
  cd name
end

