riot = require 'riot'

require './tags/checkbox'
require './tags/checkout'
require './tags/modal'
require './tags/progressbar'
screens = require './screens'

API = require './models/api'
ItemRef = require './models/itemRef'
User = require './models/user'
Order = require './models/order'
Payment = require './models/payment'

theme = require './utils/theme'

search = /([^&=]+)=?([^&]*)/g
q = window.location.href.split('?')[1].split('&')
qs = {}
while (match = search.exec(q))
  qs[decodeURIComponent(match[1])] = decodeURIComponent(match[2])

# checkout
#  id:     the id refered to by a anchor tag button
#  api:    object of API Class
#  order:  object of Order Class
#  config: config object such as:
#    {
#      screens: [screens.card],
#      callToActions: ['Pre-order'],
#    }
#
checkout = (id, api, order, user = (new User), config = {}) ->
  config.callToActions  = config.callToActions  || ['Pre-Order', 'Confirm']
  config.thankYouHeader = config.thankYouHeader || 'Thank You'
  config.thankYouBody   = config.thankYouBody   || 'You will receive a confirmation email for your preorder.'
  config.shareHeader    = config.shareHeader    || 'Follow us to get the latest updates'
  config.screens        = config.screens        || [screens.card, screens.shipping]
  config.termsUrl       = config.termsUrl       || 'http://www.crowdstart.com/terms'
  config.internationalShipping = config.internationalShipping || 0 #In Cents

  # Configure social sharing
  config.facebook   = config.facebook   || ''
  config.googlePlus = config.googlePlus || ''
  config.twitter    = config.twitter    || ''

  config.showPromoCode = config.showPromoCode || false

  # Configure analytics/conversion tracking
  config.pixels     = config.pixels || {}

  api.getItems order, (order) ->
    $modal = $('modal').remove()
    $modal = $ '''
      <modal>
        <checkout api="{ opts.api }" model="{ opts.model }" config="{ opts.config }">
        </checkout>
      </modal>
      '''

    $(window).off('.crowdstart-modal-target').on('scroll.crowdstart-modal-target', ->
      $modal.children().first().css('top', $(@).scrollTop() + 'px'))

    for screen in config.screens
      $modal.find('checkout').append $ """
        <#{ screen.tag } api="{ opts.api }" model="{ opts.model }" config="{ opts.config }">
        <#{ screen.tag }/card>
        """

    $('body').prepend $modal
    $('head').append($('<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">'))

    if qs.referrer?
      order.referrerId = qs.referrer

    model =
      payment: (new Payment)
      order:   order
      user:    user

    riot.mount 'modal',
      id:     id
      api:    api
      model:  model
      config: config

if window?
  window.Crowdstart =
    API:      API
    Checkout: checkout
    ItemRef:  ItemRef
    Order:    Order
    User:     User
    setTheme: theme.setTheme

module.exports = checkout
