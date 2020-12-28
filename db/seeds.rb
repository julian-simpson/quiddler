# frozen_string_literal: true

require 'json'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
file = File.read('db/quiddler_data.json')
quiddler_hash = JSON.parse(file)
Rails.logger.debug(quiddler_hash.to_yaml)
Rails.logger.debug('<<<<<<<<<<<<<<<<<')
Rails.logger.debug(quiddler_hash['pieces'].to_yaml)

quiddler_hash['pieces']['cards']['types'].each do |card_data|
  card_data['count'].times { Card.create(letters: card_data['letters'], value: card_data['value']) }
end
