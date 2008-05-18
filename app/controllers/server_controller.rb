class ServerController < ApplicationController
  protect_from_forgery :except => :create

  active_scaffold :server do |config|
    config.label = "Liste des proxy US pour Pandora :"
    config.columns = [:ip_addr, :port, :transparency, :result, :state, :retries, :duration, :updated_at]
    #config.actions.exclude :update, :delete, :show
    list.columns.exclude :comments
    list.sorting = {:state => 'ASC'}
    list.per_page = 25
    columns[:ip_addr].label = "Adresse IP"
    columns[:port].label = "Port"
    columns[:transparency].label = "Transparence"
    columns[:result].label = "Résultat"
    columns[:state].label = "Etat"
    columns[:retries].label = "Essais"
    columns[:duration].label = "Durée"
  end
end
