require "opal"

require './vendor/zepto'
require "opal-jquery"


require './vendor/react'
require './vendor/react_router'


# window.Router = ReactRouter.Router
# window.Route = ReactRouter.Route
# window.Link = ReactRouter.Link
# window.IndexRoute = ReactRouter.IndexRoute
# window.browserHistory = window.ReactRouter.History.createHistory


require './vendor/moment'
require './vendor/waypoints'

require './vendor/wisyhtml5/wysihtml'
require './vendor/wisyhtml5/wysihtml_parser_rules'

require_tree "./vendor/core_monkey_patches"

require_tree './vendor/model'

require_tree './vendor/react_wrapper'

require_tree './vendor/native_wrappers'

require_tree './plugins'

RW.include Plugins::FlashMessage
RW.include Plugins::Modal
RW.include Plugins::PhantomYielder
RW.include Plugins::ReactRouter
RW.include Plugins::ProgressBar
RW.include Plugins::RWGlobalExtensions

RequestHandler.include Plugins::RequestHandler

require_tree "./models"
require_tree "./services"
require_tree "./components/shared"
require_tree "./components"

#BOOTSTRAP APP
Document.ready? do
  #to pass server props in your home#index add for example:
  #than in Components::App::Router those props are set to Services::PropsFromServer
  #and they can be gotten in components as Services::PropsFromServer.props
  # <%= javascript_tag do %>
  #   window.__PROPS_FROM_SERVER__ = '<%= raw @data.to_json %>';
  # <% end %>

  # <div id='app'>

  # </div>
  # and no need for REACT UJS

  `

  var app_element = document.getElementById('app')

  if (app_element)
  {
    ReactDOM.render(React.createElement(Components_App_Router), document.getElementById('app'));
  }
  else
  {
    return false
  }

  `


end
