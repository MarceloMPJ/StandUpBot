require 'slack-ruby-bot'

class StandUpBot < SlackRubyBot::Bot

  @@ticket_by_author = Set.new
  @@task_by_author = Set.new
  @@id_by_author = Set.new

  command 'gerar' do |client, data, match|
    user_name = client.store.users[data.user]['profile']['real_name']

    # Get tickets of user
    tickets = @@ticket_by_author.select{ |ticket| ticket[:author] == user_name }

    # Get tasks of user
    tasks = @@task_by_author.select{ |task| task[:author] == user_name }

    # Build message of tickets
    tickets_messages = tickets.map { |ticket| "> _Continuei o #{ticket[:description]}_" }

    # Build message of tasks
    tasks_messages = tasks.map { |task| "> _#{task[:description]}_" }

    body_message = tickets_messages.join("\n\n") + ("\n\n") + tasks_messages.join("\n\n")

    client.say text: "*Desde a última postagem:*\n#{body_message}", channel: data.channel
  end

  command 'mostrar tarefas' do |client, data, match|
    user_name = client.store.users[data.user]['profile']['real_name']
    tasks = @@task_by_author.select{ |task| task[:author] == user_name }

    # Build message of tasks
    tasks_messages = tasks.map { |task| "> _#{task[:description]}_" }

    body_message = tasks_messages.join("\n\n")

    client.say text: "*Tickets Registradas:*\n#{body_message}", channel: data.channel
  end

  command 'mostrar tickets' do |client, data, match|
    user_name = client.store.users[data.user]['profile']['real_name']
    tickets = @@ticket_by_author.select{ |task| task[:author] == user_name }

    # Build message of tickets
    tickets_messages = tickets.map { |task| "> _#{task[:description]}_" }

    body_message = tickets_messages.join("\n\n")

    client.say text: "*Tarefas Registradas:*\n#{body_message}", channel: data.channel
  end


  match /^tarefa (?<task>.*)/  do |client, data, match|
    user_name = client.store.users[data.user]['profile']['real_name']

    build_task = { author: user_name, description: "#{match[:task]}" }
    @@task_by_author << build_task

    client.say text: "Registrado com sucesso!", channel: data.channel
  end

  match /^ticket (?<ticket>.*)/  do |client, data, match|
    user_name = client.store.users[data.user]['profile']['real_name']

    build_task = { author: user_name, description: "#{match[:ticket]}" }
    @@ticket_by_author << build_task

    client.say text: "Registrado com sucesso!", channel: data.channel
  end


  match /^(?<author>[\w _]*) pushed \w* commit to `feature\/(?<branch_name>\w*)-(?<branch_number>\d*)`.*$/ do |client, data, match|
    build_ticket = { author: match[:author], description: "#{match[:branch_name]}-#{match[:branch_number]}" }
    @@ticket_by_author << build_ticket
  end

end

StandUpBot.run
