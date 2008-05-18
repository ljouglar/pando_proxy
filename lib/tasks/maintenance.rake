#vim:syntax=ruby
namespace :check do
  require 'rubygems'
  require 'timeout'
  require 'hpricot'
  require 'forkoff'
  require 'open-uri'

  PandoMatchString = /Pandora Radio \- Listen to Free Internet Radio, Find New Music/

  desc "Recherche de nouveaux proxy servers"  
  task :new_proxies => :environment do
    ENV['RAILS_ENV'] ||= 'production'
    if Time.now.strftime('%H%M') == '1000'
      reinject_proxies
    end
    get_proxies
    check_proxies
    Juggernaut.send_to_all("window.location.reload();")
  end

  private
    def reinject_proxies
      puts "  - re-injection des proxy qui ont une chance de revenir sur le devant de la scene"
      servers = Server.find_all_by_state(1, :conditions => '(retries >= 10 AND duration < 30) OR (duration >= 30 AND result LIKE "Pandora Radio%")')
      servers.each {|server| server.update_attribute(:retries, 8)}
      puts "      #{servers.size.to_s} serveurs re-injectes"
    end

    def get_proxies
      puts "  - recuperation de la liste des proxy servers US"
      (1..5).each do |i|
        doc = Hpricot(open("http://www.publicproxyservers.com/page#{i}.html", 
                           'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 6.0; fr; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11'))
        doc.search("/html/body/table/tbody/tr[1]/td[2]/table[2]/tbody/tr/td/table/tr").each do |line|
          # Seulement les lignes avec des serveurs américains
          if line.search("/td[1]").inner_html.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) and
             line.search("/td[2]").inner_html.match(/^(80|8080|3128)$/) and
             #line.search("/td[3]").inner_html != 'transparent' and
             line.search("/td[4]").inner_html == 'United States'
           params = {
             :ip_addr => line.search("/td[1]").inner_html, 
             :port => line.search("/td[2]").inner_html, 
             :transparency => line.search("/td[3]").inner_html
           }
           if ! @server = Server.find_by_ip_addr_and_port(params[:ip_addr], params[:port])
             @server = Server.create(params)
             puts "      création du serveur #{params[:ip_addr]}:#{params[:port]}"
           end
          end
        end
      end
    end

    def check_proxies
      @servers = Server.find(:all, :conditions => "state = 0 OR retries < 10")
      puts "  - test de tous les proxy servers de la base (#{@servers.size} serveurs à tester)"
      @servers.each do |server|
        debut = Time.now
        begin
          result = ''
          proxy_class = Net::HTTP::Proxy(server.ip_addr, server.port.to_i)
          if proxy_class
            proxy_class.start('www.pandora.com') do |http|
              http.read_timeout = 100
              Timeout::timeout(20) do |timeout_length|
                result = Hpricot(http.get('/').body).search("/html/head/title/").to_s
              end
            end
          end
        rescue Timeout::Error
          result = "Timeout error => #{$!}"
        rescue 
          result = "Error => #{$!}"
        end
        duration = Time.now - debut
        server.update_attribute(:duration, format("%.2f", duration))
        printf "      #{server.ip_addr}:#{server.port} => #{result}"
        if server.result == result or duration > 50 or (!result.match(PandoMatchString) and !server.result.match(PandoMatchString))
          puts " -- meme resultat, increment du retries"
          server.update_attribute(:retries, server.retries + 1)
        else
          puts " -- autre resultat (que #{server.result}), reset du retries"
          server.update_attributes(:result => result, :retries => 0)
        end
        if result.match(PandoMatchString) and duration < 30
          server.update_attribute(:state, 0)
        else
          server.update_attribute(:state, 1)
        end
        server.save
      end
    end
end
