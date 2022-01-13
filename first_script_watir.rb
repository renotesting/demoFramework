require 'watir-webdriver'
#require 'watir'
require 'selenium-webdriver'

#caps = Selenium::WebDriver::Remote::Capabilities.chrome("goog:chromeOptions" => {detach: true})
browser =  Watir::Browser.new #:chrome, desired_capabilities: caps
#browser.goto 'watir.com'
browser.goto 'www.shaw.ca'
browser.driver.manage.window.maximize

sleep 1
browser.button(text: 'Internet', class: 'c-desktop-nav__category is-drop-down').click
sleep 1
browser.link(href: '/internet/plans', class: 'c-desktop-nav__sub-menu-links').click
sleep 1
group = browser.div(class: 'c-plans-overview__container')
if(group.exists?)
	browser.execute_script('arguments[0].scrollIntoView();', group)
end

cardTitle = browser.h3(id: 'card-title-0-130-Fibre-300-front')
if cardTitle.exists?
	puts cardTitle.text
end

puts browser.title

sleep 5
# => 'Guides – Watir Project'
#browser.close
